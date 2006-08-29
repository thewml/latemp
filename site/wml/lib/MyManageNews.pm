package MyManageNews;

use base 'Exporter';

our @EXPORT=(qw(get_news_manager));

use strict;
use warnings;

use HTML::Latemp::News;

my @news_items =
(
    (map 
        { 
            +{%$_, 
                'author' => "Shlomi Fish", 
                'category' => "Latemp", 
                'text' => "Hello"
            }
        }
        (
        {
            'title' => "First stable version of Latemp - 0.2.0",
            'id' => "0.2.0",
            'description' => q{Latemp version 0.2.0 was released. This is
            the first stable version of Latemp.},
            'date' => "2005-05-07",
        },
        {
            'title' => "Latemp Now Runs on Windows",
            'id' => "windows-portability",
            'description' => q{Latemp now runs on Microsoft Windows, after
            Website META Language was fixed to build on cygwin},
            'date' => "2006-06-14",
        },
        {
            'title' => "Version 0.4.0",
            'id' => "0.4.0",
            'description' => q{Latemp version 0.4.0 was released. This is
            a new stable version.},
            'date' => "2006-08-29",
        },
        )
    )
);

sub gen_news_manager
{
    return
        HTML::Latemp::News->new(
            'news_items' => \@news_items,
            'title' => "Latemp News",
            'link' => "http://web-cpan.berlios.de/latemp/",
            'language' => "en-US",
            'copyright' => "Copyright by Shlomi Fish, (c) 2005",
            'webmaster' => "Shlomi Fish <shlomif\@iglu.org.il>",
            'managing_editor' => "Shlomi Fish <shlomif\@iglu.org.il>",
            'description' => ("News of Latemp - the CMS for Static HTML " . 
                "web-sites."),
        );
}

# A singleton.
{
    my $news_manager;

    sub get_news_manager
    {
        if (!defined($news_manager))
        {
            $news_manager = gen_news_manager();
        }
        return $news_manager;
    }
}

1;
