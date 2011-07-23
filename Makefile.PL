use 5.014;
use strict;
use warnings;
use ExtUtils::MakeMaker;

eval 'use Test::Manifest 1.21';

WriteMakefile(
    NAME                => 'Roman::Unicode',
    AUTHOR              => 'brian d foy <brian.d.foy@gmail.com>',
    VERSION_FROM        => 'lib/Roman/Unicode.pm',
	ABSTRACT            => 'Make roman numerals, using the Unicode characters for them',
	PREREQ_PM           => {
		'Unicode::Casing' => '0',
		},
    clean               => { FILES => 'Roman-* *.bak *.old' },
	);
