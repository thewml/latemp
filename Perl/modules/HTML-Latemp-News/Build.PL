use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder;

my $builder = Test::Run::Builder->new(
    module_name         => 'HTML::Latemp::News',
    license             => 'bsd',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/HTML/Latemp/News.pm',
    requires => {
        'Test::More' => 0,
        'Class::Accessor' => 0,
        'CGI' => 0,
        'XML::RSS' => 0,
        'perl' => '5.008',
        'strict' => 0,
        'warnings' => 0,
    },
    add_to_cleanup      => [ 'HTML-Latemp-News-*' ],
);

$builder->create_build_script();
