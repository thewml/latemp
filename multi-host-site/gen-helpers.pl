#!/usr/bin/perl

use strict;
use warnings;

use HTML::Latemp::GenMakeHelpers;

my $generator = 
    HTML::Latemp::GenMakeHelpers->new(
        'hosts' =>
        [ 
            map 
            { 
                +{ 'id' => $_, 'source_dir' => "src/$_", 
                   'dest_dir' => "\$(D)/$_",
               }, 
            } 
            (qw(t2 vipe common))
        ]
    );

$generator->process_all();

1;
