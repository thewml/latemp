package HTML::Latemp::GenMakeHelpers;

use strict;
use warnings;
use autodie;
use 5.014;

package HTML::Latemp::GenMakeHelpers::Base;

sub new
{
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    $self->initialize(@_);
    return $self;
}

package HTML::Latemp::GenMakeHelpers::HostEntry;

our @ISA = (qw(HTML::Latemp::GenMakeHelpers::Base));

use Class::XSAccessor accessors =>
    { 'dest_dir' => 'dest_dir', 'id' => 'id', 'source_dir' => 'source_dir', };

sub initialize
{
    my $self = shift;
    my %args = (@_);

    $self->id( $args{'id'} );
    $self->source_dir( $args{'source_dir'} );
    $self->dest_dir( $args{'dest_dir'} );
}

package HTML::Latemp::GenMakeHelpers::Error;

our @ISA = (qw(HTML::Latemp::GenMakeHelpers::Base));

package HTML::Latemp::GenMakeHelpers::Error::UncategorizedFile;

our @ISA = (qw(HTML::Latemp::GenMakeHelpers::Error));

use Class::XSAccessor accessors => { 'file' => 'file', 'host' => 'host', };

sub initialize
{
    my $self = shift;
    my $args = shift;

    $self->file( $args->{'file'} );
    $self->host( $args->{'host'} );

    return 0;
}

package HTML::Latemp::GenMakeHelpers;

=head1 NAME

HTML::Latemp::GenMakeHelpers - A Latemp Utility Module.

=head1 SYNOPSIS

    use HTML::Latemp::GenMakeHelpers;

    my $generator =
        HTML::Latemp::GenMakeHelpers->new(
            'hosts' =>
            [ map {
                +{ 'id' => $_, 'source_dir' => $_,
                    'dest_dir' => "\$(ALL_DEST_BASE)/$_-homepage"
                }
            } (qw(common t2 vipe)) ],
        );

    $generator->process_all();

=head1 API METHODS

=head2 my $generator = HTML::Latemp::GenMakeHelpers->new(hosts => [@hosts])

Construct an object with the host defined in @hosts.

An optional parameter is C<'filename_lists_post_filter'> which must point
to a subroutine that accepts a hash reference of C<'host'>, C<'bucket'>,
and C<'filenames'> (which points to an array reference) and returns the
modified list of filenames as an array reference (it is called separately
for each host and bucket).

An example for it is:

    filename_lists_post_filter => sub {
        my ($args) = @_;
        my $filenames = $args->{filenames};
        if ($args->{host} eq 'src' and $args->{bucket} eq 'IMAGES')
        {
            return [ grep { $_ !~ m#arrow-right# } @$filenames ];
        }
        else
        {
            return $filenames;
        }
    },

(This parameter was added in version 0.5.0 of this module.)

An optional parameter is C<'out_dir'> which is the path to the output directory
of the *.mak files. By default, they get output locally. It was added in version v0.6.1.

An optional parameter is C<'out_docs_ext'> which is the extension for the docs
files (which should include the leading period) and which defaults to C<'.wml'>.
It was added in version v0.8.0.

An optional parameter is C<'docs_build_command_cb'> which is TBD.
It was added in version v0.8.0.

An optional parameter is C<'images_dest_varname_cb'> which is TBD.
It was added in version v0.8.0.

=head2 $generator->process_all()

Process all hosts.

=head1 INTERNAL METHODS

=cut

our @ISA = (qw(HTML::Latemp::GenMakeHelpers::Base));

use File::Find::Rule ();
use File::Basename qw/ basename /;

use Class::XSAccessor accessors => {
    '_common_buckets'             => '_common_buckets',
    '_base_dir'                   => 'base_dir',
    '_filename_lists_post_filter' => '_filename_lists_post_filter',
    'hosts'                       => 'hosts',
    '_hosts_id_map'               => 'hosts_id_map',
    '_out_dir'                    => '_out_dir',
    '_out_docs_ext'               => '_out_docs_ext',
    '_docs_build_command_cb'      => '_docs_build_command_cb',
    '_images_dest_varname_cb'     => '_images_dest_varname_cb',
};

=head2 initialize()

Called by the constructor to initialize the object. Can be sub-classed by
derived classes.

=cut

sub initialize
{
    my $self = shift;
    my (%args) = (@_);

    $self->_base_dir("src");
    $self->_filename_lists_post_filter(
        $args{filename_lists_post_filter} || sub {
            my ($params) = @_;
            return $params->{filenames};
        }
    );
    $self->hosts(
        [
            map { HTML::Latemp::GenMakeHelpers::HostEntry->new(%$_), }
                @{ $args{'hosts'} }
        ]
    );
    $self->_hosts_id_map( +{ map { $_->{'id'} => $_ } @{ $self->hosts() } } );
    $self->_common_buckets( {} );
    $self->_out_dir( $args{'out_dir'} );
    $self->_out_docs_ext( $args{'out_docs_ext'} // '.wml' );
    $self->_docs_build_command_cb( $args{'docs_build_command_cb'} );
    $self->_images_dest_varname_cb( $args{'images_dest_varname_cb'} );

    return;
}

sub _calc_out_path
{
    my ( $self, $bn ) = @_;

    my $out_dir = $self->_out_dir;

    return $out_dir ? File::Spec->catfile( $out_dir, $bn ) : $bn;
}

sub process_all
{
    my $self = shift;
    my $dir  = $self->_base_dir();

    my @hosts = @{ $self->hosts() };

    open my $file_lists_fh, ">", $self->_calc_out_path("include.mak");
    open my $rules_fh,      ">", $self->_calc_out_path("rules.mak");

    print {$rules_fh} "COMMON_SRC_DIR = "
        . $self->_hosts_id_map()->{'common'}->{'source_dir'} . "\n\n";

    foreach my $host (@hosts)
    {
        my $host_outputs = $self->process_host($host);
        print {$file_lists_fh} $host_outputs->{'file_lists'};
        print {$rules_fh} $host_outputs->{'rules'};
    }

    print {$rules_fh} "latemp_targets: "
        . join( " ",
        map  { '$(' . uc( $_->{'id'} ) . "_TARGETS)" }
        grep { $_->{'id'} ne "common" } @hosts )
        . "\n\n";

    close($rules_fh);
    close($file_lists_fh);
}

sub _make_path
{
    my $self = shift;

    my $host = shift;
    my $path = shift;

    return $host->source_dir() . "/" . $path;
}

=head2 $generator->hosts()

Returns an array reference of HTML::Latemp::GenMakeHelpers::HostEntry for
the hosts.

=head2 $generator->get_initial_buckets($host)

Get the initial buckets for the host $host.

=cut

sub get_initial_buckets
{
    my $self = shift;
    my $host = shift;

    return [
        {
            'name'   => "IMAGES",
            'filter' => sub {
                my $fn = shift;
                return ( $fn !~ /\.(?:tt|w)ml\z/ )
                    && ( -f $self->_make_path( $host, $fn ) );
            },
        },
        {
            'name'   => "DIRS",
            'filter' => sub {
                return ( -d $self->_make_path( $host, shift ) );
            },
            filter_out_common => 1,
        },
        {
            'name'   => "DOCS",
            'filter' => sub {
                return shift =~ /\.x?html\.wml\z/;
            },
            'map' => sub {
                my $fn = shift;
                $fn =~ s{\.wml\z}{};
                return $fn;
            },
        },
        {
            'name'   => "TTMLS",
            'filter' => sub {
                return shift =~ /\.ttml\z/;
            },
            'map' => sub {
                my $fn = shift;
                $fn =~ s{\.ttml\z}{};
                return $fn;
            },
        },
    ];
}

sub _identity
{
    return shift;
}

sub _process_bucket
{
    my ( $self, $bucket ) = @_;
    return {
        %$bucket,
        'results' => [],
        (
              ( !exists( $bucket->{'map'} ) )
            ? ( 'map' => \&_identity )
            : ()
        ),
    };
}

=head2 $generator->get_buckets($host)

Get the processed buckets.

=cut

sub get_buckets
{
    my ( $self, $host ) = @_;

    return [ map { $self->_process_bucket($_) }
            @{ $self->get_initial_buckets($host) } ];
}

sub _filter_out_special_files
{
    my ( $self, $host, $files_ref ) = @_;

    my @files = @$files_ref;

    @files = ( grep { !m{(\A|/)\.svn(/|\z)} } @files );
    @files = ( grep { !/~\z/ } @files );
    @files = (
        grep {
            my $bn = basename($_);
            not( ( $bn =~ /\A\./ ) && ( $bn =~ /\.swp\z/ ) )
        } @files
    );

    return \@files;
}

sub _sort_files
{
    my ( $self, $host, $files_ref ) = @_;

    return [ sort { $a cmp $b } @$files_ref ];
}

=head2 $self->get_non_bucketed_files($host)

Get the files that were not placed in any bucket.

=cut

sub get_non_bucketed_files
{
    my ( $self, $host ) = @_;

    my $source_dir_path = $host->source_dir();

    my $files = [ File::Find::Rule->in($source_dir_path) ];

    s!^$source_dir_path/!! for @$files;
    $files = [ grep { $_ ne $source_dir_path } @$files ];

    $files = $self->_filter_out_special_files( $host, $files );

    return $self->_sort_files( $host, $files );
}

=head2 $self->place_files_into_buckets($host, $files, $buckets)

Sort the files into the buckets.

=cut

sub place_files_into_buckets
{
    my ( $self, $host, $files, $buckets ) = @_;

FILE_LOOP:
    foreach my $f (@$files)
    {
        foreach my $bucket (@$buckets)
        {
            if ( $bucket->{'filter'}->($f) )
            {
                if ( $host->{'id'} eq "common" )
                {
                    $self->_common_buckets->{ $bucket->{name} }->{$f} = 1;
                }

                if (
                    ( $host->{'id'} eq "common" )
                    || (
                        !(
                            $bucket->{'filter_out_common'} && exists(
                                $self->_common_buckets->{ $bucket->{name} }
                                    ->{$f}
                            )
                        )
                    )
                    )
                {
                    push @{ $bucket->{'results'} }, $bucket->{'map'}->($f);
                }

                next FILE_LOOP;
            }
        }
        die HTML::Latemp::GenMakeHelpers::Error::UncategorizedFile->new(
            {
                'file' => $f,
                'host' => $host->id(),
            }
        );
    }
}

=head2 $self->get_rules_template($host)

Get the makefile rules template for the host $host.

=cut

sub get_rules_template
{
    my ( $self, $host ) = @_;

    my $h_dest_star = "\$(X8X_DEST)/%";
    my $wml_path =
qq{WML_LATEMP_PATH="\$\$(perl -MFile::Spec -e 'print File::Spec->rel2abs(shift)' '\$\@')"};
    my $dest_dir        = $host->dest_dir();
    my $source_dir_path = $host->source_dir();
    my $out_docs_ext    = $self->_out_docs_ext;

    my ( $common_cmd, $no_common_cmd );
    if ( my $cb = $self->_docs_build_command_cb )
    {
        $common_cmd    = $cb->( $self, { host => $host, is_common => 1, } );
        $no_common_cmd = $cb->( $self, { host => $host, is_common => '', } );
    }
    else
    {
        $common_cmd =
qq#$wml_path ; ( cd \$(COMMON_SRC_DIR) && wml -o "\$\${WML_LATEMP_PATH}" \$(X8X_WML_FLAGS) -DLATEMP_FILENAME=\$(patsubst $h_dest_star,%,\$(patsubst %${out_docs_ext},%,\$@)) \$(patsubst \$(COMMON_SRC_DIR)/%,%,\$<) )#;
        $no_common_cmd =
qq#$wml_path ; ( cd \$(X8X_SRC_DIR) && wml -o "\$\${WML_LATEMP_PATH}" \$(X8X_WML_FLAGS) -DLATEMP_FILENAME=\$(patsubst $h_dest_star,%,\$(patsubst %${out_docs_ext},%,\$@)) \$(patsubst \$(X8X_SRC_DIR)/%,%,\$<) )#;
    }
    my ( $common_images_dest, $no_common_images_dest );
    if ( my $cb = $self->_images_dest_varname_cb )
    {
        $common_images_dest =
            $cb->( $self, { host => $host, is_common => 1, } );
        $no_common_images_dest =
            $cb->( $self, { host => $host, is_common => '', } );
    }
    else
    {
        $no_common_images_dest = $common_images_dest = 'X8X_DEST';
    }
    my $ci_h_dest_star  = "\$($common_images_dest)/%";
    my $nci_h_dest_star = "\$($no_common_images_dest)/%";
    return <<"EOF";

X8X_SRC_DIR := $source_dir_path

X8X_DEST := $dest_dir

X8X_WML_FLAGS := \$(WML_FLAGS) -DLATEMP_SERVER=x8x

X8X_TTML_FLAGS := \$(TTML_FLAGS) -DLATEMP_SERVER=x8x

X8X_DOCS_DEST := \$(patsubst %,\$(X8X_DEST)/%,\$(X8X_DOCS))

X8X_DIRS_DEST := \$(patsubst %,\$(X8X_DEST)/%,\$(X8X_DIRS))

X8X_IMAGES_DEST := \$(patsubst %,\$($no_common_images_dest)/%,\$(X8X_IMAGES))

X8X_TTMLS_DEST := \$(patsubst %,\$(X8X_DEST)/%,\$(X8X_TTMLS))

X8X_COMMON_IMAGES_DEST := \$(patsubst %,\$($common_images_dest)/%,\$(COMMON_IMAGES))

X8X_COMMON_DIRS_DEST := \$(patsubst %,\$(X8X_DEST)/%,\$(COMMON_DIRS))

X8X_COMMON_TTMLS_DEST := \$(patsubst %,\$(X8X_DEST)/%,\$(COMMON_TTMLS))

X8X_COMMON_DOCS_DEST := \$(patsubst %,\$(X8X_DEST)/%,\$(COMMON_DOCS))

X8X_TARGETS := \$(X8X_DEST) \$(X8X_DIRS_DEST) \$(X8X_COMMON_DIRS_DEST) \$(X8X_COMMON_IMAGES_DEST) \$(X8X_COMMON_DOCS_DEST) \$(X8X_COMMON_TTMLS_DEST) \$(X8X_IMAGES_DEST) \$(X8X_DOCS_DEST) \$(X8X_TTMLS_DEST)

\$(X8X_DOCS_DEST) : $h_dest_star : \$(X8X_SRC_DIR)/%${out_docs_ext} \$(DOCS_COMMON_DEPS)
	$no_common_cmd

\$(X8X_TTMLS_DEST) : $h_dest_star : \$(X8X_SRC_DIR)/%.ttml \$(TTMLS_COMMON_DEPS)
	ttml -o \$@ \$(X8X_TTML_FLAGS) -DLATEMP_FILENAME=\$(patsubst $h_dest_star,%,\$(patsubst %.ttml,%,\$@)) \$<

\$(X8X_DIRS_DEST) : $h_dest_star :
	mkdir -p \$@
	touch \$@

\$(X8X_IMAGES_DEST) : $nci_h_dest_star : \$(X8X_SRC_DIR)/%
	\$(call LATEMP_COPY)

\$(X8X_COMMON_IMAGES_DEST) : $ci_h_dest_star : \$(COMMON_SRC_DIR)/%
	\$(call LATEMP_COPY)

\$(X8X_COMMON_TTMLS_DEST) : $h_dest_star : \$(COMMON_SRC_DIR)/%.ttml \$(TTMLS_COMMON_DEPS)
	ttml -o \$@ \$(X8X_TTML_FLAGS) -DLATEMP_FILENAME=\$(patsubst $h_dest_star,%,\$(patsubst %.ttml,%,\$@)) \$<

\$(X8X_COMMON_DOCS_DEST) : $h_dest_star : \$(COMMON_SRC_DIR)/%${out_docs_ext} \$(DOCS_COMMON_DEPS)
	$common_cmd

\$(X8X_COMMON_DIRS_DEST)  : $h_dest_star :
	mkdir -p \$@
	touch \$@

\$(X8X_DEST):
	mkdir -p \$@
	touch \$@
EOF
}

=head2 $self->process_host($host)

Process the host $host.

=cut

sub process_host
{
    my $self = shift;
    my $host = shift;

    my $dir = $self->_base_dir();

    my $source_dir_path = $host->source_dir();

    my $file_lists_text = "";
    my $rules_text      = "";

    my $files = $self->get_non_bucketed_files($host);

    my $buckets = $self->get_buckets($host);

    $self->place_files_into_buckets( $host, $files, $buckets );

    my $id      = $host->id();
    my $host_uc = uc($id);
    foreach my $bucket (@$buckets)
    {
        my $name = $bucket->{name};
        $file_lists_text .=
              $host_uc . "_"
            . $name . " :="
            . join(
            "",
            map { " $_" } @{
                $self->_filename_lists_post_filter->(
                    {
                        filenames => $bucket->{'results'},
                        bucket    => $name,
                        host      => $id,
                    }
                )
            }
            ) . "\n";
    }

    if ( $id ne "common" )
    {
        my $rules = $self->get_rules_template($host);

        $rules =~ s!X8X!$host_uc!g;
        $rules =~ s!x8x!$id!ge;
        $rules_text .= $rules;
    }

    return {
        'file_lists' => $file_lists_text,
        'rules'      => $rules_text,
    };
}

1;

__END__

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/> .

=head1 BUGS

Please report any bugs or feature requests to
C<bug-html-latemp-genmakehelpers@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-Latemp-GenMakeHelpers>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 Shlomi Fish, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the MIT X11 License.

=cut
