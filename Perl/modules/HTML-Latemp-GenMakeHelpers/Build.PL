use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder;

my $builder = Test::Run::Builder->new(
    module_name         => 'HTML::Latemp::GenMakeHelpers',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/HTML/Latemp/GenMakeHelpers.pm',
    configure_requires => {
        'Module::Build' => '0.36',
    },
    requires => {
        'Class::Accessor' => 0,
        'File::Find::Rule' => 0,
        'File::Basename' => 0,
        'warnings' => 0,
        'strict' => 0,
        'base' => 0,
        'perl' => '5.008',
    },
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'HTML-Latemp-GenMakeHelpers-*' ],
);

$builder->create_build_script();
