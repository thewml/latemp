#!/usr/bin/env perl

use strict;
use warnings;

use IO::All qw/ io /;

my ($version) =
    ( map { m{\Aversion * = *(\S+)} ? ($1) : () }
        io->file("./dist.ini")->getlines() );

if ( !defined($version) )
{
    die "Version is undefined!";
}

my @cmd = (
    "git", "tag", "-m",
    "Tagging the HTML-Latemp-GenMakeHelpers release as $version",
    "Perl/HTML-Latemp-GenMakeHelpers/releases/$version",
);

print join( " ", map { /\s/ ? qq{"$_"} : $_ } @cmd ), "\n";
exec(@cmd);

