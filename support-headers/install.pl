#!/usr/bin/perl

use strict;
use warnings;

use File::Find;
use File::Basename qw/ dirname /;
use File::Path     qw/ mkpath /;
use File::Copy     qw/ copy /;

my $inst_dir = $ENV{'HOME'} . "/conf/wml/Latemp/";

my @files;

sub wanted
{
    my $fn = $File::Find::name;
    if ( ( -f $fn ) and ( $fn !~ m#\.svn# ) )
    {
        push @files, $fn;
    }
    return;
}
find( \&wanted, "lib/", );

foreach my $f (@files)
{
    my $dir = dirname($f);
    mkpath( ["$inst_dir/$dir"] );
    copy( $f, "$inst_dir/$f" );
}
