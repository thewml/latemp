#!/usr/bin/perl

use strict;
use warnings;

use MyManageNews qw/ get_news_manager /;
use Getopt::Long qw/ GetOptions /;

my $rss2_out = "dest/rss.xml";
GetOptions( "rss2-out=s" => \$rss2_out );

my $news_manager = get_news_manager();

$news_manager->generate_rss_feed( 'output_filename' => $rss2_out, );
