package Net::P0f::Backend::XS;
use strict;
use Carp;

{ no strict;
  $VERSION = 0.01;
  @ISA = qw(Net::P0f);
}

=head1 NAME

Net::P0f::Backend::XS - Back-end for C<Net::P0f> that links to the P0f library

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use Net::P0f;

    my $p0f = Net::P0f->new(backend => 'xs', ...);
    ...

=head1 DESCRIPTION

This module is a back-end helper for B<Net::P0f>. 
It provides an interface to pilot the libp0f library. 

See L<Net::P0f> for more general information and examples. 

=head1 METHODS

=over 4

=item init()

This method initialize the backend-specific part of the object. 
It is automatically called by C<Net::P0f> during the object creation.

B<Options>

=over 4

=item *

C<XXX> - XXX

=back

=cut

sub init {
    my $self = shift;
    my %opts = @_;

    # declare my specific options
    #$self->{options}{XXX} = '';
    
    # initialize my options
    for my $opt (keys %opts) {
        exists $self->{options}{$opt} ?
        ( $self->{options}{$opt} = $opts{$opt} and delete $opts{$opt} )
        : carp "warning: unknown option '$opt'";
    }
}

=item run()

=cut

sub run {
    my $self = shift;
    die "*** ",(caller(0))[3]," not implemented ***\n"
}

=back

=head1 SEE ALSO

L<Net::P0f>

=head1 AUTHOR

SE<eacute>bastien Aperghis-Tramoni E<lt>sebastien@aperghis.netE<gt>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-net-p0f-xs@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2004 SE<eacute>bastien Aperghis-Tramoni, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Net::P0f::Backend::XS
