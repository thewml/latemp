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

import os.path

import SCons.Builder
import SCons.Action

GzipAction = SCons.Action.Action("$GZIP $GZIPFLAGS - < $SOURCE > ${TARGET.abspath}")
GzipBuilder = SCons.Builder.Builder(action = '$GZIPCOM', suffix = '$GZIPSUFFIX')

def generate(env):
    """Add Builders and construction variables for zip to an Environment."""
    try:
        bld = env['BUILDERS']['Gzip']
    except KeyError:
        bld = GzipBuilder
        env['BUILDERS']['Gzip'] = bld
        env['TOOLS'].append('gzip')

	env['GZIP']        = 'gzip'
    env['GZIPFLAGS']   = '--best'
    env['GZIPCOM']     = GzipAction
    env['GZIPSUFFIX']  = '.gz'

def exists(env):
    return env.Detect('gzip')

