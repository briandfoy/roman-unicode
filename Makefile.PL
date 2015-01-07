use 5.014;
use strict;
use warnings;

my $github    = 'https://github.com/briandfoy/';
my $main_file = 'lib/';

my %WriteMakefile = (
    NAME                => 'Roman::Unicode',
    AUTHOR              => 'brian d foy <brian.d.foy@gmail.com>',
    VERSION_FROM        => 'lib/Roman/Unicode.pm',
	ABSTRACT            => 'Make roman numerals, using the Unicode characters for them',
	PREREQ_PM           => {
		'Unicode::Casing' => '0',
		},
    clean               => { FILES => 'Roman-* *.bak *.old' },
	);

sub arguments { \%WriteMakefile }

do_it() unless caller;
sub do_it {
	require File::Spec;
	my $MM ='ExtUtils::MakeMaker';
	my $MM_version =
		eval{ "$MM " . $WriteMakefile{'CONFIGURE_REQUIRES'}{'ExtUtils::MakeMaker'} }
			//
		"$MM 6.64";
	eval "use $MM_version" || die "Could not load $MM_version: $@";
	eval "use Test::Manifest 1.21" 
		if -e File::Spec->catfile( qw(t test_manifest) );
	WriteMakefile( %WriteMakefile );
	}


no warnings;
__PACKAGE__;
