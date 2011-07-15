use 5.014;
use strict;
use warnings;
use open IO => ':utf8';
use utf8;
use vars qw( %roman2perl );

use Test::More;

if( Test::Builder->VERSION < 2 ) {
	foreach my $method ( qw(output failure_output) ) {
		binmode Test::More->builder->$method(), ':encoding(UTF-8)';
		}
	}

use_ok( 'Roman::Unicode' );

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
	ↈↈ        ((c))((c))
	ↂↈ	        (c)((c))
	ↂↈⅯↂ		(c)((c))ⅿ((c))
	ↂↈⅯↂⅤⅠⅠ   (c)((c))ⅿ((c))ⅴⅰⅰ
	ↈↈↈ      ((c))((c))((c))
	);

foreach my $upper ( sort keys %upper2lower ) {
	my $lower = $upper2lower{$upper};

	is( lc $upper, $lower, "$upper turns into $lower"   );
	}

done_testing();
