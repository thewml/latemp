package MyNavData;

use strict;
use warnings;

use MyManageNews;

my $hosts =
{
    'mysite' =>
    {
        'base_url' => "http://web-cpan.berlios.de/latemp/",
    },
};

my $news_manager = get_news_manager();

my $tree_contents =
{
    'host' => "mysite",
    'text' => "Latemp",
    'title' => "The Latemp Content Management System",
    'subs' =>
    [
        {
            'text' => "Home",
            'url' => "",
        },
        {
            'text' => "About",
            'url' => "about/",
        },
        {
            'text' => "News",
            'url' => "news/",
            'subs' =>
            [
                @{$news_manager->get_navmenu_items('num_items' => 5)},
            ],
        },        
        {
            'text' => "Download",
            'url' => "download/",
            'title' => "How to Download the Software.",
        },
        {
            'text' => "Documentation",
            'url' => "docs/",
        },
        {
            'text' => "Examples",
            'url' => "examples/",
            'title' => "Complete Example Sites",
        },
        {
            'text' => "Graphics",
            'url' => "graphics/",
            'title' => "Latemp Buttons, Logos and other Graphics",
        },
        {
            'separator' => 1,
            'skip' => 1,
        },
        {
            'text' => "Links",
            'url' => "links/",
        },
    ],
};

sub get_params
{
    return 
        (
            'hosts' => $hosts,
            'tree_contents' => $tree_contents,
        );
}

1;
