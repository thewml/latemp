use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Task::Latemp',
    license             => 'mit',
    dist_author         => q{Shlomi Fish <shlomif@shlomifish.org>},
    dist_version_from   => 'lib/Task/Latemp.pm',
    configure_requires => {
        'Module::Build' => '0.36',
    },
    requires => {
        'CGI' => 0,
        'Class::Accessor' => 0,
        'Data::Dumper' => 0,
        'File::Basename' => 0,
        'File::Find::Rule' => 0,
        'File::Path' => 0,
        'Getopt::Long' => 0,
        'HTML::Latemp::GenMakeHelpers' => 0,
        'HTML::Latemp::NavLinks::GenHtml::Text' => 0,
        'HTML::Latemp::News' => 0,
        'HTML::Widgets::NavMenu' => 0,
        'Pod::Usage' => 0,
        'Template' => 0,
        'YAML' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Task-Latemp-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
