use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'HTML::Latemp::NavLinks::GenHtml',
    license             => 'bsd',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/HTML/Latemp/NavLinks/GenHtml.pm',
    requires => {
        'Test::More' => 0,
        'Template' => 0,
        'Class::Accessor' => 0,
    },
    add_to_cleanup      => [ 'HTML-Latemp-NavLinks-GenHtml-*' ],
);

$builder->create_build_script();
