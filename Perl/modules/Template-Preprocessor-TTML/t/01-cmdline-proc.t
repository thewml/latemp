#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 9;

use Template::Preprocessor::TTML::CmdLineProc;

sub get_res
{
    my $obj = Template::Preprocessor::TTML::CmdLineProc->new(@_);
    return $obj->get_result();
}

# Test for no specified filename
{
    my $r;
    eval {
        $r = get_res(argv => [qw()]);
    };
    # TEST
    ok($@, "Testing for thrown exception");
}

# Test for one filename
{
    my $r = get_res(argv => ["hello.ttml"]);
    # TEST
    ok($r, "Result is OK");
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    ok($r->output_to_stdout(), "Outputting to stdout");
}

# Test for last filename is an option
{
    my $r;
    eval {
        $r = get_res(argv => [qw(--hello.ttml)]);
    };
    # TEST
    ok($@, "Testing for thrown exception");
}

# Test for one filename starting with minus
{
    my $r = get_res(argv => ["--", "--hello.ttml"]);
    # TEST
    ok($r, "Result is OK");
    # TEST
    is($r->input_filename(), "--hello.ttml", "Input filename is OK");
    # TEST
    ok($r->output_to_stdout(), "Outputting to stdout");
}

# Test for junk after one filename
{
    my $r;
    
    eval {
         $r = get_res(argv => ["hello.ttml", "YOWZA!"]);
    };
    # TEST
    ok ($@, "Junk after input filename");
}

