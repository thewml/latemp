#!/usr/bin/perl

use strict;
use warnings;

use IO::All;

my ($version) = 
    (map { m{\$VERSION *= *'([^']+)'} ? ($1) : () } 
    io->file('lib/Task/Sites/ShlomiFish.pm')->getlines()
    )
    ;

if (!defined ($version))
{
    die "Version is undefined!";
}

my $mini_repos_base = 'https://svn.berlios.de/svnroot/repos/web-cpan/latemp/';

my @cmd = (
    "svn", "copy", "-m",
    "Tagging the Task-Sites-ShlomiFish release as $version",
    "$mini_repos_base/trunk",
    "$mini_repos_base/tags/Perl/Task-Sites-ShlomiFish/releases/$version",
);

print join(" ", @cmd), "\n";
exec(@cmd);

