use strict;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Net::P0f',
    license             => 'perl',
    dist_author         => 'S�bastien Aperghis-Tramoni <sebastien@aperghis.net>',
    dist_version_from   => 'lib/Net/P0f.pm',
    requires => {
        'Net::Pcap' => 0,
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Net-P0f-*' ],
);

$builder->create_build_script();