#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Template::Preprocessor::TTML' );
}

diag( "Testing Template::Preprocessor::TTML $Template::Preprocessor::TTML::VERSION, Perl $], $^X" );
