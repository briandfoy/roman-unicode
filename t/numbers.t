use 5.014;
use strict;
use warnings;
use open IO => ':utf8';
use utf8;

use vars qw( %roman2perl );

BEGIN{
%roman2perl = qw(
	Ⅰ       1
	ⅠⅠ       2
	ⅠⅠⅠ      3
	ⅠⅤ      4 
	Ⅴ       5 
	ⅤⅠⅠ      7	 
	Ⅹ       10 
	Ⅼ       50 
	Ⅽ       100 
	Ⅾ           500 
	Ⅿ           1000 
	ⅯⅭⅮⅩⅬⅠⅤ     1444 
	ⅯⅯⅤⅠⅠ       2007
	ↈↈ        200000
	ↂↈ	        90000
	ↂↈⅯↂ		99000
	ↂↈⅯↂⅤⅠⅠ   99007
	);
}

use Test::More;
use_ok( 'Roman::Unicode' );

foreach my $roman ( sort keys %roman2perl ) {
	my $number = $roman2perl{$roman};

	ok( Roman::Unicode::is_roman( $roman  ),          "$roman is roman"   );
	is( Roman::Unicode::to_perl(  $roman  ), $number, "$roman is $number" );
	is( Roman::Unicode::to_roman( $number ), $roman,  "$number is $roman" );
	}

done_testing();
