use strict;
use warnings;
use Module::Build;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder;

my $builder = Test::Run::Builder->new(
    module_name         => 'HTML::Latemp::NavLinks::GenHtml',
    license             => 'bsd',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/HTML/Latemp/NavLinks/GenHtml.pm',
    requires => {
        'Class::Accessor' => 0,
        'strict' => 0,
        'Template' => 0,
        'warnings' => 0,
    },
    build_requires => {
        'Test::Differences' => 0,
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'HTML-Latemp-NavLinks-GenHtml-*' ],
);

$builder->create_build_script();
