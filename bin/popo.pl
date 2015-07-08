#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Popo::Server;
use Popo::Client;

my $socket_path = '/tmp/popo.sock'; # Unixドメインソケットファイルの名前

sub main {

    GetOptions(
        'socket_file_name=s' => \$socket_path,
    );

    # test code
    unlink($socket_path);

    my $socket;
    if ( ! -s $socket_path ) {
        $socket = Popo::Server->create($socket_path);
    }

    Popo::Client->main($socket, $socket_path);
}

main();
