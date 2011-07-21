package Roman::Unicode;

use utf8;
use 5.014;
use feature qw(unicode_strings);

use strict;
use warnings;
use open IO => ':utf8';
use vars qw( $VERSION @EXPORT_OK );

use Exporter 'import';
@EXPORT_OK = qw( is_roman to_perl to_roman to_ascii );

$VERSION = '1.02_02';

use Unicode::Normalize qw(NFKD);

=encoding utf8

=head1 NAME

Roman::Unicode - Make roman numerals, using the Unicode characters for them

=head1 SYNOPSIS

	use Roman::Unicode qw( to_roman is_roman to_perl );

	my $perl_number  = to_perl( $roman ) if is_roman( $roman );
	my $roman_number = to_roman( $arabic );

=head1 DESCRIPTION

I made this module as a way to demonstrate various Unicode things without
mixing up natural language stuff. Surprisingly, roman numerals can do quite
a bit with that.

=head2 Functions

=over 4

=item is_roman( STRING )

Returns true if the string looks like a valid roman numeral. This
works with either the ASCII version or the ones using the characters
in the U+2160 to U+2188 range.

=item to_perl( ROMAN )

If the argument is a valid roman numeral, C<to_perl> returns the Perl
number. Otherwise, it returns nothing.

=item to_roman( PERL_NUMBER )

If the argument is a valid Perl number, even if it is a string,
C<to_roman> returns the roman numeral representation. This uses the
characters in the U+2160 to U+2188 range.

If the number cannot be represented as roman numerals, this returns
nothing. Note that 0 doesn't have a roman numeral representation.

If you want the lowercase version, you can use C<lc> on the result.
However, some of the roman numerals don't have lowercase versions.

=item to_ascii( ROMAN )

If the argument is a valid roman numeral, it returns an ASCII
representation of it. For characters that have ASCII representations,
it uses those ASCII characters. For other characters, it uses ASCII
art representations:

	Roman       ASCII art
	------      ----------
	ↂ          (C)
	ↈ          ((C))
	ↇ           (D)

=item IsRoman

=item IsLowercaseRoman

=item IsUppercaseRoman

These define special properties to quickly match the characters this
module considers valid Roman numerals.

=back

=head1 LIMITATIONS

By using just the defined roman numerals characters in the Unicode Character
Set, you're limited to numbers less than 400,000 (although you could make
ↈↈↈↈ if you wanted, since that's not unheard of).

=head1 AUTHOR

brian d foy C<< <brian.d.foy@gmail.com> >> 2011-

This module started with the Roman module, credited to:

OZAWA Sakuro C<< <ozawa at aisoft.co.jp> >> 1995-1997

Alexandr Ciornii, C<< <alexchorny at gmail.com> >> 2007

=head1 COPYRIGHT

Copyright (c) 2011, brian d foy.

You can use this module under the same terms as Perl itself.

=cut

# I'm specifically not using the characters for the other roman numberals
# because those are meant to stand alone, as they might in a clock face
our %valid_roman = map { $_, 1 } (
	# the capitals U+2160 to U+216F, U+2180 to U+2182, U+2187 to U+2188
	qw(Ⅰ Ⅴ Ⅹ Ⅼ Ⅽ Ⅾ Ⅿ ↁ ↂ ↇ ↈ ),
	# the lowercase U+2170 to U+217f
	qw(ⅰ ⅴ ⅹ ⅼ ⅽ ⅾ ⅿ),
	# the ASCII
	qw(I V X L C D M),
	qw(i v x l c d m),

	);

our %roman2arabic = qw(
	Ⅰ 1 Ⅴ 5 Ⅹ 10
	Ⅼ 50 Ⅽ 100 Ⅾ 500 Ⅿ 1000 ↁ 5000 ↂ 10000 ↇ 50000 ↈ 100000

	ⅰ 1 ⅴ 5 ⅹ 10
	ⅼ 50 ⅽ 100 ⅾ 500 ⅿ 1000
	);

sub _get_chars { my @chars = $_[0] =~ /(\X)/ug }

sub _highest_value {  (sort { $a <=> $b } values %roman2arabic)[-1] }

sub is_roman($) { $_[0] =~ / \A \p{IsRoman}+ \z /x }

sub to_perl($) {
    is_roman $_[0] or return;
    my($last_digit) = _highest_value();
    my($arabic);

    foreach my $char ( _get_chars( $_[0] ) ) {
        my $digit = $roman2arabic{$char};
        $arabic -= 2 * $last_digit if $last_digit < $digit;
        $arabic += ($last_digit = $digit);
	    }

    $arabic;
	}

BEGIN {

my %roman_digits = qw(
	1 ⅠⅤ
	10 ⅩⅬ
	100 ⅭⅮ
	1000 Ⅿↁ
	10000 ↂↇ
	100000 ↈↈↈↈ
	);

my @figure = reverse sort keys %roman_digits;
$roman_digits{$_} = [split(//, $roman_digits{$_}, 2)] foreach @figure;

sub to_roman($) {
    my( $arg ) = @_;

    {
    no warnings 'numeric';
    0 < $arg and $arg < 4 * _highest_value()  or return;
	}

    my($x, $roman) = ( '', '' );
    foreach my $figure ( @figure ) {
        my( $digit, $i, $v ) = (int( $arg/$figure ), @{$roman_digits{$figure}});

        if( 1 <= $digit and $digit <= 3 ) {
            $roman .= $i x $digit;
        	}
        elsif( $digit == 4 ) {
            $roman .= "$i$v";
        	}
        elsif( $digit == 5 ) {
            $roman .= $v;
        	}
        elsif( 6 <= $digit and $digit <= 8 ) {
            $roman .= $v . $i x ($digit - 5);
        	}
        elsif( $digit == 9 ) {
            $roman .= "$i$x";
        	}

        $arg -= $digit * $figure;
        $x = $i;
    	}

	$roman;
	}
}

sub to_ascii {
	my( $roman ) = @_;
	return unless is_roman( $roman );

	$roman = NFKD( $roman );

	$roman =~ s/ↁ/|))/g;
	$roman =~ s/ↂ/((|))/g;
	$roman =~ s/ↈ/(((|)))/g;
	$roman =~ s/ↇ/|)))/g;

	$roman;
	}

sub IsRoman {
	return <<'CODE_NUMBERS';
2160
2164
2169
216C 216F
2170
2174
2179
217C 217F
2181 2182
2187 2188
CODE_NUMBERS
	}

sub IsUppercaseRoman {
	return <<"CODE_NUMBERS";
2160
2164
2169
216C 216F
2181 2182
2187 2188
CODE_NUMBERS
	}

sub IsLowercaseRoman {
	return <<"CODE_NUMBERS";
2170
2174
2179
217C 217F
CODE_NUMBERS
	}

1;
