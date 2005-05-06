package Bundle::Latemp;

$VERSION = '0.2.3';

1;

__END__

=head1 NAME

Bundle::Latemp - A bundle to install external CPAN modules used by 
the Latemp Content Management System 

=head1 SYNOPSIS

Perl one liner using CPAN.pm:

  perl -MCPAN -e 'install Bundle::Latemp'

Use of CPAN.pm in interactive mode:

  $> perl -MCPAN -e shell
  cpan> install Bundle::Latemp
  cpan> quit

Just like the manual installation of perl modules, the user may
need root access during this process to insure write permission 
is allowed within the intstallation directory.


=head1 CONTENTS

CGI

Class::Accessor

Data::Dumper

File::Basename

File::Find::Rule

File::Path

Getopt::Long

HTML::Latemp::GenMakeHelpers

HTML::Latemp::NavLinks::GenHtml

HTML::Latemp::News

HTML::Widgets::NavMenu

Pod::Usage

Template

YAML

=head1 DESCRIPTION

This bundle installs modules needed by the Latemp Content Management System:

L<http://web-cpan.berlios.de/latemp/>

=head1 AUTHOR

Shlomi Fish E<lt>F<shlomif@iglu.org.il>E<gt>

=cut

