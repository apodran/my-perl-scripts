#!/usr/bin/env perl
#===============================================================================
#
#         FILE: cherrytree2zim.pl
#
#        USAGE: ./cherrytree2zim.pl
#
#  DESCRIPTION: Script for converting exported CherryTree's
#               "Export to Multiple Plain Text Files" to Zim Notebook structure.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Andriy Podranetskyy, apodran@gmail.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 16.02.17 13:59:13
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use feature ":5.14";
use open ':std', ':encoding(UTF-8)';

use Getopt::Long;
use Data::Dumper::Simple;
use File::Basename;
use File::Copy qw(copy);
use File::Find;
use File::Spec;
use File::Path qw(make_path);

my ( $source_dir, $target_dir, $notebook, $dry_run, $usage );
my $DEBUG = 0;

GetOptions(
    "source_dir=s" => \$source_dir,    # string
    "target_dir=s" => \$target_dir,    # string
    "notebook=s"   => \$notebook,      # string
    "dry_run"      => \$dry_run,
    "help|usage"   => \$usage,
    "debug"        => \$DEBUG,         # flag
) or usage( -die => 1 );

usage() if $usage;

usage(-die => 1) unless $source_dir;

die qq("$source_dir" is not a directory or is not readable!\n) unless -d $source_dir && -r $source_dir;

$target_dir ||= $source_dir . '/Zim_Notebook';

unless (-d $target_dir) {
    mkdir($target_dir, 0755) || die qq(Cannot mkdir "$target_dir"!\n);
}

die qq("$target_dir" directory is not writeable!\n) unless -w $target_dir;

$notebook ||= 'CherryTree_Notebook';

$target_dir .= $notebook;
unless ( -d $target_dir ) {
    mkdir( $target_dir, 0755 ) || die qq(Cannot mkdir Notebook directory "$target_dir"!\n);
}

my $files = find_files( $source_dir, qr{^$target_dir} );
print Dumper($files) if $DEBUG;

foreach my $f ( @$files ) {
    my $rel_path = File::Spec->abs2rel( $f, $source_dir );

    # Replace "--" used for CherryTree sub-node by "/"
    $rel_path =~ s!(?<=[^-])--!/!g;

    my $zf = $target_dir . '/' . $rel_path;
    say "NEW FILE: $zf" if $DEBUG;

    unless ($dry_run) {
        make_path( dirname($zf) );
        copy $f, $zf;
    }
}


exit;

sub usage {
    my %args = (
        -die => 0,
        @_
    );

    print << "USAGE";
Synopsis: $0 OPTIONS

Command-specific options:
   --source_dir <source directory>
      Required parameter.
      Path to the directory of exported files of CherryTree's "Export to Multiple Plain Text Files"
   --target_dir <target directory>
      Path to the directory where to place a new Zim Notebook files
   --notebook <new notebook name>
      Name of the new Zim Notebook
   --dry_run
      Do not do any changes, just show output
   --help
   --usage
      This message
   --debug
      Output debug info if set

Example:
    $0 --source_dir /tmp/exported_cherry_tree --target_dir ~/Notebooks --notebook "New Notebook"
USAGE

    exit( $args{-die} );

    return;
}

sub find_files {
    my ( $dir, $ignore ) = @_;
    $ignore ||= '';

    my @f = ();

    my $wanted = sub {
        push @f, $File::Find::name if -f $_;
        return;
    };

    my $skip_dirs = sub {
        return () if $ignore && $File::Find::dir =~ m($ignore);
        print "DEBUG: processed directory: $File::Find::dir\n" if $DEBUG;
        return @_;
    };

    find( { wanted => \&$wanted, preprocess => \&$skip_dirs }, $dir );

    return \@f;
}
