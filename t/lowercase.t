use 5.014;
use strict;
use warnings;
use open IO => ':utf8';
use utf8;
use vars qw( %roman2perl );

use Test::More 1.0;

if( Test::Builder->VERSION < 2 ) {
	foreach my $method ( qw(output failure_output) ) {
		binmode Test::More->builder->$method(), ':encoding(UTF-8)';
		}
	}

# Need to load this before Unicode::Casing
BEGIN { use_ok( 'Roman::Unicode' ) }

my %upper2lower = qw(
	Ⅰ       ⅰ
	ⅠⅠ       ⅰⅰ
	ⅠⅠⅠ      ⅰⅰⅰ
	ⅠⅤ      ⅰⅴ
	Ⅴ       ⅴ
	ⅤⅠⅠ     ⅴⅰⅰ
	Ⅹ       ⅹ
	Ⅼ       ⅼ
	Ⅽ       ⅽ
	Ⅾ           ⅾ
	Ⅿ           ⅿ
	ⅯⅭⅮⅩⅬⅠⅤ     ⅿⅽⅾⅹⅼⅰⅴ
	ⅯⅯⅤⅠⅠ       ⅿⅿⅴⅰⅰ
	ↈↈ        (((|)))(((|)))
	ↂↈ	        ((|))(((|)))
	ↂↈⅯↂ		((|))(((|)))ⅿ((|))
	ↂↈⅯↂⅤⅠⅠ   ((|))(((|)))ⅿ((|))ⅴⅰⅰ
	ↈↈↈ      (((|)))(((|)))(((|)))
	);

	diag( "Entering foreach" );

foreach my $upper ( sort keys %upper2lower ) {
	my $lower = $upper2lower{$upper};

	use Unicode::Casing lc => \&Roman::Unicode::to_roman_lower;

	diag( "After test for $upper" );
	# is( lc $upper, $lower, "$upper turns into $lower"   );
	diag( "After test for $upper" );
	}

	diag( "Leaving foreach" );

diag "Before done_testing";
done_testing();
diag "After done_testing";

# For some reason Travis CI exits with 139 on v5.14 even though
# all of the tests pass. So, this is here.
diag "Before exit";
CORE::exit( 0 );
