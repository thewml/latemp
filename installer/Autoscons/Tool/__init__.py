""" A copy of the SCons tool selection mechanism.

This exists to provide tool modules just like those in SCons so that
they can be easily added to SCons eventually.

"""

#
# Copyright (c) 2001, 2002, 2003 Steven Knight
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
# KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

import imp
import sys

import Autoscons
import SCons.Errors

class ToolSpec:
    def __init__(self, name):
        self.name = name

    def __call__(self, env, *args, **kw):
        env.Append(TOOLS = [ self.name ])
        apply(self.generate, ( env, ) + args, kw)

    def __str__(self):
        return self.name
    
def Tool(name):
    """Select a canned Tool specification.
    """
    full_name = 'Autoscons.Tool.' + name
    if not sys.modules.has_key(full_name):
        try:
            file, path, desc = imp.find_module(name,
                                        sys.modules['Autoscons.Tool'].__path__)
            mod = imp.load_module(full_name, file, path, desc)
            setattr(Autoscons.Tool, name, mod)
        except ImportError:
            raise SCons.Errors.UserError, "No tool named '%s'" % name
        if file:
            file.close()
    spec = ToolSpec(name)
    spec.generate = sys.modules[full_name].generate
    spec.exists = sys.modules[full_name].exists
    return spec

