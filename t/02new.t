#!/usr/bin/perl -T
use strict;
use Test;
BEGIN { plan tests => 8 }
use Net::P0f;

my $p0f;

# create an object
$p0f = new Net::P0f;
ok( defined $p0f                               );  #01
ok( ref $p0f, 'Net::P0f::Backend::CmdFE'       );  #02
$p0f = undef;

$p0f = new Net::P0f backend => 'cmd';
ok( defined $p0f                               );  #03
ok( ref $p0f, 'Net::P0f::Backend::CmdFE'       );  #04
$p0f = undef;

$p0f = new Net::P0f backend => 'socket';
ok( defined $p0f                               );  #05
ok( ref $p0f, 'Net::P0f::Backend::Socket'      );  #06
$p0f = undef;

$p0f = new Net::P0f backend => 'xs';
ok( defined $p0f                               );  #07
ok( ref $p0f, 'Net::P0f::Backend::XS'          );  #08
$p0f = undef;
