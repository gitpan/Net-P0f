#!/usr/bin/perl -T
use strict;
use Test;
BEGIN { plan tests => 12 }

# check the functions defined in Net::P0f
use Net::P0f;
ok( defined &Net::P0f::new                      );  #01
ok( defined &Net::P0f::AUTOLOAD                 );  #02
ok( defined &Net::P0f::DESTROY                  );  #03
ok( defined &Net::P0f::loop                     );  #04
ok( defined &Net::P0f::lookupdev                );  #05
ok( defined &Net::P0f::findalldevs              );  #06

# check the functions defined in Net::P0f::Backend::CmdFE
use Net::P0f::Backend::CmdFE;
ok( defined &Net::P0f::Backend::CmdFE::init     );  #07
ok( defined &Net::P0f::Backend::CmdFE::run      );  #08

# check the functions defined in Net::P0f::Backend::Socket
use Net::P0f::Backend::Socket;
ok( defined &Net::P0f::Backend::Socket::init    );  #09
ok( defined &Net::P0f::Backend::Socket::run     );  #10

# check the functions defined in Net::P0f::Backend::XS
use Net::P0f::Backend::XS;
ok( defined &Net::P0f::Backend::XS::init        );  #11
ok( defined &Net::P0f::Backend::XS::run         );  #12

