package Template::Preprocessor::TTML;

use warnings;
use strict;

use base 'Template::Preprocessor::TTML::Base';

use Template;
use Template::Preprocessor::TTML::CmdLineProc;

__PACKAGE__->mk_accessors(qw(
    argv
));

=head1 NAME

Template::Preprocessor::TTML - The great new Template::Preprocessor::TTML!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Template::Preprocessor::TTML;

    my $foo = Template::Preprocessor::TTML->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 initialize()

Internal function for initializing the object.

=cut

sub initialize
{
    my $self = shift;
    my %args = (@_);
    $self->argv([@{$args{'argv'}}]);

    return 0;
}

=head2 run

Performs the processing.

=cut

sub run
{
    my $self = shift;
    my $cmd_line = Template::Preprocessor::TTML::CmdLineProc->new(argv => $self->argv());
    my $opts = $cmd_line->get_result();
    my $template = Template->new();

    $template->process($opts->input_filename(), $opts->defines())
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@iglu.org.il> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-template-preprocessor-ttml@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Template-Preprocessor-TTML>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Shlomi Fish, all rights reserved.

This program is released under the following license: BSD

=cut

1; # End of Template::Preprocessor::TTML
