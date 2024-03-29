#!/usr/bin/env perl

use strict;
use warnings;

use Cwd                          qw( getcwd );
use Path::Tiny                   qw/ path /;
use HTML::Latemp::GenMakeHelpers ();

my $generator = HTML::Latemp::GenMakeHelpers->new(
    'hosts' => [
        map {
            +{
                'id'         => $_,
                'source_dir' => $_,
                'dest_dir'   => "\$(ALL_DEST_BASE)/$_-homepage"
            }
        } (qw( common t2 vipe ))
    ],
);

$generator->process_all();

my $mak_fh = path("include.mak");
my $text   = $mak_fh->slurp_utf8();
$text =~ s!^(T2_DOCS = .*)humour/fortunes/index.html!$1!m;
$mak_fh->spew_utf8($text);

# This is to in order to generate the t2/humour/fortunes/arcs-list.mak
# file, which is inclduded by the makefile.
{
    my $orig_dir = getcwd();

    chdir("t2/humour/fortunes");
    system( "make", "dist" );

    chdir($orig_dir);
}
