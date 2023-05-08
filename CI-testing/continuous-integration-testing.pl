#!/usr/bin/env perl

use 5.014;
use strict;
use warnings;
use autodie;

use Path::Tiny qw/ cwd path /;

=begin foo

    # - if false ; then ( a="$(pwd)"; mkdir B2 && cd B2 && hg clone https://bitbucket.org/shlomif/shlomif-cmake-modules && cd shlomif-cmake-modules/shlomif-cmake-modules && cp -f "$(pwd)"/Shlomif_Common.cmake "$a"/installer/cmake/ ) ; fi
    #

=cut

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

# my $TEMP_DEBUG = $IS_WIN;
my $TEMP_DEBUG = 0;
my $CPAN       = 'cpanm';
if ($TEMP_DEBUG)
{
    $CPAN .= " -n";
}
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
    if ( $TEMP_DEBUG and $IS_WIN )
    {
        foreach my $d ( 'Perl/modules/HTML-Latemp-News', )
        {
            my $cwd = cwd();
            chdir($d);
            do_system( { cmd => [ "dzil", "build", ] } );
            my $build = "HTML-Latemp-News-0.2.1";
            chdir($build);
            my $fn     = "lib/HTML/Latemp/News.pm";
            my $backup = "c:/News.pm-aristt.orig.orig";
            path($fn)->copy($backup);
            eval { do_system( { cmd => [ "tidyall", "-a", ] } ); };
            do_system(
                {
                    cmd => [ "diff", "-u", $backup, $fn, ],
                }
            );
            chdir($cwd);
        }
        exit(1);
    }

DZIL_DIRS:
    foreach my $d (@dzil_dirs)
    {
        # tidyall test is failing on Windows
        if ( $IS_WIN and ( $d =~ /Latemp-News\z/ ) )
        {
            next DZIL_DIRS;
        }
        do_system( { cmd => ["cd $d && (dzil smoke --release --author)"] } );
    }

    path("installer/B")->remove_tree;

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
