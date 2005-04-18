package MyNavData;

my $hosts =
{
    'berlios' =>
    {
        'base_url' => "http://better-scm.berlios.de/",
    },
};

my $tree_contents =
{
    'host' => "berlios",
    'text' => "Better SCM",
    'title' => "Better SCM Initiative",
    'subs' =>
    [
        {
            'text' => "Home",
            'url' => "",
        },
        {
            'text' => "General Docs",
            'url' => "docs/",
            'title' => ("General Documents that don't Belong to " . 
                "Anywhere More Specific."),
            'subs' =>
            [
                {
                    'text' => "Evolution as a VCS User",
                    'url' => "docs/shlomif-evolution.html",
                    'title' => "Shlomi Fish' Evolution as a Revision Control User",
                },
                {
                    'text' => "Nice Tries, but...",
                    'url' => "docs/nice_trys.html",
                    'title' => ("Opinion on Several Attempts to Make an " .
                        "Incomplete Version Control System"),
                },
            ],
        },
        {
            'text' => "Alternatives",
            'url' => "alternatives/",
            'expand' => { 're' => ""},
            'subs' => 
            [
                {
                    'text' => "Arch",
                    'url' => "arch/",
                    'title'=> "A Distributed Version Control System",
                },
                {
                    'text' => "Subversion",
                    'url' => "subversion/",
                    'title' => ("A Version Control System that Aims to " . 
                        "Provide a Good Alternative to CVS"),
                },
            ],
        },
        {
            'text' => "Mailing List",
            'url' => "mailing-list.html",
        },
        {
            'text' => "IRC",
            'url' => "irc/",
            'title' => "Chat about Version Control using the Internet",
        },
        {
            'text' => "Links", 
            'url' => "links.html",
            'title' => "Links of Relevance",
        },
        {
            'separator' => 1,
            'skip' => 1,
        },
        {
            'url' => "site-map/",
            'text' => "Site Map",
            'title' => "A Page Concentrating all the Pages on the Site",
        },
        {
            'separator' => 1,
            'skip' => 1,
        },
        {
            'url' => "source/",
            'text' => "Site Sources",
            'title' => "How to Get and Manipulate the Source Code of this Site",
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
