#!/usr/bin/env perl
#===============================================================================
#
#         FILE: telegram_bot.pl
#
#        USAGE: ./telegram_bot.pl
#
#  DESCRIPTION: A Telegram Bot
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Andriy Podranetskyy (), apodran@gmail.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 15.09.15 23:21:11
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use 5.012;

use LWP::Simple;
use LWP::UserAgent;
use JSON::MaybeXS;
use List::Util qw/min max/;
use Data::Dumper::Concise;

my $TF_file_name = 'bot_token.txt';    # input file name

open my $TF, '<', $TF_file_name
  or die "$0 : failed to open  input file '$TF_file_name' : $!\n";

my $token = readline(*$TF);
chomp $token;

close $TF
  or warn "$0 : failed to close input file '$TF_file_name' : $!\n";

my $api_url = 'https://api.telegram.org/bot' . $token;

my $resp_json = get( $api_url . '/getUpdates' )
  or die "Failed to access to Telegram API!\n";
say $resp_json;

my $json_obj = decode_json($resp_json);
print Dumper $json_obj;

my $max_update_id = 0;
if ( $json_obj->{ok} ) {

    foreach my $m ( @{ $json_obj->{result} } ) {
        $max_update_id = max( $max_update_id, $m->{update_id} );

        say "Message:\t" . $m->{message}{text};
        if ( $m->{message}{text} eq 'ping' ) {
            reply_to( $m->{message}{chat}{id},
                $m->{message}{message_id}, 'pong' );
        }
    }
}

if ($max_update_id) {

    # mark as read

    my $ua = LWP::UserAgent->new;

    my $response = $ua->post(
        $api_url . '/getUpdates',
        [
            'offset' => $max_update_id + 1,

        ],
    );

    print Dumper( decode_json $response->content );
}

exit 0;

sub reply_to {
    my ( $chat_id, $msg_id, $text ) = @_;

    my $ua = LWP::UserAgent->new;

    my $response = $ua->post(
        $api_url . '/sendMessage',
        {
            'chat_id'             => $chat_id,
            'reply_to_message_id' => $msg_id,
            'text'                => $text,
        },
    );

    print Dumper( decode_json $response->content );

    return;
}    ## --- end sub reply_to
