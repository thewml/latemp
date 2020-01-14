#!/usr/bin/perl

use strict;
use warnings;

use IO::Al qw/ io /;

my ($version) =
    ( map { m{\$VERSION *= *'([^']+)'} ? ($1) : () }
        io->file('lib/HTML/Latemp/NavLinks/GenHtml.pm')->getlines() );

if ( !defined($version) )
{
    die "Version is undefined!";
}

my @cmd = (
    "git", "tag", "-m",
    "Tagging the HTML-Latemp-NavLinks-GenHtml release as $version",
    "Perl/HTML-Latemp-NavLinks-GenHtml/releases/$version",
);

print join( " ", map { /\s/ ? qq{"$_"} : $_ } @cmd ), "\n";
exec(@cmd);

