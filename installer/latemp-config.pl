#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $prefix = "<<<PREFIX>>>";

my $opt_wml_include_path = 0;
my $opt_wml_flags = 0;
GetOptions(
    "wml-include-path" => \$opt_wml_include_path,
    "wml-flags" => \$opt_wml_flags,
);

my $wml_include_path = "$prefix/lib/wml/include/";
if ($opt_wml_include_path)
{
    print "$wml_include_path\n";
    exit;
}
if ($opt_wml_flags)
{
    my @inc_paths = 
    (
        $wml_include_path, 
        ($ENV{'HOME'} . "/.latemp/lib/")
    );
    print join(" ", (map { "-I$_ --passoption=2,-I$_" } @inc_paths)) . "\n";
    exit;
}

