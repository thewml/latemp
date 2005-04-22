#!/usr/bin/perl

use strict;
use warnings;

use Pod::Xhtml;

my $parser = Pod::Xhtml->new(FragmentOnly => 1);
open I, "<", "latemp-ref.pod";
open O, ">", "latemp-ref.html";
print O <<"EOF";
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US" lang="en-US">
<head>
<title>The Latemp Reference Document</title>
<style type="text/css">
body { background-color : white; }
tt, pre { color : BlueViolet; }
a:hover { background-color : palegreen; }
h1 { background-color : #96dd9a; }
h2 { background-color : #ede550; }
h3 { background-color : #8080FF; }
h1, h2, h3
{
   padding-left: 0.2em;
   padding-bottom: 0.1em;
}
p, pre, ul, ol
{
   margin-left: 1em;
}
</style>
</head>
<body>
EOF

$parser->parse_from_filehandle(\*I, \*O);
close(I);
print O "</body>\n</html>\n";
close(O);

1;
