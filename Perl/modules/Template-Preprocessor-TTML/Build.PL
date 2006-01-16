use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Template::Preprocessor::TTML',
    license             => 'BSD',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/Template/Preprocessor/TTML.pm',
    requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Template-Preprocessor-TTML-*' ],
    script_files => [ 'bin/ttml' ],
);

$builder->create_build_script();
