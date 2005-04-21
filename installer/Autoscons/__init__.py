# Autoscons - An autotools replacement for SCons
# Copyright 2003 David Snopek
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 

"""
Autoscons is a GNU AutoTools replacement, for SCons.

TODO:
 * Read and write libtool *.la's, pkg-config *.pc's, and *-config scripts (in python, dos batch, and sh-compatible shell).
 * Built-in tests for basic platform stuff, such as, determining that we are going to do a mingw or an msvc build so we can do platform specific configuration.
 * Functions for comparing versions strings to require a minimum version.
 * WIN32: Ensure that import libraries get installed in "lib/" and dlls in "dll/"
 * Port to python 1.5.2.
"""

__author__ = "David Snopek"

from Autoscons.Template import Template
from Autoscons.Tool import Tool
from Autoscons.Configure import Configure
from Autoscons.AutoBuild import Init, Package, Library, Program, Features, ConfHeader, Options

def _setup():
	import types
	# add StringTypes if this python doesn't have it
	if not hasattr(types, "StringTypes"):
		types.StringTypes = (types.StringType, types.UnicodeType)

_setup()
