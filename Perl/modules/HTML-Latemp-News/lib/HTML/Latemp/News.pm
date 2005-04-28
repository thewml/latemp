package HTML::Latemp::News;

use warnings;
use strict;

=head1 NAME

HTML::Latemp::News - News Maintenance Module for Latemp (and possibly other 
web frameworks)

=cut

our $VERSION = '0.1.2';

=head1 SYNOPSIS

    #!/usr/bin/perl

    use strict;
    use warnings;

    use MyManageNews;

    my @news_items = 
    (
        .
        .
        .
    );

    my $news_manager = 
        HTML::Latemp::News->new(
            'news_items' => \@news_items,
            'title' => "Better SCM News",
            'link' => "http://better-scm.berlios.de/",
            'language' => "en-US",
            'copyright' => "Copyright by Shlomi Fish, (c) 2005",
            'webmaster' => "Shlomi Fish <shlomif\@iglu.org.il>",
            'managing_editor' => "Shlomi Fish <shlomif\@iglu.org.il>",
            'description' => "News of the Better SCM Site - a site for Version Control and Source Configuration Management news and advocacy",
        );

    $news_manager->generate_rss_feed(
        'output_filename' => "dest/rss.xml"
    );

    1;
=cut

package HTML::Latemp::News::Base;

use base 'Class::Accessor';
use CGI;

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->initialize(@_);
    return $self;
}

package HTML::Latemp::News::Item;

our @ISA=(qw(HTML::Latemp::News::Base));

__PACKAGE__->mk_accessors(qw(index title id description author date 
    category text));

sub initialize
{
    my $self = shift;

    my (%args) = (@_);

    foreach my $k (keys(%args))
    {
        if (! $self->can($k))
        {
            die "Unknown property for HTML::Latemp::News::Item - \"$k\"!";
        }
        $self->set($k, $args{$k});
    }
}

package HTML::Latemp::News;

our @ISA=(qw(HTML::Latemp::News::Base));

__PACKAGE__->mk_accessors(qw(copyright description docs generator items 
    language link managing_editor rating title ttl webmaster));

use XML::RSS;

sub input_items
{
    my $self = shift;

    my $items = shift;

    return 
    [ 
        map 
        { $self->input_single_item($_, $items->[$_]) } 
        (0 .. $#$items)
    ];
}

sub input_single_item
{
    my $self = shift;
    my ($index, $inputted_item) = (@_);

    return 
        HTML::Latemp::News::Item->new(
            %$inputted_item,
            'index' => $index,
        );
}

sub initialize
{
    my $self = shift;

    my %args = (@_);

    my $items = $args{'news_items'};

    $self->items(
        $self->input_items($items)
    );

    $self->title($args{'title'});
    $self->link($args{'link'});
    $self->language($args{'language'});
    $self->rating($args{'rating'} || '(PICS-1.1 "http://www.classify.org/safesurf/" 1 r (SS~~000 1))');
    $self->copyright($args{'copyright'} || "");
    $self->docs($args{'docs'} || "http://blogs.law.harvard.edu/tech/rss");
    $self->ttl($args{'ttl'} || "360");
    $self->generator($args{'generator'} || "Perl and XML::RSS");
    $self->webmaster($args{'webmaster'});
    $self->managing_editor($args{'managing_editor'} || $self->webmaster());
    $self->description($args{'description'});

    return 0;
}

=head1 DESCRIPTION

This is a module that maintains news item for a web-site. It can generate
an RSS feed, as well as a news page, and an HTML newsbox, all from the same
data.

=head1 FUNCTION

=head2 HTML::Latemp::News->new(...)

This is the constructor for the news manager. It accepts the following named
parameters:

=over 8

=item 'news_items'

This is a reference to a list of news_items. See below.

=item 'title'

The title of the RSS feed.

=item 'link'

The link to the homepage of the site.

=item 'language'

The language of the text.

=item 'copyright'

The copyright notice of the text.

=item 'webmaster'

The Webmaster.

=item 'managing_editor'

The managing editor.

=item 'description'

A description of the news feed as will be put in the RSS feed.

=back

=head3 Format of the news_items

The news_items is a reference to an array, of which each element is a hash
reference. The hash may contain the following keys:

=over 8

=item 'title'

The title of the item.

=item 'id'

The ID of the item. This will also be used to calculate URLs.

=item 'description'

A text description explaining what the item is all about.

=item 'author'

The author of the item.

=item 'date'

A string representing the daet.

=item 'category'

The cateogry of the item.

=back

=cut

sub add_item_to_rss_feed
{
    my $self = shift;
    my %args = (@_);

    my $item = $args{'item'};
    my $rss_feed = $args{'feed'};

    my $item_url = $self->get_item_url($item);

    $rss_feed->add_item(
        'title' => $item->title(),
        'link' => $item_url,
        'permaLink' => $item_url,
        'enclosure' => { 'url' => $item_url, },
        'description' => $item->description(),
        'author' => $item->author(),
        'pubDate' => $item->date(),
        'category' => $item->category(),
    );
}

sub get_item_url
{
    my $self = shift;
    my $item = shift;
    return $self->link() . $self->get_item_rel_url($item);
}

sub get_item_rel_url
{
    my $self = shift;
    my $item = shift;
    return "news/" . $item->id() . "/";
}

sub get_items_to_include
{
    my $self = shift;
    my $args = shift;

    my $num_items_to_include = $args->{'num_items'} || 10;

    my $items = $self->items();

    if (@$items < $num_items_to_include)
    {
        $num_items_to_include = scalar(@$items);
    }

    return [ @$items[(-$num_items_to_include) .. (-1)] ];
}

sub generate_rss_feed
{
    my $self = shift;

    my %args = (@_);

    my $rss_feed = XML::RSS->new('version' => "2.0");
    $rss_feed->channel(
        'title' => $self->title(),
        'link' => $self->link(),
        'language' => $self->language(),
        'description' => $self->description(),
        'rating' => $self->rating(),
        'copyright' => $self->copyright(),
        'pubDate' => (scalar(localtime())),
        'lastBuildDate' => (scalar(localtime())),
        'docs' => $self->docs(),
        'ttl' => $self->ttl(),
        'generator' => $self->generator(),
        'managingEditor' => $self->managing_editor(),
        'webMaster' => $self->webmaster(),
    );

    foreach my $single_item (@{$self->get_items_to_include(\%args)})
    {
        $self->add_item_to_rss_feed(
            'item' => $single_item,
            'feed' => $rss_feed,
        );
    }

    my $filename = $args{'output_filename'} || "rss.xml";
    
    $rss_feed->save($filename);
}

=head2 $news_manager->generate_rss_feed('output_filename' => "rss.xml")

This generates an RSS feed. It accepts two named arguments. 
C<'output_filename'> is the name of the RSS file to write to. C<'num_items'>
is the number of items to include, which defaults to 10.

=cut

sub get_navmenu_items
{
    my $self = shift;
    my %args = (@_);

    my @ret;

    foreach my $single_item (reverse(@{$self->get_items_to_include(\%args)}))
    {
        push @ret,
            {
                'text' => $single_item->title(),
                'url' => $self->get_item_rel_url($single_item),
            };
    }
    return \@ret;
}

=head2 $news_manager->get_navmenu_items('num_items' => 5)

This generates navigation menu items for input to the navigation menu of
L<HTML::Widgets::NavMenu>. It accepts a named argument C<'num_items'> which
defaults to 10.

=cut

sub format_news_page_item
{
    my $self = shift;
    my (%args) = (@_);

    my $item = $args{'item'};

    return "<h3><a href=\"" . $item->id() . "/\">" . 
        CGI::escapeHTML($item->title()) . "</a></h3>\n" .
        "<p>\n" . $item->description() . "\n</p>\n";
}

sub get_news_page_entries
{
    my $self = shift;
    my %args = (@_);

    my $html = "";

    foreach my $single_item (reverse(@{$self->get_items_to_include(\%args)}))
    {
        $html .= $self->format_news_page_item('item' => $single_item);
    }
    return $html;
}

=head2 $news_manager->get_news_page_entries('num_items' => 5)

This generates HTML for the news page. 

=cut

sub get_news_box
{
    my $self = shift;
    my (%args) = (@_);

    my $html = "";

    $html .= qq{<div class="news">\n};
    $html .= qq{<h3>News</h3>\n};
    $html .= qq{<ul>\n};
    foreach my $item (reverse(@{$self->get_items_to_include(\%args)}))
    {
        $html .= "<li><a href=\"" . 
            $self->get_item_rel_url($item) . "\">" . 
        CGI::escapeHTML($item->title()) . "</a></li>\n";
    }
    $html .= qq{<li><a href="./news/">More&hellip;</a></li>};
    $html .= qq{</ul>\n};
    $html .= qq{</div>\n};
    return $html;
}

=head2 $news_manager->get_news_box('num_items' => 5)

This generates an HTML news box with the recent headlines.

=cut

1;

__END__

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@iglu.org.il> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-html-latemp-news@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-Latemp-News>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SEE ALSO

L<XML::RSS>, L<HTML::Widgets::NavMenu>.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 Shlomi Fish, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of the MIT X11 license.

=cut
