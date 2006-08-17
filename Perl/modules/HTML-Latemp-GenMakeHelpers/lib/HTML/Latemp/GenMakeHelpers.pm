package HTML::Latemp::GenMakeHelpers;

use strict;
use warnings;

use vars qw($VERSION);

$VERSION = '0.1.7';

package HTML::Latemp::GenMakeHelpers::Base;

use base 'Class::Accessor';

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->initialize(@_);
    return $self;
}

package HTML::Latemp::GenMakeHelpers::HostEntry;

use vars qw(@ISA);

@ISA=(qw(HTML::Latemp::GenMakeHelpers::Base));

__PACKAGE__->mk_accessors(qw(id dest_dir source_dir));

sub initialize
{
    my $self = shift;
    my %args = (@_);

    $self->id($args{'id'});
    $self->source_dir($args{'source_dir'});
    $self->dest_dir($args{'dest_dir'});
}

package HTML::Latemp::GenMakeHelpers;

use vars qw(@ISA);

@ISA=(qw(HTML::Latemp::GenMakeHelpers::Base));

use File::Find::Rule;
use File::Basename;

__PACKAGE__->mk_accessors(qw(base_dir hosts hosts_id_map));

sub initialize
{
    my $self = shift;
    my (%args) = (@_);

    $self->base_dir("src");
    $self->hosts(
        [ 
        map { 
            HTML::Latemp::GenMakeHelpers::HostEntry->new(
                %$_
            ),
        }
        @{$args{'hosts'}}
        ]
        );
    $self->hosts_id_map(+{ map { $_->{'id'} => $_ } @{$self->hosts()}});
}

sub process_all
{
    my $self = shift;
    my $dir = $self->base_dir();

    my @hosts = @{$self->hosts()};

    open my $file_lists_fh, ">", "include.mak";
    open my $rules_fh, ">", "rules.mak";

    print {$rules_fh} "COMMON_SRC_DIR = " . $self->hosts_id_map()->{'common'}->{'source_dir'} . "\n\n";

    foreach my $host (@hosts)
    {
        my $host_outputs = $self->process_host($host);
        print {$file_lists_fh} $host_outputs->{'file_lists'};
        print {$rules_fh} $host_outputs->{'rules'};
    }

    print {$rules_fh} "latemp_targets: " . join(" ", map { '$('.uc($_->{'id'})."_TARGETS)" } grep { $_->{'id'} ne "common" } @hosts) . "\n\n";

    close($rules_fh);
    close($file_lists_fh);
}

sub _make_path
{
    my $self = shift;

    my $host = shift;
    my $path = shift;

    return $host->source_dir(). "/".$path;
}



sub get_initial_buckets
{
    my $self = shift;
    my $host = shift;

    return
    [
        {
            'name' => "IMAGES",
            'filter' =>
            sub 
            { 
                (!/\.(?:tt|w)ml$/) && (-f $self->_make_path($host, $_)) 
            },
        },
        {
            'name' => "DIRS",
            'filter' => 
            sub { (-d $self->_make_path($host, $_)) },
        },
        {
            'name' => "DOCS",
            'filter' => sub { /\.html\.wml$/ },
            'map' => sub { my $a = shift; $a =~ s{\.wml$}{}; return $a;},
        },
        {
            'name' => "TTMLS",
            'filter' => sub { /\.ttml$/ },
            'map' => sub { my $a = shift; $a =~ s{\.ttml$}{}; return $a;},
        },
    ];
}

sub _identity
{
    return shift;
}

sub _process_bucket
{
    my ($self, $bucket) = @_;
    return 
        { 
            %$bucket, 
            'results' => [],
            (
                (!exists($bucket->{'map'})) ?
                    ('map' => \&_identity) :
                    ()
            ),
        };
}

sub get_buckets
{
    my ($self, $host) = @_;

    return 
        [ 
            map 
            { $self->_process_bucket($_) } 
            @{$self->get_initial_buckets($host)} 
        ];
}

sub get_non_bucketed_files
{
    my ($self, $host) = @_;

    my $source_dir_path = $host->source_dir();

    my @files = File::Find::Rule->in($source_dir_path);

    s!^$source_dir_path/!! for @files;
    @files = (grep { $_ ne $source_dir_path } @files);
    @files = (grep { ! m{(^|/)\.svn(/|$)} } @files);
    @files = (grep { ! /~$/ } @files);
    @files = 
        (grep 
        {
            my $b = basename($_); 
            !(($b =~ /^\./) && ($b =~ /\.swp$/))
        } 
        @files
        );
    @files = sort { $a cmp $b } @files;

    return \@files;
}

sub process_host
{
    my $self = shift;
    my $host = shift;

    my $dir = $self->base_dir();

    my $source_dir_path = $host->source_dir();

    my $file_lists_text = "";
    my $rules_text = "";

    my @files = @{$self->get_non_bucketed_files($host)};

    my @buckets = @{$self->get_buckets($host)};


    FILE_LOOP: foreach (@files)
    {
        for my $b (@buckets)
        {
            if ($b->{'filter'}->($host, $_))
            {
                push @{$b->{'results'}}, $b->{'map'}->($_);
                next FILE_LOOP;
            }
        }
        die "Uncategorized file $_ - host == " . $host->id() . "!";
    }

    my $host_uc = uc($host->id());
    foreach my $b (@buckets)
    {
        $file_lists_text .= $host_uc . "_" . $b->{'name'} . " = " . join(" ", @{$b->{'results'}}) . "\n";
    }
    
    if ($host->id() ne "common")
    {
        my $h_dest_star = "\$(X8X_DEST)/%";
        my $wml_path = qq{WML_LATEMP_PATH="\$\$(perl -MFile::Spec -e 'print File::Spec->rel2abs(shift)' '\$\@')"};
        my $dest_dir = $host->dest_dir();
        my $rules = <<"EOF";

X8X_SRC_DIR = $source_dir_path

X8X_DEST = $dest_dir

X8X_TARGETS = \$(X8X_DEST) \$(X8X_DIRS_DEST) \$(X8X_COMMON_DIRS_DEST) \$(X8X_COMMON_IMAGES_DEST) \$(X8X_COMMON_DOCS_DEST) \$(X8X_COMMON_TTMLS_DEST) \$(X8X_IMAGES_DEST) \$(X8X_DOCS_DEST) \$(X8X_TTMLS_DEST)

X8X_WML_FLAGS = \$(WML_FLAGS) -DLATEMP_SERVER=x8x

X8X_TTML_FLAGS = \$(TTML_FLAGS) -DLATEMP_SERVER=x8x

X8X_DOCS_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(X8X_DOCS))

X8X_DIRS_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(X8X_DIRS))

X8X_IMAGES_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(X8X_IMAGES))

X8X_TTMLS_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(X8X_TTMLS))

X8X_COMMON_IMAGES_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(COMMON_IMAGES))

X8X_COMMON_DIRS_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(COMMON_DIRS))

X8X_COMMON_TTMLS_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(COMMON_TTMLS))

X8X_COMMON_DOCS_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(COMMON_DOCS))

\$(X8X_DOCS_DEST) :: $h_dest_star : \$(X8X_SRC_DIR)/%.wml \$(DOCS_COMMON_DEPS) 
	 $wml_path ; ( cd \$(X8X_SRC_DIR) && wml -o "\$\${WML_LATEMP_PATH}" \$(X8X_WML_FLAGS) -DLATEMP_FILENAME=\$(patsubst $h_dest_star,%,\$(patsubst %.wml,%,\$@)) \$(patsubst \$(X8X_SRC_DIR)/%,%,\$<) )

\$(X8X_TTMLS_DEST) :: $h_dest_star : \$(X8X_SRC_DIR)/%.ttml \$(TTMLS_COMMON_DEPS)
	ttml -o \$@ \$(X8X_TTML_FLAGS) -DLATEMP_FILENAME=\$(patsubst $h_dest_star,%,\$(patsubst %.ttml,%,\$@)) \$<

\$(X8X_DIRS_DEST) :: $h_dest_star : unchanged
	mkdir -p \$@
	touch \$@

\$(X8X_IMAGES_DEST) :: $h_dest_star : \$(X8X_SRC_DIR)/%
	cp -f \$< \$@

\$(X8X_COMMON_IMAGES_DEST) :: $h_dest_star : \$(COMMON_SRC_DIR)/%
	cp -f \$< \$@

\$(X8X_COMMON_TTMLS_DEST) :: $h_dest_star : \$(COMMON_SRC_DIR)/%.ttml \$(TTMLS_COMMON_DEPS)
	ttml -o \$@ \$(X8X_TTML_FLAGS) -DLATEMP_FILENAME=\$(patsubst $h_dest_star,%,\$(patsubst %.ttml,%,\$@)) \$<

\$(X8X_COMMON_DOCS_DEST) :: $h_dest_star : \$(COMMON_SRC_DIR)/%.wml \$(DOCS_COMMON_DEPS)
	$wml_path ; ( cd \$(COMMON_SRC_DIR) && wml -o "\$\${WML_LATEMP_PATH}" \$(X8X_WML_FLAGS) -DLATEMP_FILENAME=\$(patsubst $h_dest_star,%,\$(patsubst %.wml,%,\$@)) \$(patsubst \$(COMMON_SRC_DIR)/%,%,\$<) )

\$(X8X_COMMON_DIRS_DEST)  :: $h_dest_star : unchanged
	mkdir -p \$@
	touch \$@

\$(X8X_DEST): unchanged
	mkdir -p \$@
	touch \$@

EOF

        $rules =~ s!X8X!$host_uc!g;
        $rules =~ s!x8x!$host->id()!ge;
        $rules_text .= $rules;
    }

    return
        {
            'file_lists' => $file_lists_text,
            'rules' => $rules_text,
        };
}

1;

__END__

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

=head1 AUTHOR

Shlomi Fish, C<< <shlomif@iglu.org.il> >>

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

