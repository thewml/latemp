package HTML::Latemp::NavLinks::GenHtml;

use warnings;
use strict;

use 5.008;

use parent 'Class::Accessor';

__PACKAGE__->mk_accessors(
    qw(
        nav_links_obj
        root
        )
);

=head1 NAME

HTML::Latemp::NavLinks::GenHtml - A module to generate the HTML of the
navigation links.

=cut

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
    my $self  = {};
    bless $self, $class;
    $self->_init(@_);
    return $self;
}

sub _init
{
    my $self = shift;
    my (%args) = @_;

    $self->root( $args{root} );
    $self->nav_links_obj( $args{nav_links_obj} );

    return $self;
}

=head2 $obj->get_total_html()

Calculates the HTML and returns it.

=cut

sub _get_buttons
{
    my $self = shift;

    my @buttons = (
        {
            'dir'    => "prev",
            'button' => "left",
            'title'  => "Previous Page",
        },
        {
            'dir'    => "up",
            'button' => "up",
            'title'  => "Up in the Site",
        },
        {
            'dir'    => "next",
            'button' => "right",
            'title'  => "Next Page",
        },
    );

    foreach my $button (@buttons)
    {
        my $dir = $button->{'dir'};
        if ( $button->{'exists'} = exists( $self->nav_links_obj->{$dir} ) )
        {
            $button->{'link_obj'} = $self->nav_links_obj->{$dir};
        }
    }

    return \@buttons;
}

1;
