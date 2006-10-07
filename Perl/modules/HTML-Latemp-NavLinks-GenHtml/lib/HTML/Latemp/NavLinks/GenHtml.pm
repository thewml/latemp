package HTML::Latemp::NavLinks::GenHtml;

use warnings;
use strict;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw(
    nav_links_obj
    root
    ));

=head1 NAME

HTML::Latemp::NavLinks::GenHtml - A module to generate the HTML of the 
navigation links.

=cut

our $VERSION = '0.1.8';

=head1 SYNOPSIS

    package MyNavLinks;

    use base 'HTML::Latemp::NavLinks::GenHtml::ArrowImages';
    

=head1 METHODS

=head2 $specialised_class->new('param1' => $value1, 'param2' => $value2)

Initialises the object.

=cut

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->_init(@_);
    return $self;
}

sub _init
{
    my $self = shift;
    my (%args) = @_;

    $self->root($args{root});
    $self->nav_links_obj($args{nav_links_obj});

    return $self;
}

=head2 $obj->get_total_html()

Calculates the HTML and returns it.

=cut

sub _get_buttons
{
    my $self = shift;

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
        if ($button->{'exists'} = exists($self->nav_links_obj->{$dir}))
        {
            $button->{'link_obj'} = $self->nav_links_obj->{$dir};
        }
    }

    return \@buttons;
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@iglu.org.il> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-html-latemp-navlinks-genhtml@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-Latemp-NavLinks-GenHtml>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 Shlomi Fish, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of the MIT X11 license.

=cut

1; 

