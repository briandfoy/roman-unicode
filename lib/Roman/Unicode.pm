package Roman;

use utf8;
use 5.014;
use feature qw(unicode_strings);

use strict;
use warnings;
use open IO => ':utf8';

our $VERSION='1.23';

=encoding utf8

=head1 NAME

Roman::Unicode - Make roman numerals, using the Unicode characters for them

=head1 SYNOPSIS

	use Roman::Unicode;

	$arabic = arabic($roman) if is_roman($roman);
	$roman  = Roman($arabic);

=head1 DESCRIPTION



=head1 Functions

=head2 is_roman

Returns true if the string looks like a valid roman numeral. This works with
either the ASCII version 

=head2 to_perl( ROMAN )

If the argument is a valid roman numeral, to_perl returns the Perl number.
Otherwise, it returns nothing.

=head2 to_roman( PERL_NUMBER )

If the argument is a valid Perl number, even if it is a string,
C<to_roman> returns the roman numeral representation. This uses the
characters in the U+2160 to U+2188 range.

If the number cannot be represented as roman numerals, this returns
nothing. Note that 0 doesn't have a roman numeral representation.

If you want the lowercase version, you can use C<lc> on the result.
However, some of the roman numerals don't have lowercase versions.

=head2 to_ascii( ROMAN )

If the argument is a valid roman numeral, it returns an ASCII
representation of it. For characters that have ASCII representations,
it uses those ASCII characters. For other characters, it uses ASCII
art representations:

	Roman       ASCII art
	------      ----------

=head1 LIMITATIONS

By using just the defined roman numerals characters in the Unicode Character
Set, you're limited to numbers less than 400,000 (although you could make
ↈↈↈↈ if you wanted, since that's not unheard of).

=head1 AUTHOR

brian d foy C<< <brian.d.foy@gmail.com> >> 2011 

This module started with the Roman module, credited to:

OZAWA Sakuro C<< <ozawa at aisoft.co.jp> >> 1995-1997

Alexandr Ciornii, C<< <alexchorny at gmail.com> >> 2007

=head1 COPYRIGHT

Copyright (c) 2011, brian d foy.

You can use this module under the same terms as Perl itself.

=cut

use Exporter;
our @EXPORT = qw(is_roman arabic Roman roman);

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

sub is_roman($) {
    my @chars = _get_chars( $_[0] ); 
	
    if( @chars == 0 ) { return 0 }
    else {
    	return 0 if grep { ! exists $roman2arabic{ $_ } } @chars;
    	return 1;
    	}
	}

sub arabic($) {
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

sub roman($) {
    my( $arg ) = @_;
    0 < $arg and $arg < 4 * _highest_value()  or return;

    my($x, $roman) = ( '', '' );
    foreach my $figure ( @figure ) {
        my( $digit, $i, $v ) = (int( $arg/$figure ), @{$roman_digit{$figure}});

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

sub _compose {
	my( $string ) = @_;
	return unless is_roman( $string );

	my $_ = _decompose( $string );
	# ASCII / Roman
	s/III/ⅠⅠⅠ/g;
	s/II/ⅠⅠ/g
	s/IV/ⅠⅤ/g;
	s/VIII/ⅤⅠⅠⅠ/g;
	s/VI/ⅤⅠ/g;
	s/V/Ⅴ/g;
	s/IX/ⅠⅩ/g;
	s/XII/ⅩⅠⅠ/g;
	s/XI/ⅩⅠ/g;
	
	$_;
	}

1;
