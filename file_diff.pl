#!/usr/bin/perl
#===============================================================================
#
#         FILE:  file_diff.pl
#
#        USAGE:  ./file_diff.pl
#
#  DESCRIPTION:  This script returns a difference between two files.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:
#      VERSION:  1.0
#      CREATED:  09/28/2011 02:42:55 AM EEST
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use utf8;

use Getopt::Long;
use List::Compare;

my ( $difference, $intersection, $usage );

GetOptions(
    "difference"   => \$difference,      # boolean
    "intersection" => \$intersection,    # boolean
    "help|usage"   => \$usage,
) or usage( -die => 1 );

usage() if $usage;

my ( $file1, $file2 ) = @ARGV;

unless ( $file1 && $file2 ) {
    die "Two existing files should be given!\n";
}

unless ( -r $file1 ) {
    die "File '$file1' is not readable!\n";
}

unless ( -r $file2 ) {
    die "File '$file2' is not readable!\n";
}

my $INFILE1_file_name = $file1;    # input file name

open my $INFILE1, '<', $INFILE1_file_name
  or die "$0 : failed to open  input file $INFILE1_file_name : $!\n";

my @lines1 = <$INFILE1>;

close $INFILE1
  or warn "$0 : failed to close input file $INFILE1_file_name : $!\n";

my $INFILE2_file_name = $file2;    # input file name

open my $INFILE2, '<', $INFILE2_file_name
  or die "$0 : failed to open  input file $INFILE2_file_name : $!\n";

my @lines2 = <$INFILE2>;

close $INFILE2
  or warn "$0 : failed to close input file $INFILE2_file_name : $!\n";

# Compare lines: only lines of file1 not presented in file2 will be shown
my $lc = List::Compare->new( \@lines1, \@lines2 );

my @list;
if ($intersection) {
    @list = $lc->get_intersection;
}
else {
    @list = $lc->get_unique;
}

print foreach @list;

exit;

sub usage {
    my %args = (
        -die => 0,
        @_
    );

    print << "USAGE";
Synopsis: $0 <file1> <file2> OPTIONS

Command-specific options:
   --difference
      Show a difference of two files (default option)
   --intersection
      Show an intersection of two files instead of a difference
   --help
   --usage
      This message

Examples:
    $0 file1.txt file2.txt
    $0 -i file1.txt file2.txt
    $0 file1.txt file2.txt --intersection
    $0 --difference file1.txt file2.txt
USAGE

    exit( $args{-die} );

    return;
}
