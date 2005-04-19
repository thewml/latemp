package HTML::Latemp::GenMakeHelpers;

use strict;
use warnings;

use File::Find::Rule;
use File::Basename;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw(base_dir));

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->initialize(@_);
    return $self;
}

sub initialize
{
    my $self = shift;

    $self->base_dir("src");
}

sub process_all
{
    my $self = shift;
    my $dir = $self->base_dir();

    opendir D, "$dir";
    my @hosts = grep { -d "$dir/$_" } grep { !/^\./ } readdir(D);
    closedir(D);

    open my $file_lists_fh, ">", "include.mak";
    open my $rules_fh, ">", "rules.mak";

    print {$rules_fh} "COMMON_SRC_DIR = src/common\n\n";

    foreach my $host (@hosts)
    {
        my $host_outputs = $self->process_host($host);
        print {$file_lists_fh} $host_outputs->{'file_lists'};
        print {$rules_fh} $host_outputs->{'rules'};
    }

    print {$rules_fh} "latemp_targets: " . join(" ", map { '$('.uc($_)."_TARGETS)" } grep { $_ ne "common" } @hosts) . "\n\n";

    close($rules_fh);
    close($file_lists_fh);
}

sub process_host
{
    my $self = shift;
    my $host = shift;

    my $dir = $self->base_dir();

    my $dir_path = "$dir/$host";
    my $make_path = sub {
        my $path = shift;
        return "$dir_path/$path";
    };

    my $file_lists_text = "";
    my $rules_text = "";

    my @files = File::Find::Rule->in($dir_path);

    s!^$dir_path/!! for @files;
    @files = (grep { $_ ne $dir_path } @files);
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
        die "Uncategorized file $_ - host == $host!";
    }

    my $host_uc = uc($host);
    foreach my $b (@buckets)
    {
        $file_lists_text .= $host_uc . "_" . $b->{'name'} . " = " . join(" ", @{$b->{'results'}}) . "\n";
    }
    
    if ($host ne "common")
    {
        my $h_dest_star = "\$(${host_uc}_DEST)/%";
        $rules_text .= <<"EOF";

${host_uc}_DEST_DIR = $host

${host_uc}_SRC_DIR = src/${host}

${host_uc}_DEST = \$(D)/\$(${host_uc}_DEST_DIR)

${host_uc}_TARGETS = \$(${host_uc}_DIRS_DEST) \$(${host_uc}_COMMON_DIRS_DEST) \$(${host_uc}_COMMON_IMAGES_DEST) \$(${host_uc}_IMAGES_DEST) \$(${host_uc}_DOCS_DEST) 
        
${host_uc}_WML_FLAGS = \$(WML_FLAGS) -DLATEMP_SERVER=${host}

${host_uc}_DOCS_DEST = \$(patsubst %,\$(${host_uc}_DEST)/%,\$(${host_uc}_DOCS))

${host_uc}_DIRS_DEST = \$(patsubst %,\$(${host_uc}_DEST)/%,\$(${host_uc}_DIRS))

${host_uc}_IMAGES_DEST = \$(patsubst %,\$(${host_uc}_DEST)/%,\$(${host_uc}_IMAGES))

${host_uc}_COMMON_IMAGES_DEST = \$(patsubst %,\$(${host_uc}_DEST)/%,\$(COMMON_IMAGES))

${host_uc}_COMMON_DIRS_DEST = \$(patsubst %,\$(${host_uc}_DEST)/%,\$(COMMON_DIRS))
        
\$(${host_uc}_DOCS_DEST) :: $h_dest_star : \$(${host_uc}_SRC_DIR)/%.wml \$(DOCS_COMMON_DEPS) 
	( cd \$(${host_uc}_SRC_DIR) && wml \$(${host_uc}_WML_FLAGS) -DLATEMP_FILENAME=\$(patsubst $h_dest_star,%,\$(patsubst %.wml,%,\$@)) \$(patsubst \$(${host_uc}_SRC_DIR)/%,%,\$<) ) > \$@

\$(${host_uc}_DIRS_DEST) :: $h_dest_star : unchanged
	mkdir -p \$@
	touch \$@

\$(${host_uc}_IMAGES_DEST) :: $h_dest_star : \$(${host_uc}_SRC_DIR)/%
	cp -f \$< \$@

\$(${host_uc}_COMMON_IMAGES_DEST) :: $h_dest_star : \$(COMMON_SRC_DIR)/%
	cp -f \$< \$@

\$(${host_uc}_COMMON_DIRS_DEST) :: $h_dest_star : unchanged
	mkdir -p \$@
	touch \$@
 
EOF
    }

    return
        {
            'file_lists' => $file_lists_text,
            'rules' => $rules_text,
        };
}

1;

