package Popo::Client;
use strict;
use warnings;
use utf8;

use IO::Handle;
use IO::Socket::UNIX;

my $server_read_socket;
my $server_write_socket;

sub main {
    my ($class, $socket, $socket_path) = @_;

    $server_read_socket = $socket;

    my $select = IO::Select->new();
    $select->add(\*STDIN);
    $select->add($server_read_socket);

    $class->_connect($socket_path);

    while ( my @handles = $select->can_read() ) {
        foreach (@handles) {
            if ( (fileno $_) == 0 ) {
                _stdin_callback();
            } elsif ( $_ == $server_read_socket ) {
                _socket_callback($server_read_socket );
            }
        }
    }
}


sub _connect {
    my ($class, $sock_path) = @_;

    $server_write_socket = IO::Socket::UNIX->new(
        Peer => $sock_path,
        Type => SOCK_STREAM,
    ) or die "Cannot connect client: $!";

}

sub _stdin_callback {
    my $read_data = <STDIN>;
    print "stdin : $read_data";
    print $server_write_socket $read_data;
}

sub _socket_callback {
    my $read_data = <$server_read_socket>;
    print "callback : $read_data";
    print $read_data;
}

1;
