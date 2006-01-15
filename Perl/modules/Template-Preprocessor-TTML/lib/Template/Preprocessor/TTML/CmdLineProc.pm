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
    defines
    include_files
    include_path
    input_filename
    output_to_stdout
    output_filename
    run_mode
));

sub initialize
{
    my $self = shift;
    $self->output_to_stdout(1);
    $self->include_path([]);
    $self->defines(+{});
    $self->include_files([]);
    $self->run_mode("regular");
    return 0;
}

sub add_to_inc
{
    my $self = shift;
    my $path = shift;
    push @{$self->include_path()}, $path;
}

sub add_to_defs
{
    my ($self, $k, $v) = @_;
    $self->defines()->{$k} = $v;
}

sub add_include_file
{
    my $self = shift;
    my $path = shift;
    push @{$self->include_files()}, $path;
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

sub _get_run_mode_opts_map
{
    return
    {
        "--version" => "version",
        "-V" => "version",
        "--help" => "help",
        "-h" => "help",
    };
}

sub _get_arged_longs_opts_map
{
    return
    {
        "include" => "_process_include_path_opt",
        "includefile" => "_process_add_includefile_opt",
        "define" => "_process_define_opt",
    };
}

sub _handle_middle_run_mode_opt
{
    my ($self, $arg) = @_;
    if (exists($self->_get_run_mode_opts_map()->{$arg}))
    {
        die "Option \"$arg\" was specified in the middle of the command line. It should be a standalone option.";
    }
}

sub _handle_long_option
{
    my $self = shift;
    my $arg_orig = shift;
    if ($arg_orig eq "--")
    {
        return $self->_handle_no_more_options();
    }
    $self->_handle_middle_run_mode_opt($arg_orig);
    my $arg = $arg_orig;
    $arg =~ s!^--!!;
    my $map = $self->_get_arged_longs_opts_map();
    $arg =~ m{^([^=]*)};
    my $option = $1;
    if (exists($map->{$option}))
    {
        my $sub = $self->can($map->{$option});
        if (length($arg) eq length($option))
        {
            if ($self->_no_args_left())
            {
                die "An argument should be specified after \"$arg_orig\"";
            }
            return $sub->(
               $self, $self->_get_next_arg()
            );
        }
        else
        {
            return $sub->(
                $self, substr($arg, length($option)+1)
            );
        }
    }
    die "Unknown option!";
}

sub _handle_no_more_options
{
    my $self = shift;
    $self->_assign_filename($self->_get_next_arg());
}

sub _get_arged_short_opts_map
{
    return
    {
        "o" => "_process_output_short_opt",
        "I" => "_process_include_path_opt",
        "D" => "_process_define_opt",
    };
}

sub _handle_short_option
{
    my $self = shift;
    my $arg_orig = shift;

    $self->_handle_middle_run_mode_opt($arg_orig);

    my $arg = $arg_orig;
    $arg =~ s!^-!!;
    my $map = $self->_get_arged_short_opts_map();
    my $first_char = substr($arg, 0, 1);
    if (exists($map->{$first_char}))
    {
        my $sub = $self->can($map->{$first_char});
        if (length($arg) > 1)
        {
            return $sub->(
                $self, substr($arg, 1)
            );
        }
        else
        {
            if ($self->_no_args_left())
            {
                die "An argument should be specified after \"$arg_orig\"";
            }
            return $sub->(
                $self, $self->_get_next_arg()
            );
        }
    }
    die "Unknown option \"$arg_orig\"!";
}

sub _process_output_short_opt
{
    my $self = shift;
    my $filename = shift;
    $self->result()->output_to_stdout(0);
    $self->result()->output_filename($filename);
}

sub _process_include_path_opt
{
    my $self = shift;
    my $path = shift;
    $self->result()->add_to_inc($path);
}

sub _process_add_includefile_opt
{
    my $self = shift;
    my $file = shift;
    $self->result()->add_include_file($file);
}

sub _process_define_opt
{
    my $self = shift;
    my $def = shift;
    if ($def !~ m{^([^=]+)=(.*)$})
    {
        die "Variable definition should contain a \"=\", but instead it is \"$def\"!";
    }
    my ($var, $value) = ($1, $2);
    $self->result()->add_to_defs($var, $value);
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

sub _handle_exclusive_run_mode_opt
{
    my $self = shift;
    if ((@{$self->argv()} == 1))
    {
        my $opt = $self->argv()->[0];
        if (exists($self->_get_run_mode_opts_map()->{$opt}))
        {
            $self->result()->run_mode(
                $self->_get_run_mode_opts_map()->{$opt}
            );
            return 1;
        }
    }
    return 0;
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

    if (! $self->_handle_exclusive_run_mode_opt())
    {
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
    }
    return $self->result();
}

1;
