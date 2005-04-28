use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'HTML::Latemp::News',
    license             => 'BSD',
    dist_author         => 'Shlomi Fish <shlomif@iglu.org.il>',
    dist_version_from   => 'lib/HTML/Latemp/News.pm',
    requires => {
        'Test::More' => 0,
        'Class::Accessor' => 0,
        'CGI' => 0,
        'XML::RSS' => 0,
    },
    add_to_cleanup      => [ 'HTML-Latemp-News-*' ],
);

$builder->create_build_script();
