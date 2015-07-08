package Popo::Server;
use strict;
use warnings;
use utf8;
use Socket;
use IO::Socket::UNIX;
use IO::Select;
use POSIX;

my $client_read_socket;
my $client_write_socket;

sub create {
    my ($class, $socket_path) = @_;

    my ($read, $write) = IO::Socket->socketpair(AF_UNIX, SOCK_STREAM, PF_UNSPEC) 
        or die "Cannot socketpair: $!";

    my $pid;
    if (!defined ($pid = fork())) {
        die "Cannot fork: $!";
    } elsif (! $pid) {
        # parent
        close $write;
        return $read;
    } else {
        # child
        close $read;
        print "server process id is $$\n";
        $client_write_socket = $write;
    }

    POSIX::setsid();

    my $socket = _create_socket($socket_path);

    my $select = IO::Select->new();
    $select->add($socket);

    while ( my @handle = $select->can_read() ) {
        foreach ( @handle ) {
            if ( $_ == $socket) {
                print "client connection\n";
                $client_read_socket = $socket->accept();
                $select->add($client_read_socket);
            } elsif ( $_ == $client_read_socket ) {
                _server_callback();
            }
        }
        sleep(1);
    }
}


sub _create_socket {
    my $socket_path = shift;

    return IO::Socket::UNIX->new(
        Local  => $socket_path,
        Type   => SOCK_STREAM,
        Listen => SOMAXCONN,
    ) or die "Cannot create server: $!";

}

sub _server_callback {

    my $read_data = <$client_read_socket>;
    print "server write: $read_data";
    print $client_write_socket $read_data;
}

1;
