#!/usr/bin/env perl

use strict;
use warnings;
use autodie;

sub do_system
{
    my ($args) = @_;

    my $cmd = $args->{cmd};
    print "Running [@$cmd]";
    if (system(@$cmd))
    {
        die "Running [@$cmd] failed!";
    }
}

my $cmd = shift@ARGV;

# do_system({cmd => ["cd black-hole-solitaire/ && mkdir B && cd B && ../c-solver/Tatzer && make && $^X ../c-solver/run-tests.pl"]});

# do_system({cmd => ["cd black-hole-solitaire/Games-Solitaire-BlackHole-Solver/ && dzil test --all"]});

my @dzil_dirs =
(
    'Perl/modules/HTML-Latemp-GenMakeHelpers',
    'Perl/modules/HTML-Latemp-NavLinks-GenHtml',
    'Perl/modules/HTML-Latemp-News',
);

if ($cmd eq 'install_deps')
{
    foreach my $d (@dzil_dirs)
    {
        do_system({cmd => ["cd $d && (dzil authordeps --missing | sudo cpanm) && (dzil listdeps --author --missing | sudo cpanm)"]});
    }
}
elsif ($cmd eq 'test')
{
    foreach my $d (@dzil_dirs)
    {
        do_system({cmd => ["cd $d && (dzil smoke --release --author)"]});
    }
}
else
{
    die "Unknown command '$cmd'!";
}
