#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 36;

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
    # TEST
    is_deeply($r->include_path(), [], "Include Path is empty");
    # TEST
    is_deeply($r->defines(), +{}, "Defines are empty");
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

# Test for -o
{
    my $r = get_res(argv => ["-o", "myout.html", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    ok(!$r->output_to_stdout(), "Not outting to stdout");
    # TEST
    is ($r->output_filename(), "myout.html", "Output filename is OK");
}

# Test for includes
{
    my $r = get_res(argv => ["-I", "mydir/", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    is_deeply($r->include_path(), ["mydir/"], "Include Path is OK");
}

# Test for includes
{
    my $r = get_res(argv => ["-Imydir/", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    is_deeply($r->include_path(), ["mydir/"], "Include Path is OK");
}

# Test for includes
{
    my $r = get_res(argv => ["--include=mydir/", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    is_deeply($r->include_path(), ["mydir/"], "Include Path is OK");
}

# Test for includes
{
    my $r = get_res(argv => ["--include", "mydir/", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    is_deeply($r->include_path(), ["mydir/"], "Include Path is OK");
}

# Several includes
{
    my $r = get_res(argv => ["--include", "mydir/", "-I/hello/home", "--include=/yes/no", "-I", "./you-say/", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    is_deeply(
        $r->include_path(), 
        ["mydir/", "/hello/home", "/yes/no", "./you-say/",], 
        "Include Path is OK"
    );
}

# Test for defines
{
    my $r = get_res(argv => ["-Dmyarg=myval", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    is_deeply($r->defines(), {'myarg' => "myval"}, "Defines are OK");
}

# Test for defines
{
    my $r = get_res(argv => ["-D", "myarg=myval", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    is_deeply($r->defines(), {'myarg' => "myval"}, "Defines are OK");
}

# Test for defines
{
    my $r = get_res(argv => ["--define=myarg=myval", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    is_deeply($r->defines(), {'myarg' => "myval"}, "Defines are OK");
}

# Test for defines
{
    my $r = get_res(argv => ["--define", "myarg=myval", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    is_deeply($r->defines(), {'myarg' => "myval"}, "Defines are OK");
}

# Test for multiple defines
{
    my $r = get_res(argv => ["-Dmyarg=myval", "-Dsuper=par", "-D", "write=1", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    is_deeply($r->defines(), 
        {'myarg' => "myval", "super" => "par", "write" => "1"}, 
        "Multiple Defines are OK");
}

# Test for multiple defines
{
    my $r = get_res(argv => ["-Dmyarg=myval", "-Dsuper=par", "-D", "write=1", "--define=hi=there", "--define", "ext=.txt", "hello.ttml"]);
    # TEST
    is($r->input_filename(), "hello.ttml", "Input filename is OK");
    # TEST
    is_deeply($r->defines(), 
        {'myarg' => "myval", "super" => "par", "write" => "1", 
         "hi" => "there", "ext" => ".txt",
        }, 
        "Multiple Defines are OK");
}

