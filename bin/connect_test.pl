#!/usr/bin/perl

use IO::Socket::UNIX;


my $socket = IO::Socket::UNIX->new(
    Peer => "/tmp/popo.sock",
    Type => SOCK_STREAM,
) or die $!;

print "socket number is: ". $socket. "\n";

print $socket 'client test\n';
