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
    print "-I$wml_include_path -I" . $ENV{'HOME'} . "/.latemp/lib/". "\n";
    exit;
}

