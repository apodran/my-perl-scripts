#!/usr/bin/env perl
#===============================================================================
#
#         FILE: port_check.pl
#
#        USAGE: ./port_check.pl
#
#  DESCRIPTION: Port checker
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Andriy Podranetskyy (), apodran@gmail.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 22.09.17 12:32:40
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use 5.012;

use Net::Ping;

# TGX protocol
my $scan_port = 40001;

# TGX host
my @hosts = ( '10.110.3.35', '192.168.40.20' );

my ( $host, $ret, $duration, $ip, $port, $rtt );

# Like tcp protocol, but with many hosts
my $proto = 'syn';
my $p = Net::Ping->new($proto);
$p->port_number($scan_port);
$p->hires();

$p->service_check(1);
foreach my $h (@hosts) {
    ( $ret, $duration, $ip, $port ) = $p->ping( $h, 5.5 );
    printf( "$h [ip: $ip] is alive (packet return time: %.2f ms)\n",
        1000 * $duration )
        if $ret;
}

while ( ( $host, $rtt, $ip ) = $p->ack ) {
    print "HOST: $host [$ip] ACKed in $rtt seconds.\n";
}

$p->close();
