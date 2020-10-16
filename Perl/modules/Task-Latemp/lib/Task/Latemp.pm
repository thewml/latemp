package Task::Latemp;

use warnings;
use strict;

use 5.014;

use CGI;
use Class::Accessor;
use Data::Dumper;
use File::Basename;
use File::Find::Rule;
use File::Path;
use Getopt::Long;
use HTML::Latemp::GenMakeHelpers;
use HTML::Latemp::NavLinks::GenHtml::Text;
use HTML::Latemp::News;
use HTML::Widgets::NavMenu;
use Pod::Usage;
use Template;
use YAML;

=head1 NAME

Task::Latemp - Specifications for modules needed by the Latemp static site generator.

=head1 DESCRIPTION

Latemp ( L<https://web-cpan.shlomifish.org/latemp/> ) is a static site
generator based on Website Meta Language. This task installs all of its
required dependencies.

=head1 AUTHOR

Shlomi Fish, L<https://www.shlomifish.org/> .

=head1 ACKNOWLEDGEMENTS

=head1 SEE ALSO

L<Task> .

=head1 COPYRIGHT & LICENSE

Copyright 2006 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT / Expat .

=cut

1; # End of Task::Latemp
