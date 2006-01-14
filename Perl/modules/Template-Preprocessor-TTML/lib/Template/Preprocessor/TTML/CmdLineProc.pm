package Template::Preprocessor::TTML::CmdLineProc;

use strict;
use warnings;

=head1 NAME

Template::Preprocessor::TTML::CmdLineProc - Process command line arguments

=cut

use base 'Template::Preprocessor::TTML::Base';

package Template::Preprocessor::TTML::CmdLineProc::Results;

use base 'Template::Preprocessor::TTML::Base';

__PACKAGE__->mk_accessors(qw(
    input_filename
    output_to_stdout
    output_filename
));

sub initialize
{
    my $self = shift;
    $self->output_to_stdout(1);
    return 0;
}

package Template::Preprocessor::TTML::CmdLineProc;

__PACKAGE__->mk_accessors(qw(
    argv
    result
));

=head1 SYNOPSIS

    my $obj = 
        Template::Preprocessor::TTML::CmdLineProc->new(
            argv => [@ARGV],
        );
    my $result = $obj->get_result();

=head1 DESCRIPTION

The constructor accepts argv as argument, and is destructible to it. It
returns a results object.

=head1 FUNCTIONS

=head2 $cmd_line->initialize(@_)

This is an internal function that initializes the arguments of the object.

=cut

sub initialize
{
    my $self = shift;
    my (%args) = @_;
    $self->argv($args{argv});

    $self->result(Template::Preprocessor::TTML::CmdLineProc::Results->new());
    return 0;
}

sub _get_next_arg
{
    my $self = shift;
    return shift(@{$self->argv()});
}

sub _no_args_left
{
    my $self = shift;
    return (@{$self->argv()} == 0);
}

sub _handle_long_option
{
    my $self = shift;
    my $arg = shift;
    if ($arg eq "--")
    {
        return $self->_handle_no_more_options();
    }
    die "Unknown option!";
}

sub _handle_no_more_options
{
    my $self = shift;
    $self->_assign_filename($self->_get_next_arg());
}

sub _get_standalone_short_opts_map
{
    return
    {
        "o" => "output",
    };
}

sub _handle_short_option
{
    my $self = shift;
    my $arg_orig = shift;

    my $arg = $arg_orig;
    $arg =~ s!^-!!;
    my $map = $self->_get_standalone_short_opts_map();
    if (exists($map->{$arg}))
    {
        return $self->can("_process_" . $map->{$arg} . "_short_opt")->(
            $self, $arg
        );
    }
    die "Unknown option \"$arg_orig\"!";
}

sub _process_output_short_opt
{
    my $self = shift;
    if ($self->_no_args_left())
    {
        die "Output filename should be specified after \"-o\"";
    }
    $self->result()->output_to_stdout(0);
    $self->result()->output_filename($self->_get_next_arg());
}

sub _assign_filename
{
    my ($self, $arg) = @_;
    if (! $self->_no_args_left())
    {
        die "Junk after filename";
    }
    else
    {
        $self->result()->input_filename($arg);
    }
}

=head2 $cmd_line->get_result()

This function calculates the results from the arguments. If something wrong
it will throw an exception. It should be called only once.

=cut

sub get_result
{
    my $self = shift;

    if ($self->_no_args_left())
    {
        die "Incorrect usage: you need to specify a filename";
    }
    
    while (defined(my $arg = $self->_get_next_arg()))
    {
        if ($arg =~ m{^-})
        {
            if ($arg =~ m{^--})
            {
                $self->_handle_long_option($arg);
            }
            else
            {
                $self->_handle_short_option($arg);
            }
        }
        else
        {
            $self->_assign_filename($arg);
        }
    }
    return $self->result();
}

1;
