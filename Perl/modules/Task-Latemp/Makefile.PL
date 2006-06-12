use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Task::Latemp',
    AUTHOR              => 'Shlomi Fish <shlomif@iglu.org.il>',
    VERSION_FROM        => 'lib/Task/Latemp.pm',
    ABSTRACT_FROM       => 'lib/Task/Latemp.pm',
    PL_FILES            => {},
    PREREQ_PM => 
    {
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
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Task-Latemp-*' },
);
