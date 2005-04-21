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

import os, sys
import Autoscons
import Autoscons.Util
import SCons.SConf

def Configure(env, custom_tests = {}, conf_dir = None, log_file = None):
	""" Configure an environment using Autocons.  This calls SCons.SConf.Configure
	but adds the custom Autocons tests."""
	
	# integrate the Autocons tests
	ac_tests = [
		( 'CheckConfigScript', CheckConfigScript ),
		( 'CheckPkgConfig', CheckPkgConfig ),
		( 'CheckLibSanity', CheckLibSanity )
		]
	for key, value in ac_tests:
		custom_tests[key] = value

	# build SConf
	args = { 'custom_tests': custom_tests }
	if conf_dir != None:
		args['conf_dir'] = conf_dir
	if log_file != None:
		args['log_file'] = log_file
	sconf = apply(SCons.SConf.SConf, [ env ], args)

	return sconf

def CheckLibSanity(context, library_obj):
	context.Message("Checking for %s sanity... " % library_obj.target)

	new_env = context.env.Copy()
	library_obj.ApplyDependToEnv(new_env)

	# TODO: allow libraries to specify there own source file for the sanity test
	ret = context.TryBuild(new_env.Program, """
		int
		main() {
			return 0;
		}\n\n""", ".cpp")

	if ret:
		context.Result("ok")
	else:
		context.Result("failed")
	return ret

def CheckConfigScript(context, library_name, script_name, min_version):
	context.Message("Checking for configure script for %s... " % library_name)
	
	if os.name in ('nt', 'dos'):
		# NOTE: we do this inorder to make up for the fact that windows
		# won't understand something like the #! (she-bang)
		script_path = SCons.Util.WhereIs(script_name, 
			os.environ['PATH'], os.environ['PATHEXT'] + ";.py")
	else:
		script_path = SCons.Util.WhereIs(script_name)
	if script_path == None:
		context.Result("not found")
		return None
	else:
		if script_path[-3:] == ".py":
			script_path = sys.executable + " \"" + script_path + "\""
		context.Result(script_path)
	
	context.Message("Checking for %s with version >= %s... " % (library_name, min_version))
	
	# read the version
	ret, stdout = Autoscons.Util.OpenProcess(script_path + " --version")
	if not ret:
		context.Result("not found")
		return None
	version = stdout.readline()
	
	# check version string
	if not Autoscons.Util.CheckVersion(version[:-1], min_version):
		context.Result(version)
		return None
	
	# read cflags
	ret, stdout = Autoscons.Util.OpenProcess(script_path + " --cflags")
	if not ret:
		context.Result("not found")
		return None
	cflags = stdout.readline()
	
	# read libs
	ret, stdout = Autoscons.Util.OpenProcess(script_path + " --libs")
	if not ret:
		context.Result("not found")
		return None
	libs = stdout.readline()
	
	context.Result(version[:-1])
	
	# make the library object
	lib = Autoscons.Library(context.env, library_name)
	lib.ReadDepConfig(cflags, libs)

	# sanity test 
	# TODO: allow user to skip the sanity test.  This is important for 
	# cross-compiling
	if not context.sconf.CheckLibSanity(lib):
		return None
	
	return lib

def CheckPkgConfig(context, library_name, pc_name, min_version):
	try:
		pkg_config = context.env['PKGCONFIG']
	except KeyError:
		# TODO: make a single check for pkg-config
		context.Message("Checking for pkg-config installed on this system... ")
		pkg_config = SCons.Util.WhereIs("pkg-config")
		if pkg_config == None:
			context.Result("not found")
			return None
		else:
			context.Result(pkg_config)
			context.env['PKGCONFIG'] = pkg_config
	script_path = pkg_config + " " + pc_name
	
	context.Message("Checking for %s with version >= %s... " % (library_name, min_version))

	# read the version
	ret, stdout = Autoscons.Util.OpenProcess(script_path + " --modversion")
	if not ret:
		context.Result("not found")
		return None
	version = stdout.readline()
	
	# check version string using pkg-config
	ret, temp = Autoscons.Util.OpenProcess(script_path + " --atleast-version=" + min_version)
	if not ret:
		context.Result(version)
		return None
	
	# read cflags
	ret, stdout = Autoscons.Util.OpenProcess(script_path + " --cflags")
	if not ret:
		context.Result("not found")
		return None
	cflags = stdout.readline()
	
	# read libs
	ret, stdout = Autoscons.Util.OpenProcess(script_path + " --libs")
	if not ret:
		context.Result("not found")
		return None
	libs = stdout.readline()
	
	context.Result(version[:-1])
	
	# make the library object
	lib = Autoscons.Library(context.env, library_name)
	lib.ReadDepConfig(cflags, libs)

	# sanity test 
	# TODO: allow user to skip the sanity test.  This is important for 
	# cross-compiling
	if not context.sconf.CheckLibSanity(lib):
		return None
	
	return lib


