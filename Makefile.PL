use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::P0f',
    AUTHOR              => 'Sébastien Aperghis-Tramoni <sebastien@aperghis.net>',
    VERSION_FROM        => 'lib/Net/P0f.pm',
    ABSTRACT_FROM       => 'lib/Net/P0f.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Net::Pcap' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net-P0f-*' },
);
