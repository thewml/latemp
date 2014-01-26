package Bundle::Latemp;

use strict;
use warnings;

use 5.008;

use vars (qw($VERSION));

$VERSION = '0.2.4';

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

L<http://web-cpan.shlomifish.org/latemp/>

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/> .

=head1 LICENSE

Copyright 2014 by Shlomi Fish

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut

