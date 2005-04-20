#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $prefix = "<<<PREFIX>>>";

my $wml_include_path = 0;
GetOptions(
    "wml-include-path" => \$wml_include_path
);

if ($wml_include_path)
{
    print "$prefix/lib/wml/include/latemp/\n";
    exit;
}

