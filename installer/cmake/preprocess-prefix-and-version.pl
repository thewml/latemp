#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;

my $prefix;
my $version;

my $input_fn;
my $output_fn;

GetOptions
(
    "input=s" => \$input_fn,
    "output=s" => \$output_fn,
    "prefix=s" => \$prefix,
    "version=s" => \$version,
);

if (!defined($input_fn))
{
    die "Input filename not specified!";
}

if (!defined($output_fn))
{
    die "Output filename not specified!";
}

if (!defined($prefix))
{
    die "Prefix not specified!";
}

if (!defined($version))
{
    die "Version not specified!";
}

open my $in_fh, "<", $input_fn
    or die "Could not open '$input_fn'";

open my $out_fh, ">", $output_fn
    or die "Could not open '$output_fn'";

LINES:
while (my $line = <$in_fh>)
{
    if ($line =~ /\A__END__/)
    {
        last LINES;
    }
    elsif ($line =~ /^=head1/)
    {
        DISCARD_POD:
        while ($line = <$in_fh>)
        {
            if ($line =~ /^=cut/)
            {
                last DISCARD_POD;
            }
        }
    }
    else
    {
        $line =~ s{<<<PREFIX>>>}[$prefix]eg;
        $line =~ s{<<<VERSION>>>}[$version]eg;
        print {$out_fh} $line;
    }
}
close($in_fh);
close($out_fh);

chmod(0755, $output_fn);

exit(0);
