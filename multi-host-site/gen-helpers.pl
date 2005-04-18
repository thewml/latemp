#!/usr/bin/perl

use strict;
use warnings;

use File::Find::Rule;
use File::Basename;

my $dir = "src";
my @files = File::Find::Rule->in($dir);

s!^src/!! for @files;
@files = (grep { $_ ne $dir } @files);
@files = (grep { ! m{(^|/)\.svn(/|$)} } @files);
@files = (grep { ! /~$/ } @files);
@files = 
    (grep 
    {
        my $b = basename($_); 
        !(($b =~ /^\./) && ($b =~ /\.swp$/))
    } 
    @files
    );
@files = sort { $a cmp $b } @files;

my @buckets = 
(
    {
        'name' => "IMAGES_PRE1",
        'filter' => sub { (!/\.wml$/) && (-f "$dir/$_") },
    },
    {
        'name' => "SUBDIRS_PROTO",
        'filter' => sub { (-d "$dir/$_") },
    },
    {
        'name' => "HTMLS_PROTO",
        'filter' => sub { /\.html\.wml$/ },
        'map' => sub { my $a = shift; $a =~ s{\.wml$}{}; return $a;},
    },
);

foreach (@buckets) 
{ 
    $_->{'results'}=[]; 
    if (!exists($_->{'map'}))
    {
        $_->{'map'} = sub { return shift;},
    }
}

FILE_LOOP: foreach (@files)
{
    for my $b (@buckets)
    {
        if ($b->{'filter'}->())
        {
            push @{$b->{'results'}}, $b->{'map'}->($_);
            next FILE_LOOP;
        }
    }
    die "Uncategorized file $_!";
}

open O, ">", "include.mak";
foreach my $b (@buckets)
{
    print O $b->{'name'} . " = " . join(" ", @{$b->{'results'}}) . "\n";
}
close(O);

1;
