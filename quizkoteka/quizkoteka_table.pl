#!/usr/bin/env perl
#===============================================================================
#
#         FILE: quizkoteka_table.pl
#
#        USAGE: ./quizkoteka_table.pl
#
#  DESCRIPTION: Script for manipulating game results for QuizКОТЕка stored in
#               an image file.
#               Quizkoteka: https://www.facebook.com/Quizkoteka/
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Andriy Podranetskyy (), apodran@gmail.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 24/03/16 19:11:05
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use v5.14;

binmode STDOUT, ":encoding(UTF-8)";

use Image::OCR::Tesseract 'get_ocr';
use Data::Dumper::Concise;
use Encode;

my $image = './results.jpg';

my $text = get_ocr( $image, undef, 'ukr+eng' );

$text = Encode::decode_utf8( $text );
say $text;

my @lines = grep {/\w/} split /\n+/, $text;
#print Dumper \@lines;

my @results = ();
foreach my $l (@lines) {
    if ( $l =~ /^(.+?)\s+((?:[\p{Any},]+ +){8})([\w,]+) +([\w-]+)$/u ) {
        push @results, { team => $1, tours => $2, res => $3, place => $4 };
    }
}

#print Dumper \@results;


foreach my $r ( @results ) {
    write;
format STDOUT =
  @<<<<<<<<<<<<<<<<<< | @<<<<<<<<<<<<<<<<<<<< | @>>>>>>>> | @|||||
   $r->{team},           $r->{tours},            $r->{res}, $r->{place}
.
format STDOUT_TOP =
  ----------------------------------------------------------------
.

}
