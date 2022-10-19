#!/usr/bin/perl

use strict;
use warnings;

use File::Find::Rule ();
use File::Basename   qw/ dirname /;
use File::Path       qw/ mkpath /;
use File::Copy       qw/ copy /;

my $inst_dir = $ENV{'HOME'} . "/conf/wml/Latemp/";

my @files =
    File::Find::Rule->not( File::Find::Rule->directory->name(".svn")->prune )
    ->not( File::Find::Rule->directory )->in("lib");

foreach my $f (@files)
{
    my $dir = dirname($f);
    mkpath( ["$inst_dir/$dir"] );
    copy( $f, "$inst_dir/$f" );
}
