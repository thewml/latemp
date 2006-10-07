package HTML::Latemp::NavLinks::GenHtml::ArrowImages;

use strict;
use warnings;

use vars qw($nav_buttons_html);

use base 'HTML::Latemp::NavLinks::GenHtml';

__PACKAGE__->mk_accessors(qw(
    nav_links_obj
    root
    ));

=head1 NAME

HTML::Latemp::NavLinks::GenHtml::ArrowImages - A class to generate the image-based HTML of the navigation links.

=head1 SYNOPSIS

    my $obj = HTML::Latemp::NavLinks::GenHtml::Text->new(
        root => $path_to_root,
        nav_links_obj => $links,
        );

=head1 DESCRIPTION

This module generates text navigation links. C<root> is the relative path to 
the site's root directory. C<nav_links_obj> are the navigation links object 
as returned by L<HTML::Widgets::NavMenu> or something similar.

=head1 METHODS

=cut

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

    my $nav_links_obj = $self->nav_links_obj();
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
        if ($button->{'exists'} = exists($nav_links_obj->{$dir}))
        {
            $button->{'link_obj'} = $nav_links_obj->{$dir};
        }
    }
    
    my $vars =
    {
        'buttons' => \@buttons,
        'root' => $root,
        'with_accesskey' => $with_accesskey,
        'image_base' => $self->get_image_base(),
    };
    
    my $nav_links_template = <<'EOF';
[% USE HTML %]
[% FOREACH b = buttons %]
[% SET key = b.dir.substr(0, 1) %]
<li>
[% IF b.exists %]
<a href="[% HTML.escape(b.link_obj.direct_url()) %]" title="[% b.title %] (Alt+[% key FILTER upper %])"
[% IF with_accesskey %]
accesskey="[% key %]"
[% END %]
>[% END %]<img src="[% root %]/images/[% image_base %][% b.button %][% UNLESS b.exists %]-disabled[% END %].png"
alt="[% b.title %]" class="bless" />[% IF b.exists %]</a>
[% END %]
</li>
[% END %]
EOF
    
    my $nav_buttons_html = "";
    
    $template->process(\$nav_links_template, $vars, \$nav_buttons_html);
    return $nav_buttons_html;
}


=head2 $obj->get_image_base()

Can be overrided. Should return the base of the image filename of the module.

=cut

sub get_image_base
{
    my $self = shift;

    return "arrow-";
}

=head2 $obj->get_total_html()

Calculates and returns the final HTML.

=cut

sub get_total_html
{
    my $self = shift;

    return "<ul class=\"nav_links\">\n" .
        $self->_get_nav_buttons_html(@_) .
        "\n</ul>";
}

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

1;


