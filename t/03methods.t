#!/usr/bin/perl -T
use strict;
use Test;
BEGIN { plan tests => 39 }
use Net::P0f;

my $p0f;

# create an object
$p0f = new Net::P0f;

# class methods
ok( defined $p0f->can('lookupdev')             );  #01
ok( defined $p0f->can('findalldevs')           );  #02
ok( defined $p0f->can('new')                   );  #03

# object methods
ok( defined $p0f->can('loop')                  );  #04
ok( defined $p0f->can('init')                  );  #05
ok( defined $p0f->can('run')                   );  #06

# accessors
ok( $p0f->chroot_as, undef                     );  #07
ok( $p0f->chroot_as('nobody'), undef           );  #08
ok( $p0f->chroot_as, 'nobody'                  );  #09

ok( $p0f->fingerprints_file, undef             );  #10
ok( $p0f->fingerprints_file('p0f.fp'), undef   );  #11
ok( $p0f->fingerprints_file, 'p0f.fp'          );  #12

ok( $p0f->interface, undef                     );  #13
ok( $p0f->interface('eth0'), undef             );  #14
ok( $p0f->interface, 'eth0'                    );  #15

ok( $p0f->dump_file, undef                     );  #16
ok( $p0f->dump_file('network.dump'), undef     );  #17
ok( $p0f->dump_file, 'network.dump'            );  #18

ok( $p0f->detection_mode, 0                    );  #19
ok( $p0f->detection_mode(1), 0                 );  #20
ok( $p0f->detection_mode, 1                    );  #21

ok( $p0f->fuzzy, 0                             );  #22
ok( $p0f->fuzzy(1), 0                          );  #23
ok( $p0f->fuzzy, 1                             );  #24

ok( $p0f->promiscuous, 0                       );  #25
ok( $p0f->promiscuous(1), 0                    );  #26
ok( $p0f->promiscuous, 1                       );  #27

ok( $p0f->filter, undef                        );  #28
ok( $p0f->filter('net 192.168.1'), undef       );  #29
ok( $p0f->filter, 'net 192.168.1'              );  #30

ok( $p0f->masquerade_detection, 0              );  #31
ok( $p0f->masquerade_detection(1), 0           );  #32
ok( $p0f->masquerade_detection, 1              );  #33

ok( $p0f->masquerade_detection_threshold, undef      );  #34
ok( $p0f->masquerade_detection_threshold(100), undef );  #35
ok( $p0f->masquerade_detection_threshold, 100        );  #36

ok( $p0f->resolve_names, 0                     );  #37
ok( $p0f->resolve_names(1), 0                  );  #38
ok( $p0f->resolve_names, 1                     );  #39
