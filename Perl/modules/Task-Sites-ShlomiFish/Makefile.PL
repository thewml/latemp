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
        'App::XML::DocBook::Builder' => 0,
        'DateTime' => 0,
        'HTML::TokeParser::Simple' => 0,
        'IO::All' => 0,
        'String::ShellQuote' => 0,
        'Task::Latemp' => 0,
        'Template::Preprocessor::TTML' => 0,
        'WWW::Google::SiteMap' => 0,
        'XML::Grammar::Fortune' => '0.0107',
        'XML::Grammar::Fortune::Synd::App' => 0,
        'XML::Grammar::ProductsSyndication' => '0.0302',
        'XML::Grammar::Screenplay' => '0.0501',
        'XML::LibXML::XPathContext' => 0,
        'XML::LibXSLT' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Task-Sites-ShlomiFish-*' },
);
