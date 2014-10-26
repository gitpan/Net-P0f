package Net::P0f;
use strict;
use Carp;
use Net::Pcap;
use Net::P0f::Backend::CmdFE;
use Net::P0f::Backend::Socket;
use Net::P0f::Backend::XS;

{ no strict;
  $VERSION = 0.01;
}

=head1 NAME

Net::P0f - Perl wrapper for the P0f utility

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Net::P0f;

    my $p0f = Net::P0f->new(interface => 'eth0', promiscuous => 1);
    $p0f->loop(callback => \&process_packet);

    sub process_packet {
        # do stuff with packet information
	# see the documentation for more details
    }

=head1 DESCRIPTION

This module (and its associated helper modules) is a Perl interface to 
the P0f utility. P0f is a passive operating system fingerprinting: it 
identifies the system of network devices by passively looking at specific 
patterns in their TCP/IP packets. 

For more information on P0f, please see L<http://lcamtuf.coredump.cx/p0f.shtml>

=head1 METHODS

=head2 Lookup methods

The following methods are class methods, which can of course also 
be used as object methods. 

=over 4

=item lookupdev()

Returns the name of a network device that can be used for operating. 

=cut

sub lookupdev {
    my $self = shift;
    my $err = '';
    my $dev = Net::Pcap::lookupdev(\$err);
    carp $err if $err;
    return $dev
}

=item findalldevs()

Returns a list of all network devices that can be used for operating. 

=cut

sub findalldevs {
    my $self = shift;
    die "*** ",(caller(0))[3],"not implemented ***\n";
}

=back

=head2 Packet analysis methods

=over 4

=item new()

B<Options>

=over 4

=item B<Engine options>

=item *

C<backend> - selects the back-end. 
Accepted values are C<"cmd">, C<"socket"> and C<"xs"> to select, 
respectively, the command line front-end, the socket version and 
the XS version. If not specified, defaults to C<"cmd">.

=item *

C<chroot_as> - chroot and setuid to this user. 
Accepted value is any valid user name. 
Default is not to chroot. 

=item *

C<fingerprints_file> - read fingerpints from the given file.

=item B<Input options>

Only one the following options must be used. 

=item *

C<interface> - selects the network device.
Accepted values are any interface name that the system can recognize. 
Remember that such names are usualy not portable. 

=item *

C<dump_file> - reads from the given dump file, as created by B<tcpdump(1)> 
with the C<-w file> option. 

=item B<Detection options>

=item *

C<detection_mode> - selects the detection mode. 
Accepted values are 0 for the SYN mode, 1 for the SYN+ACK mode, 
and 2 for the RST+ACK mode. 
Default value is 0. 

=item *

C<fuzzy> - activates the fuzzy matching (do not combine with 
the RST+ACK detection mode). 
Value can be 0 (fuzzy matching disabled) or 1 (activated). 
Default value is 0. 

=item *

C<promiscuous> - switches the network device to promiscuous mode.
Value can be 0 (normal mode) or 1 (promiscuous mode activated). 
Default value is 0.

=item *

C<filter> - pcap-style BPF expression.

=item *

C<masquerade_detection> - activates the masquerade detection. 
Value can be 0 (masquerade detection disabled) or 1 (enabled). 
Default value is 0. 

=item *

C<masquerade_detection_threshold> - sets the masquerade detection threshold. 
Value can be any integer between 1 and 200. 
Default value is 100.

=item *

C<resolve_names> - activates the IP to names resolution. 
Value can be 0 (do not resolve names) or 1 (resolve names). 
Default value is 0. 

=back

B<Example>

Common use under Linux: 

    my $p0f = new Net::P0f interface => 'eth0';

The same, in a more portable way: 

    my $p0f = new Net::P0f interface => Net::P0f->lookupdev;

=cut

my %objects = ();

sub new {
    my $class = ref $_[0] || $_[0]; shift;
    my $self = {
        options => {
            # Engine options
	    chroot_as       =>  undef,      # arg: user
	    fingerprints_file   =>  undef,  # arg: fingerprints file

            # Input options
            interface       =>  undef,      # arg: network device
            dump_file       =>  undef,      # arg: dump file

            # Detection options
            detection_mode  =>  0,          # switch 0/1
            fuzzy           =>  0,          # switch 0/1
            promiscuous     =>  0,          # switch 0/1
            filter          =>  undef,      # arg: BPF filter
            masquerade_detection    =>  0,  # switch 0/1
            masquerade_detection_threshold  =>  undef,  # arg: threshold
            resolve_names   =>  0,          # switch 0/1
        }, 
        loop => {
            callback    =>  0, 
            count       =>  0, 
            keep_on     =>  0, 
        }
    };

    # gets all options
    my %opts = @_;

    # select the backend and create the object
    my %backends = (
        cmd     => 'Net::P0f::Backend::CmdFE', 
       'socket' => 'Net::P0f::Backend::Socket', 
        xs      => 'Net::P0f::Backend::XS', 
    );
    $opts{backend} ||= 'cmd';  # default backend
    croak "unknown value for option 'backend': $opts{backend}" 
      unless exists $backends{$opts{'backend'}};
    my $backend = $backends{$opts{backend}};
    bless $self, $backend;
    delete $opts{backend};

    # initialize generic options
    for my $opt (keys %opts) {
        $self->{options}{$opt} = $opts{$opt} and delete $opts{$opt}
          if exists $self->{options}{$opt}
    }

    # initialize backend-specific options
    $self->init(%opts);

    # keep track of created objects
    $objects{"$self"} = $self;

    return $self
}


# 
# AUTOLOAD()
# --------
# generates dynamic accessors for all existing options
# 
sub AUTOLOAD {
    no strict;
    my $self = $_[0];
    my $type = ref $self || croak "I am not an object, so don't call me that way.";
    my $name = $AUTOLOAD;
    $name =~ s/.*:://;
    
    carp "Unknown option '$name'" unless exists $self->{options}{$name};

    my $code = q{
        sub {
            my $self = shift;
            my $value = $self->{options}{METHOD};
            $self->{options}{METHOD} = shift if @_;
            return $value
        }
    };
    $code =~ s/METHOD/$name/g;

    *$AUTOLOAD = eval $code;
    goto &$AUTOLOAD;
}


# 
# DESTROY()
# -------
sub DESTROY {
    delete $objects{"$_[0]"};
}


=item loop()

This method launches the execution of the P0f engine. 

B<Options>

=over 4

=item *

C<callback> - sets the callback function that will be called for 
each received packets. This option is required. 
See L<"CALLBACK"> for more information. 

=item *

C<count> - wait for this number of packets, then stop. If set to 
zero, run until a C<SIGINT> signal is received. This option is required. 

=back

B<Example>

    # process 10 packets, giving them to the packet_handler() function
    $p0f->loop(callback => \&packet_handler, count => 10);

=cut

sub loop {
    my $self = shift;
    my %opts = @_;

    for my $opt (qw(callback count)) {
        croak "Option '$opt' was not set" unless $opts{$opt};
        $self->{loop}{$opt} = $opts{$opt};
    }
    
    { # check input source
      my $v = defined($self->{options}{interface}) . defined($self->{options}{dump_file});
      for($v) {
          $_ eq '00' and 
            croak "No input source was defined. Please set one of 'interface' or 'dump_file'.";

          $_ eq '11' and do {
              carp "warning: Both 'interface' and 'dump_file' have been set. 'dump_file' prevails.";
              delete $self->{options}{interface};
          }
      }
    }
    
    # run the P0f engine
    $self->run;
}

=back

=head1 CALLBACK

A callback function has the following signature: 

    sub callback {
        my($self,$header,$os_info,$link_info) = @_;
	# ...
    }

where the parameters have the following meaning: 

=over 4

=item *

C<$self> is the C<Net::P0f> object

=item *

C<$header> is a hashref with the following keys: 

=over 4

=item *

C<ip_src> is the source IP address

=item *

C<name_src> is the source DNS name (if any)

=item *

C<port_src> is the source port

=item *

C<ip_dest> is the destination IP address

=item *

C<name_dest> is the destination DNS name (if any)

=item *

C<port_dest> is the destination port

=back

=item *

C<$os_info> is a hashref with the following keys: 

=over 4

=item *

C<genre> is the generic genre of the operating system (like C<"Linux"> 
or C<"Windows">)

=item *

C<details> gives more information on the operating system, like its 
version

=item *

C<uptime> indicates the uptime of the host

=back

=item *

C<$link_info> is a hashref with the following keys: 

=over 4

=item *

C<distance> is the distance to the host

=item *

C<link_type> is the type of the connection

=back

=back

=head1 SIGNALS

=over 4

=item sighandler()

This function is a signal handler for the C<SIGINT>, C<SIGTERM> 
and C<SIGQUIT> signals. Its main purpose is to tell all the 
instancied C<Net::P0f> objects to cleanly stop their engine. 

=back

=cut

sub sighandler {
    # tell all the created objects to stop their engine
    for my $key (keys %objects) {
        $objects{$key}->{loop}{keep_on} = 0;
    }
}

$SIG{INT}  = \&sighandler;
$SIG{TERM} = \&sighandler;
$SIG{QUIT} = \&sighandler;

=head1 SEE ALSO

B<p0f(1)> manual page

L<Net::P0f::Backend::CmdFE>, L<Net::P0f::Backend::Socket>, 
L<Net::P0f::Backend::XS> for backend specific details

=head1 AUTHOR

S�bastien Aperghis-Tramoni E<lt>sebastien@aperghis.netE<gt>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-net-p0f@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2004 S�bastien Aperghis-Tramoni, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Net::P0f
