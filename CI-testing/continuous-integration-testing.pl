#!/usr/bin/env perl

use 5.014;
use strict;
use warnings;
use autodie;

sub do_system
{
    my ($args) = @_;

    my $cmd = $args->{cmd};
    print "Running [@$cmd]\n";
    if ( system(@$cmd) )
    {
        die "Running [@$cmd] failed!";
    }
}

my $IS_WIN = ( $^O eq "MSWin32" );
my $SEP    = $IS_WIN ? "\\"    : '/';
my $MAKE   = $IS_WIN ? 'gmake' : 'make';

my $cmake_gen;
if ($IS_WIN)
{
    $cmake_gen = 'MSYS Makefiles';
}
my $ACTION = shift @ARGV;

my @dzil_dirs = (
    'Perl/modules/HTML-Latemp-GenMakeHelpers',
    'Perl/modules/HTML-Latemp-NavLinks-GenHtml',
    'Perl/modules/HTML-Latemp-News',
    'Perl/modules/Task-Latemp',
    'Perl/modules/Template-Preprocessor-TTML',
);

my $CPAN = 'cpanm';
if ( $ACTION eq 'install_deps' )
{
    foreach my $d (@dzil_dirs)
    {
        do_system(
            {
                cmd => [
"cd $d && (dzil authordeps --missing | $CPAN) && (dzil listdeps --author --missing | $CPAN)"
                ]
            }
        );
    }
}
elsif ( $ACTION eq 'test' )
{
    my $TEMP_DEBUG = 1;
    if ( $TEMP_DEBUG and $IS_WIN )
    {
        foreach my $d ( 'Perl/modules/HTML-Latemp-News', )
        {
            use Path::Tiny qw/ cwd /;
            my $cwd = cwd();
            chdir($d);
            do_system( { cmd => [ "dzil", "build", ] } );
            do_system(
                {
                    cmd => [
                        "diff", "-u",
                        (
                            map { "$_/lib/HTML/Latemp/News.pm" }
                                ( ".", "HTML-Latemp-News-0.2.1" )
                        )
                    ]
                }
            );
            chdir($cwd);
        }
        exit(1);
    }

    foreach my $d (@dzil_dirs)
    {
        do_system( { cmd => ["cd $d && (dzil smoke --release --author)"] } );
    }
    do_system(
        {
            cmd => [
                      "cd installer/ && mkdir B && cd B && $^X ..${SEP}Tatzer "
                    . ( defined($cmake_gen) ? qq#--gen="$cmake_gen"# : "" )
                    . " .. && $MAKE"
            ]
        }
    );
}
else
{
    die "Unknown action command '$ACTION'!";
}
