#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use File::Path;
use Pod::Usage;

my $theme;
my $project_dir;
my $host = "mysite";
my $author = "John Smith";
my $language = "en-US";
my $encoding = "utf-8";
my $remote_path;

my $help = 0;
my $man = 0;

GetOptions(
    "theme=s" => \$theme,
    "dir=s" => \$project_dir,
    "host=s", => \$host,
    "author=s" => \$author,
    "lang=s" => \$language,
    "encoding=s" => \$encoding,
    "remote-path=s" => \$remote_path,
    'help|h|?' => \$help, 
    'man' => \$man
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

my $host_uc = uc($host);

if (!defined($theme))
{
    die "You must specify a theme.";
}

if (!defined($project_dir))
{
    die "You must specify a project directory.";
}

if (!defined($remote_path))
{
    die "You must specify a remote path.";
}

mkpath($project_dir, 0, 0755);

# If mkpath did not suceeed it will throw an exception

my $current_file;
$current_file = "$project_dir/gen-helpers.pl";
open O, ">", $current_file;
print O <<"EOF";
#!/usr/bin/perl

use strict;
use warnings;

use HTML::Latemp::GenMakeHelpers;

my \$generator = 
    HTML::Latemp::GenMakeHelpers->new(
        'hosts' =>
        [ 
            map 
            { 
                +{ 'id' => \$_, 'source_dir' => "src/\$_", 
                   'dest_dir' => "\\\$(ALL_DEST_BASE)/\$_",
               }, 
            } 
            (qw(common $host))
        ]
    );

\$generator->process_all();

1;
EOF

close(O);


chmod 0755, $current_file;

open O, ">", "$project_dir/gen-feeds.pl";
print O <<'EOF';
#!/usr/bin/perl

use strict;
use warnings;

use MyManageNews;
use Getopt::Long;

my $rss2_out = "dest/rss.xml";
GetOptions ("rss2-out=s" => \$rss2_out);

my $news_manager = get_news_manager();

$news_manager->generate_rss_feed(
    'output_filename' => $rss2_out,
);

1;
EOF
close(O);

$current_file = "$project_dir/template.wml";

open O, ">", $current_file;
print O <<"EOF";
# Read all the latemp macros 
#include "latemp/latemp-prelude.wml"

# You can put some customizations here

<set-var latemp_with_head_meta_tags="1" />

# Actually start the page template.
#include "latemp/latemp-driver.wml"
<latemp_lang "$language" />
<latemp_encoding "$encoding" />
<latemp_common_keywords "" />
<latemp_author "$author" />

<latemp_webmaster>
</latemp_webmaster>

<latemp_license>
</latemp_license>

<latemp_affiliations_buttons>
</latemp_affiliations_buttons>
EOF

close(O);

$current_file = "$project_dir/Makefile";

open O, ">", $current_file;
print O <<"EOF";

RSYNC = rsync --progress --verbose --rsh=ssh

ALL_DEST_BASE = dest

DOCS_COMMON_DEPS = template.wml lib/MyNavData.pm lib/MyManageNews.pm

WML_FLAGS = -DLATEMP_THEME=$theme

LATEMP_WML_FLAGS =\$(shell latemp-config --wml-flags)

WML_FLAGS += --passoption=2,-X3074 --passoption=3,-I../../lib/ \\
	--passoption=3,-w \$(LATEMP_WML_FLAGS) -I../../ -DROOT~. \\
    -I../../lib/

all: dummy

%.show:
	\@echo "\$* = \$(\$*)"

include include.mak
include rules.mak

# Add news_feeds to this target if you want to generate an RSS feed.
dummy : latemp_targets

RSS_FEED = \$(${host_uc}_DEST)/rss.xml

news_feeds: \$(RSS_FEED)

\$(RSS_FEED): gen-feeds.pl lib/MyManageNews.pm
	perl -Ilib gen-feeds.pl --rss2-out="\$\@"

.PHONY: 

upload: all
	cd \$(ALL_DEST_BASE)/$host && \\
	\$(RSYNC) -r * $remote_path
EOF

close(O);

mkpath("$project_dir/lib", 0, 0775);

$current_file = "$project_dir/lib/MyNavData.pm";

open O, ">", $current_file;
print O <<"EOF";
package MyNavData;

use strict;
use warnings;

use MyManageNews;

my \$hosts =
{
    '$host' =>
    {
        'base_url' => "http://myhost.mydomain/",
    },
};

my \$news_manager = get_news_manager();

sub get_news_category
{
    my \$items = \$news_manager->get_navmenu_items('num_items' => 5);
    if (\@\$items)
    {
        return
        {
            'text' => "News",
            'url' => "news/",
            'subs' =>
            [
                \@\$items,
            ],
        },
    }
    else
    {
        return ();
    }
}

my \$tree_contents =
{
    'host' => "$host",
    'text' => "My Site",
    'title' => "My Site",
    'subs' =>
    [
        {
            'text' => "Home",
            'url' => "",
        },
        {
            'text' => "About",
            'url' => "about.html",
        },
        get_news_category(),
        {
            'text' => "Links",
            'url' => "links.html",
        },
    ],
};

sub get_params
{
    return
        (
            'hosts' => \$hosts,
            'tree_contents' => \$tree_contents,
        );
}

1;
EOF

close(O);

open O, ">", "$project_dir/lib/MyManageNews.pm";
print O <<"EOF";
package MyManageNews;

use base 'Exporter';

our \@EXPORT=(qw(get_news_manager));

use strict;
use warnings;

use HTML::Latemp::News;

my \@news_items =
(
    (map 
        { 
            +{\%\$_, 
                'author' => "$author", 
                'category' => "My Site Category", 
            }
        }
        (
            # TODO: Fill Items Here.
        ),
    )
);

sub gen_news_manager
{
    return
        HTML::Latemp::News->new(
            'news_items' => \\\@news_items,
            'title' => "My Site News",
            'link' => "http://www.link-to-my-site.tld/",
            'language' => "en-US",
            'copyright' => "Copyright by $author, (c) 2005",
            'webmaster' => "$author <author\\\@domain.org>",
            'managing_editor' => "$author <author\\\@domain.org>",
            'description' => "News of the My Site",
        );
}

# A singleton.
{
    my \$news_manager;

    sub get_news_manager
    {
        if (!defined(\$news_manager))
        {
            \$news_manager = gen_news_manager();
        }
        return \$news_manager;
    }
}

1;
EOF
close(O);

open O, ">", "$project_dir/lib/MyNavLinks.pm";
print O <<'EOF';
package MyNavLinks;

use base 'HTML::Latemp::NavLinks::GenHtml::Text';

1;
EOF

close(O);

mkpath("$project_dir/src/common", 0, 0755);
mkpath("$project_dir/src/$host", 0, 0755);
open O, ">", "$project_dir/src/common/style.css";
print O <<"EOF";
/*
    CSS Stylesheet for better-scm.berlios.de
    Copyright (c) Shlomi Fish, 2003-2005
    Feel free to use, modify and re-distribute under the terms of the 
    MIT X11 License (http://www.opensource.org/licenses/mit-license.php)

    \$Id: style.css 175 2005-04-17 07:43:41Z shlomif \$
*/

a:hover { color : red }

.navbar {
    float : left;
    background-color : #C5CAE2;
    width : 200px;
    padding-left : 0.5em;
    padding-top : 0.5em;
}

.main
{
    padding-left : 1em;
    padding-bottom : 1em;
    padding-top : 0em;
    padding-right: 1em;
    margin-left : 220px;
    margin-top: 1em;
    margin-right: 1em;
    background-color : white;
    border: thin solid black;
}

p.desc { margin-left : 3em }
h2 
{ 
    background-color: #FFEE00  
}
h2, h3, h4
{
    padding-left: 0.3em;
}
.main p
{
    padding-left : 1em;
}
.link { background : transparent; }
/* Opera has a very wide default for margin-left, which causes the navbar
   to be misrendered. This rule fixes it.
   */
.navbar ul
{
    margin-left: 0;
}
ul.navbarmain
{ 
    padding-left : 1em; 
    font-size: 80%;
    font-family: sans-serif;
}
ul.navbarnested 
{ 
    padding-left : 0em ; 
    margin-left : 2em;
}
.note 
{ 
    border-color : black; 
    border-style : double;
    padding : 0.5em;
    background-color : #98FB98; /* PaleGreen */
}
.note h2
{
   background: transparent;
}
ul.my li
{
    padding-bottom: 0.5em;
}
.righty
{
   float: right;
   text-align: center;
   font-size: 80%;
   width: 30%;
}
.righty img
{
    border : 0;
}
.foot_left
{
    float : left;
}
.webmaster
{
    margin-bottom: 0em;
}
.vcs
{    
    margin-top: 0.5em;
    clear: left;
}
.vcs tt
{
    font-size: 83%;
}

.center
{
    text-align : center;
}
.nav_links
{
    text-align: center;
    padding-left : 0em;
    padding-top : 0em;
}
.nav_links li
{
    display: inline;
    list-style-type: none;
    padding-right: 0.2em;
    padding-top: 0em;
}
.leading_path
{
    padding-left: 0.5em;
    padding-top: 0.2em;
    padding-bottom: 0.2em;
    background-color : #40C040;
    /* background-color: #FF7070; */
    margin-bottom : 0.2em;
    font-size: 85%;
}
.leading_path :hover
{
    color : yellow;
}
.footer {
    clear : both;
    margin-right : 30px;
    padding-top: 0.5em;
}
/* Workaround to get the <hr /> element at the bottom to properly display 
   with Konqueror 3.3.x
   */
.footer hr
{
    width:100%;
    clear:both;
}
tt { color : #8a2be2; }
pre
{
    padding-left: 1em;
    padding-right: 1em;
    padding-bottom: 0.5em;
    padding-top: 0.5em;
    background-color: #FF8080;
    border-width : thin;
    border-color: #004000;
    border-style: solid;
}
/* Border-less */
.bless
{
    border : none;
}
EOF

close(O);

open O, ">", "$project_dir/src/common/print.css";
print O <<"EOF";
.navbar 
{
    display: none;
}
.main
{
    background-color : white;
}
p.desc { margin-left : 3em }
.note 
{ 
    border-color : black; 
    border-style : double;
    padding : 0.5em;
}
.righty
{
   float: right;
   text-align: center;
   font-size: 80%;
   width: 30%;
}
.righty img
{
    border : 0;
}
.webmaster
{
    float : left;
}
.center
{
    text-align : center;
}
.leading_path
{
    padding-left: 0.5em;
    padding-top: 0.2em;
    padding-bottom: 0.2em;
    margin-bottom : 0.2em;
    border-width : thin;
    border-color : black;
    border-style : groove;
    font-size: 85%;
}
.footer {
    clear : both;
    margin-right : 30px;
    padding-top: 0.5em;
}
tt { font-weight: bold; }
pre
{
    padding-left: 1em;
    padding-right: 1em;
    padding-bottom: 0.5em;
    padding-top: 0.5em;
    border-width : thin;
    border-color: #004000;
    border-style: solid;
}
/* Border-less */
.bless
{
    border : none;
}
EOF
close(O);

open O, ">", "$project_dir/src/$host/index.html.wml";
print O <<"EOF";
#include "template.wml"

<latemp_subject "My Subject" />
<latemp_version_control_id "\$Id\$" />

EOF

close(O);

open O, ">", "$project_dir/src/$host/about.html.wml";
print O <<"EOF";
#include "template.wml"

<latemp_subject "About this site" />
<latemp_version_control_id "\$Id\$" />

<p>
Here you should put information about this site. A good idea may be moving
it to about/index.html.wml.
</p>

EOF

close(O);

open O, ">", "$project_dir/src/$host/links.html.wml";
print O <<"EOF";
#include "template.wml"

<latemp_subject "Links" />
<latemp_version_control_id "\$Id\$" />

<h2>Latemp Related Links</h2>

<ul>
<li>
<a href="http://web-cpan.berlios.de/latemp/">The Latemp Homepage</a>
</li>
<li>
<a href="http://thewml.org/">Web Meta Language</a>
</li>
</ul>
EOF

close(O);

open O, ">", "$project_dir/unchanged";
print O "";
close(O);

print STDERR "Successfully Created Latemp Project.\n";

__END__

=head1 NAME

latemp-setup - Set up a Latemp Project

=head1 SYNOPSIS

B<latemp-setup> --theme=[Theme] --dir=[Dir] --host=[Host] [--author=[Author]]
[--lang=[Language]] [--encoding=[Encoding]] [--remote-path=[Remote Path]]

Or alternatively

latemp-setup --help

Or

latemp-setup --man

=head1 DESCRIPTION

This program sets up a working skeleton for a Latemp project. The options
I<--theme>, I<--dir> and I<--remote-path> are required.

=head1 OPTIONS

=over 8

=item B<--help> B<-h> B<-?>

Display a help message on the screen.

=item B<--man>

Invoke the UNIX B<man> command to display the man-page of this program.

=item B<--theme>

Chooses a Latemp theme to use. A Latemp theme controls the HTML layout of the
page.

=item B<--dir>

This is a dir in which to create the project. It would be created if it does 
not exist.

=item B<--remote-path>

This is the remote path to upload the final files to (using rsync).

=item B<--author>

This specifies the author of the files. It defaults to "John Smith"

=item B<--lang>

This chooses the language with which to mark the HTML.

=item B<--encoding>

This specifies an encoding to use ("utf-8", "iso-8859-8", etc.)

=head1 SEE ALSO

B<The Latemp Homepage>: 

http://web-cpan.berlios.de/latemp/

=head1 AUTHOR

Shlomi Fish <shlomif@iglu.org.il>

=cut


