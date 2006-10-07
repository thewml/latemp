package HTML::Latemp::NavLinks::GenHtml::Text;

use strict;
use warnings;

use vars qw($nav_buttons_html);

use base 'HTML::Latemp::NavLinks::GenHtml';

=head1 NAME

HTML::Latemp::NavLinks::GenHtml::Text - A class to generate the text HTML of
the navigation links.

=head1 SYNOPSIS

    my $obj = HTML::Latemp::NavLinks::GenHtml::Text->new(
        root => $path_to_root,
        nav_links => $links,
        );

=head1 DESCRIPTION

This module generates text navigation links. C<root> is the relative path to 
the site's root directory. C<nav_links> are the navigation links hash 
as returned by L<HTML::Widgets::NavMenu> or something similar.

=head1 METHODS

=head2 $obj->get_total_html()

Calculates and returns the final HTML.

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@iglu.org.il> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-html-latemp-navlinks-genhtml@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-Latemp-NavLinks-GenHtml>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2005 Shlomi Fish, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of the MIT X11 license.

=cut

__PACKAGE__->mk_accessors(qw(
    nav_links
    root
    ));

use Template;

# load Template::Stash to make method tables visible
use Template::Stash;

# Define a method to return a substring.
$Template::Stash::SCALAR_OPS->{ 'substr' } = sub {
    return substr($_[0], $_[1], $_[2]);
};

sub _get_nav_buttons_html
{
    my $self = shift;

    my (%args) = (@_);
    
    my $with_accesskey = $args{'with_accesskey'};

    my $nav_links = $self->nav_links();
    my $root = $self->root();    

    my $template = 
        Template->new(
        {
            'POST_CHOMP' => 1,
        }
        );

    my @buttons =
    (
        { 
            'dir' => "prev", 
            'button' => "left", 
            'title' => "Previous Page",
        },
        { 
            'dir' => "up", 
            'button' => "up", 
            'title' => "Up in the Site",
        },
        {
            'dir' => "next", 
            'button' => "right", 
            'title' => "Next Page",
        },
    );

    foreach my $button (@buttons)
    {
        my $dir = $button->{'dir'};
        if ($button->{'exists'} = exists($nav_links->{$dir}))
        {
            $button->{'link'} = $nav_links->{$dir};
        }
    }
    
    my $vars = 
    {
        'buttons' => \@buttons,
        'root' => $root,
        'with_accesskey' => $with_accesskey,
    };
    
    my $nav_links_template = <<'EOF';
[% USE HTML %]
[% FOREACH b = buttons %]
[% SET key = b.dir.substr(0, 1) %]
<li>[
[% IF b.exists %]
<a href="[% HTML.escape(b.link) %]" title="[% b.title %] (Alt+[% key FILTER upper %])"
[% IF with_accesskey %]
accesskey="[% key %]"
[% END %]
>[% END %] [% b.dir %] [% IF b.exists %]</a>
[% END %]
]</li>
[% END %]
EOF
    
    my $nav_buttons_html = "";
    
    $template->process(\$nav_links_template, $vars, \$nav_buttons_html);
    return $nav_buttons_html;
}

sub get_total_html
{
    my $self = shift;

    return "<ul class=\"nav_links\">\n" .
        $self->_get_nav_buttons_html(@_) .
        "\n</ul>";
}

1;

