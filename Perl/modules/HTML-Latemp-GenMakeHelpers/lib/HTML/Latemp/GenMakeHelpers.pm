package HTML::Latemp::GenMakeHelpers;

use strict;
use warnings;

use vars qw($VERSION);

$VERSION = '0.1.4';

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

sub process_host
{
    my $self = shift;
    my $host = shift;

    my $dir = $self->base_dir();

    my $source_dir_path = $host->source_dir();
    my $make_path = sub {
        my $path = shift;
        return "$source_dir_path/$path";
    };

    my $file_lists_text = "";
    my $rules_text = "";

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

    my @buckets = 
    (
        {
            'name' => "IMAGES",
            'filter' => sub { (!/\.wml$/) && (-f $make_path->($_)) },
        },
        {
            'name' => "DIRS",
            'filter' => sub { (-d $make_path->($_)) },
        },
        {
            'name' => "DOCS",
            'filter' => sub { /\.html\.wml$/ },
            'map' => sub { my $a = shift; $a =~ s{\.wml$}{}; return $a;},
        },
    );

    foreach (@buckets) 
    { 
        $_->{'results'}=[]; 
        if (!exists($_->{'map'}))
        {
            $_->{'map'} = sub { return shift;},
        }
    }

    FILE_LOOP: foreach (@files)
    {
        for my $b (@buckets)
        {
            if ($b->{'filter'}->())
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
        my $dest_dir = $host->dest_dir();
        my $rules = <<"EOF";

X8X_SRC_DIR = $source_dir_path

X8X_DEST = $dest_dir

X8X_TARGETS = \$(X8X_DEST) \$(X8X_DIRS_DEST) \$(X8X_COMMON_DIRS_DEST) \$(X8X_COMMON_IMAGES_DEST) \$(X8X_IMAGES_DEST) \$(X8X_DOCS_DEST)
        
X8X_WML_FLAGS = \$(WML_FLAGS) -DLATEMP_SERVER=x8x

X8X_DOCS_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(X8X_DOCS))

X8X_DIRS_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(X8X_DIRS))

X8X_IMAGES_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(X8X_IMAGES))

X8X_COMMON_IMAGES_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(COMMON_IMAGES))

X8X_COMMON_DIRS_DEST = \$(patsubst %,\$(X8X_DEST)/%,\$(COMMON_DIRS))
        
\$(X8X_DOCS_DEST) :: $h_dest_star : \$(X8X_SRC_DIR)/%.wml \$(DOCS_COMMON_DEPS) 
	( cd \$(X8X_SRC_DIR) && wml \$(X8X_WML_FLAGS) -DLATEMP_FILENAME=\$(patsubst $h_dest_star,%,\$(patsubst %.wml,%,\$@)) \$(patsubst \$(X8X_SRC_DIR)/%,%,\$<) ) > \$@

\$(X8X_DIRS_DEST) :: $h_dest_star : unchanged
	mkdir -p \$@
	touch \$@

\$(X8X_IMAGES_DEST) :: $h_dest_star : \$(X8X_SRC_DIR)/%
	cp -f \$< \$@

\$(X8X_COMMON_IMAGES_DEST) :: $h_dest_star : \$(COMMON_SRC_DIR)/%
	cp -f \$< \$@

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

