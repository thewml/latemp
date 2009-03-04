use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Task::Sites::ShlomiFish',
    AUTHOR              => 'Shlomi Fish <shlomif@iglu.org.il>',
    VERSION_FROM        => 'lib/Task/Sites/ShlomiFish.pm',
    ABSTRACT_FROM       => 'lib/Task/Sites/ShlomiFish.pm',
    PL_FILES            => {},
    PREREQ_PM => 
    {
        'IO::All' => 0,
        'Template::Preprocessor::TTML' => 0,
        'DateTime' => 0,
        'HTML::TokeParser::Simple' => 0,
        'XML::LibXSLT' => 0,
        'WWW::Google::SiteMap' => 0,
        'XML::Grammar::ProductsSyndication' => '0.02',
        'Task::Latemp' => 0,
        'XML::LibXML::XPathContext' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Task-Latemp-*' },
);
