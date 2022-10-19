#!/usr/bin/perl

use strict;
use warnings;

use File::Find;
use File::Basename qw/ dirname /;
use File::Path     qw/ mkpath /;
use File::Copy     qw/ copy /;

my $inst_dir = $ENV{'HOME'} . "/conf/wml/Latemp/";

my @filenames;

sub wanted
{
    my $fn = $File::Find::name;
    if ( ( -f $fn ) and ( $fn !~ m#\.svn# ) )
    {
        push @filenames, $fn;
    }
    return;
}
find( \&wanted, "lib/", );

foreach my $fn (@filenames)
{
    my $dn = dirname($fn);
    mkpath( ["$inst_dir/$dn"] );
    copy( $fn, "$inst_dir/$fn" );
}
