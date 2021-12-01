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

use List::Compare;

my ( $file1, $file2, $option ) = @ARGV;

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
if ( $option && $option eq '-i' ) {
    @list = $lc->get_intersection;
}
else {
    @list = $lc->get_unique;
}

print foreach @list;
