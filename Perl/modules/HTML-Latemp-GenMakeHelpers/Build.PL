use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'HTML::Latemp::GenMakeHelpers',
    license             => 'BSD',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/HTML/Latemp/GenMakeHelpers.pm',
    requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'HTML-Latemp-GenMakeHelpers-*' ],
);

$builder->create_build_script();
