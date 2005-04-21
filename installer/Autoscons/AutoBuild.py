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

import SCons, os, sys, string, shutil, types
import Autoscons.Util
import Autoscons.Builder
from Autoscons.Template import Template

_default_install_pathes = None
def GetDefaultInstallPathes():
	""" Returns the default install pathes for this platform.  This data is cached and 
	doesn't change from the first call. """

	global _default_install_pathes

	if _default_install_pathes == None:
		# default prefix for the given platform.  Some platforms require you to set a 
		# prefix manually.
		if os.name == 'posix':
			prefix = "/usr/local"
		else:
			prefix = None
		
		inst = {}
		inst['AC_PREFIX'] = prefix
		inst['AC_EXECPREFIX'] = "$AC_PREFIX"
		if os.name in ('nt', 'dos'):
			inst['AC_LIBDIR'] = os.path.join('$AC_EXECPREFIX', 'dll')
			inst['AC_IMPORTDIR'] = os.path.join('$AC_EXECPREFIX', 'lib')
		else:
			inst['AC_LIBDIR'] = os.path.join('$AC_EXECPREFIX', 'lib')
			inst['AC_IMPORTDIR'] = None
		inst['AC_INCLUDEDIR'] = os.path.join('$AC_PREFIX', 'include')
		inst['AC_DATADIR'] = os.path.join('$AC_PREFIX', 'share')
		inst['AC_BINDIR'] = os.path.join('$AC_EXECPREFIX', 'bin')
		inst['AC_SBINDIR'] = os.path.join('$AC_EXECPREFIX', 'sbin')
		inst['AC_MANDIR'] = os.path.join('$AC_PREFIX', 'man')
		inst['AC_INFODIR'] = os.path.join('$AC_PREFIX', 'info')
		inst['AC_SYSCONFDIR'] = os.path.join('$AC_PREFIX', 'etc')
		_default_install_pathes = inst

	return _default_install_pathes

def _build_install_pathes(env):
	# insert defaults if the environment hasn't overridden
	inst = GetDefaultInstallPathes()
	for key, value in inst.items():
		if not env.has_key(key):
			env[key] = value

def Options(files = None):
	""" Creates an "Autocons aware" Options object.  This essentially
	means that its an Options object with a couple default options that
	make configuring Autocons easy for the user of your build system (ie. 
	not the developer). """

	from SCons.Options import Options
	defs = GetDefaultInstallPathes()
	opts = Options(files)
	opts.Add('CC', 'The C Compiler')
	opts.Add('CXX', 'The C++ Compiler')
	opts.Add('AC_PREFIX', 'The install prefix (ex. /usr/local)', defs['AC_PREFIX'])
	opts.Add('AC_EXECPREFIX', 'The executable prefix (ex. /usr/local)', defs['AC_EXECPREFIX'])
	opts.Add('AC_LIBDIR', 'The library install directory (ex. $AC_PREFIX/lib)', defs['AC_LIBDIR'])
	opts.Add('AC_IMPORTDIR', 'The import install directory (only some platform: win32)', defs['AC_IMPORTDIR'])
	opts.Add('AC_INCLUDEDIR', 'The include files install directory (ex. $AC_PREFIX/include)', defs['AC_INCLUDEDIR'])
	opts.Add('AC_DATADIR', 'The shared data install directory (ex. $AC_PREFIX/share)', defs['AC_DATADIR'])
	opts.Add('AC_BINDIR', 'The binary program install directory (ex. $AC_PREFIX/bin)', defs['AC_BINDIR'])
	opts.Add('AC_SBINDIR', 'The superuser program install directory (ex. $AC_PREFIX/sbin)', defs['AC_SBINDIR'])
	opts.Add('AC_MANDIR', 'The man page install directory (ex. $AC_PREFIX/man)', defs['AC_MANDIR'])
	opts.Add('AC_INFODIR', 'The info page install directory (ex. $AC_PREFIX/info)', defs['AC_INFODIR'])
	opts.Add('AC_SYSCONFDIR', 'The configuration install directory (ex. /etc)', defs['AC_SYSCONFDIR'])
	opts.Add('ENABLE_FEATURES', 'List feature names to enable', [])
	opts.Add('DISABLE_FEATURES', 'List feature names to disable (overrides enable)', [])
	return opts

def Features(env, defaults=[]):
	features = defaults[:]

	def breakup(val):
		if type(val) in types.StringTypes:
			return filter(lambda x: x.strip(), val.split(","))
		elif type(val) == types.ListType:
			return val
		else:
			raise SCons.Errors.UserError, "Bad feature value: %s" % val
		
	enable = breakup(env.get('ENABLE_FEATURES', []))
	disable = breakup(env.get('DISABLE_FEATURES', []))

	for f in enable:
		if not f in features:
			features.append(f)
	
	for f in disable:
		# NOTE: We loop to make sure that multiples are removed
		while f in features:
			features.remove(f)

	return features

class Package:
	def __init__(self, distname, path = "."):
		self.DistName = distname
		self.Root = SCons.Node.FS.default_fs.Dir(path)
		self.DistFiles = []
	
	def __str__(self):
		return self.DistName

	def BuildDist(self, env):
		DistDir = self.Root.Dir(self.DistName)
		
		# install the files into the distdir
		source_nodes = []
		for file in self.DistFiles:
			dest = os.path.join(str(DistDir), file.path)
			n = env.InstallAs(dest, file)
			source_nodes.append(n)
			env.AlwaysBuild(n)

		def DeleteSourceFunc(target, source, env, DistDir=DistDir):
			# if source is under distdir, delete whole distdir
			if source[0].is_under(DistDir):
				delme = DistDir
			else:
				delme = source[0]
			# treat directories appropriately
			if os.path.isdir(delme.path):
				shutil.rmtree(delme.path)
			else:
				os.unlink(delme.path)
		def DeleteSourceString(target, source, env, DistDir=DistDir):
			if source[0].is_under(DistDir):
				delme = DistDir
			else:
				delme = source[0]
			s = "rm "
			if os.path.isdir(delme.path):
				s = s + "-rf "
			else:
				s = s + "-f "
			return s + delme.path
		DeleteSourceAction = SCons.Action.Action(DeleteSourceFunc, DeleteSourceString)

		# check for tools to make the archive
		if 'tar' in env['TOOLS']:
			tnode_list = env.Tar(str(DistDir) + ".tar", source_nodes)
			tnode = tnode_list[0]
			tnode.add_post_action(DeleteSourceAction)
			env.AlwaysBuild(tnode)
			if 'gzip' in env['TOOLS']:
				cnode = env.Gzip(str(DistDir) + ".tar.gz", tnode)
				cnode.add_post_action(DeleteSourceAction)
				env.AlwaysBuild(cnode)
				self.dist_node = cnode
			else:
				self.dist_node = tnode
		elif 'zip' in env['TOOLS']:
			n = env.Zip(str(DistDir) + ".zip", source_nodes)
			n.add_post_action(DeleteSourceAction)
			env.AlwaysBuild(n)
			self.dist_node = n
		else:
			self.dist_node = DistDir
		
		env.Alias('dist', self.dist_node)
		return self.dist_node
	
	def AddToDist(self, *dist_files):
		for name in Autoscons.Util.flatten(dist_files):
			node = SCons.Node.FS.default_fs.File(name)
			if not node in self.DistFiles:
				self.DistFiles.append( node )

	# a logical alias
	ExtraDist = AddToDist
	
	def SearchAndAdd(self, names, dir = None, **kw):
		if type(names) != types.ListType:
			names = [ names ]
		if dir == None:
			dir = self.Root
		else:
			dir = SCons.Node.FS.default_fs.Dir(dir)
		search = Autoscons.Util.FileTreeTraverser(dir.get_abspath(), names, **kw)

		def HandleAddToDist(names, self=self):
			self.AddToDist(filter(lambda x: not os.path.isdir(x), names))
		search.Traverse(HandleAddToDist)
		
def Init(name, version, **pkg_opts):
	""" Creates a Package with the given name and version.  All extra keyword arguments are
	passed to the Package constructor.  This will make a package from the root of the source-tree
	and add a number of sensible distfiles. """

	pkg = Package(name + "-" + version, "#", **pkg_opts)

	default_deep_distfiles = [ "SConstruct", "SConscript" ]
	pkg.SearchAndAdd(map(lambda x: "^" + x + "$", default_deep_distfiles))
	pkg.SearchAndAdd(names = [], dir = "#Autoscons", ignore_patterns = [ r"\..*", r".*\.pyc", r".*\.pyo", r".*~" ], ignore_files = [ "CVS" ])

	default_top_distfiles = [ "README", "LICENSE", "INSTALL", "COPYING", "NEWS", "TODO" ]
	for f in default_top_distfiles:
		n = pkg.Root.File(f)
		if n.exists():
			pkg.AddToDist(f)
	
	return pkg

# TODO: replace with config.guess
def get_target(env):
	if env.Dictionary().has_key("TARGET"):
		return env['TARGET']
	
	# check for gcc
	child = os.popen(env['CC'] + " -dumpmachine", "r")
	target = child.readline()
	if child.close() == None:
		target = target[:-1] # remove newline
		# check for target names that are too short
		h_list = target.split("-")
		if len(h_list) == 1:
			if os.name == "dos" or os.name == "nt":
				target = "i386-pc-" + h_list[0]
			else:
				target = "unknown-unknown-" + h_list[0]
		elif len(h_list) == 2:
			if os.name == "dos" or os.name == "nt":
				target = h_list[0] + "-pc-" + h_list[1]
			else:
				target = h_list[0] + "-unknown-" + h_list[1]
		
		env['TARGET'] = target
		return target
	
	if os.name == 'nt':
		# TODO: is there a way to read the proc type? or win version?
		target = 'i386-pc-windows'
		env['TARGET'] = target
		return target
	
	if os.name == 'dos':
		target = 'i386-pc-dos'
		env['TARGET'] = target
		return target

	# TODO: this detection could problably go on for ever!
	target = 'unknown-unknown-unknown'
	env['TARGET'] = target
	return target	
	
class ConfHeader:
	""" Used to generate a configure header. """

	def __init__(self):
		self.node = None
		self.defines = []
	
	def Build(self, env, header_file):
		# add the custom builders
		new_env = env.Copy()
		Autoscons.Builder.ExtendEnvironment(new_env)

		self.node = new_env.ConfigHeader(header_file, source = [ SCons.Node.Python.Value(self.defines) ])
		return self.node
	
	def Copy(self):
		temp = ConfHeader()
		temp.defines = self.defines[:]
		return temp
	
	def Define(self, name, value=1, description=None):
		self.defines.append((name, str(value), description))
	
	def DefineQuoted(self, name, value, description=None):
		self.defines.append((name, "\"%s\"" % str(value), description))
	
	DefineUnquoted = Define

	def GetCPPFlags(self):
		qd = []
		for name, value, desc in self.defines:
			# double quote
			if value[0] == '"' and value[-1] == '"':
				temp = "\"\\\"%s\\\"\"" % value[1:-1]
			else:
				temp = value
			qd.append("-D%s=%s" % (name, temp))
		return string.join(qd)

# TODO: To really, really get the ACObject dependancies right we have to use the 
# SCons build engine more.  What we need to do is make a builder for ACLibrary
# and have the ACObject style dependancies held in an environment variable.  Then
# we can use a Scanner to determine which nodes depend on which and an environment
# function (like $_concat()) or simply an early build action to expand the 
# dependancies at build time.  This is The Right Way (tm)!

class ACObject:
	def __init__(self, env, target, deps=None, **kw):
		""" The base class to all Autocons generated objects. """
		self.env = apply(env.Copy, [], kw)
		_build_install_pathes(self.env)
		Autoscons.Builder.ExtendEnvironment(self.env)
		
		self.target = target
		self.owner = 0
		self.building = 0
		
		self.dependancies = []
		if deps != None:
			self.Depends(deps)

		self.install_node = []
	
	def _install(self, target, sources):
		if type(sources) != types.ListType:
			sources = [ sources ]
		rnodes = []
		for f in sources:
			# NOTE: I wish this would work by using the construction variables in
			# the path name but for now just subst the string
			# TODO: make a special node type that uses the construction variables 
			# to resolve actual path.
			inst_target = self.env.Install(self.env.subst(target), f)
			#inst_target = self.env.Install(target, f)
			rnodes.append(inst_target)
		self.install_node = self.install_node + rnodes
		return rnodes
		
	def _preBuild(self, target, source, env, **kw):
		# TODO: for what ever reason the caching system here fails! Removed until
		# further notice.
		#
		#if not self.building:
		#	# execute this if it is the first time this object is being built
		#	
		#	# calculate dependancies
		#	for d in self.dependancies:
		#		d.ApplyDependToObject2(self, env)
		#	# cache the build environment for later use
		#	self.build_env = env
		#
		#	# mark as building
		#	self.building = 1
		#else:
		#	# execute this on all subsequent builds of this object
		#	
		#	# use cached build environment
		#	env.Replace(**self.build_env.Dictionary())

		# calculate dependancies
		for d in self.dependancies:
			#print "Depends:", d.target
			d.ApplyDependToObject2(self, env)

		# TODO: based on the output I get from uncommenting this, it seems that all the objects that
		# depend on a node will add a pre-action and that all there changes get integrated!  From what
		# I can tell so far this isn't dangerous but I don't like it...  Maybe this is the key to the
		# caching problem described above?
		#
		#print "build", self.target,
		#if env.has_key('LIBPATH'):
		#	print env['LIBPATH']
	
	def _postBuild(self, target, source, env, **kw):
		if self.building:
			# stop the build
			del self.build_env
			self.building = 0
		
	def ApplyDependToObject1(self, acobject, env):
		""" Used by a child class to set-up the given Environment for the given object to
		depend correctly on this object.  This is called when the object is added via 
		ACObject.Depends() and "env" == "acobject.env". """
		pass
	
	def ApplyDependToObject2(self, acobject, env):
		""" Used by a child class to set-up the given Environment for the given object to 
		depend correctly on this object.  Warning: The argument "env" is not the same as
		"acobject.env"!  "env" is instead the build environment.  This gets called before
		the object is actually built.  """
		pass
	
	def Depends(self, deps):
		if type(deps) != types.ListType:
			deps = [ deps ]
		for d in deps:
			# NOTE: we need this so that we can get scons build dependancies right.  If all
			# the dependancies are added build time, scons won't know to build its dependancies
			# first because it has already commited to building the current file!
			d.ApplyDependToObject1(self, self.env)
			self.dependancies.append(d)
		
	def __setitem__(self, key, value):
		self.env[key] = value
		
	def __getitem__(self, key):
		return self.env[key]

	def __delitem__(self, key):
		del self.env[key]
	
class Library(ACObject):
	def __init__(self, env, target, depends=None, **kw):
		""" Creates a Library object representing a shared or static system
		library.  This object can represent another library that exists on
		the system that SCons had nothing to do with or act as the build 
		instructions for it.  The *_prefix variables are install directories
		for the library components.  Use enviroment variables to set the paths
		that the library reads from.  The dep_* variables are used to add to
		the environment of a program or library that depends on this one. """
		
		ACObject.__init__(self, env, target, depends, **kw)
		self.owner = 0
		self.dep_flags = { 'LIBS': [], 'LIBPATH': [], 'CPPPATH': [], 'CPPFLAGS': "", \
				   'DEFINES': [], 'SHLINKFLAGS': "", 'LINKFLAGS': "", 'LIBFLAGS': "" }

		# HACK: a hack to try and know the directory before the object is built
		self.cwd = SCons.Node.FS.default_fs.getcwd().path
		
		# a hack to get the excess libflags added to _LIBFLAGS
		self.env['AC_LIBFLAGS'] = ""
		self.env.Append(_LIBFLAGS = " ${AC_LIBFLAGS}")

	def GetPath(self):
		if self.owner:
			if type(self.bin_node) == types.ListType:
				return str(self.bin_node[0])
			else:
				return str(self.bin_node)
		return None
	
	def GetDir(self):
		path = self.GetPath()
		if path:
			return os.path.dirname(path)
		else:
			return self.cwd

	def _BuildDefString(self, target, source, env):
		return "Creating library: %s" % target[0]
	
	def _BuildDefFunc(self, target, source, env):
		fd = open(str(target[0]), "w")
		fd.write("# This is a library definition file automatically generated by Autocons!\n")
		fd.write("# The format for this file is yet undefined.\n\n")
		fd.close()
	
	def Build(self, source, headers, version = None, install = 0, build_shared = 1, build_static = 0, package = None, **kw):
		""" Uses the current environment to build and install the library in question. """

		have_gcc = "gcc" in self.env['TOOLS']

		# add the extra keywords to the environment
		for key, value in kw.items():
			self.env[key] = value

		# expand all the AC_* variables at this point because
		# we need to use them in there expanded form in many
		# places and after this point, they are set in stone
		for key, value in self.env.items():
			if key[:3] == "AC_":
				if value != None:
					self.env[key] = self.env.subst(value)

		# since we are actually building this library, mark as owner and set information
		# about how this object is being built.
		self.owner = 1
		self.install = install
		self.build_static = build_static
		self.build_shared = build_shared
		self.version = version
		
		if build_shared == 0 and build_static == 0:
			raise SCons.Errors.UserError, "Library is set not to build shared or static."

		# build the source nodes
		source_node = []
		for s in source:
			n = self.env.SharedObject(target = str(s).split('.')[0], source = s)
			source_node.append(n)

		# build the library
		self.node = []
		if build_static:
			self.static_node = self.env.StaticLibrary(target = self.target, source = source_node)
			self.bin_node = self.static_node
			if type(self.static_node) == types.ListType:
				self.node.extend(self.static_node)
			else:
				self.node.append(self.static_node)
		if build_shared:
			if os.name == "posix" and version != None:
				# get the version
				if version != None:
					if type(version) in types.StringTypes:
						version = version.split(".")
				if version == None or len(version) < 3:
					raise SCons.Errors.UserError, "Library needs a valid three part version number!"
				
				if have_gcc:
					# NOTE: this is necessary for doing linking to a library
					# before it is installed.
					self.env.Append(SHLINKFLAGS = " -Wl,-soname -Wl,${TARGET.file}")

				# under posix we build versioned shared libraries
				posix_target = self.env.subst("${SHLIBPREFIX}" + self.target + "-%s.%s${SHLIBSUFFIX}.%s" % version)
				self.shared_node = self.env.SharedLibrary(SCons.Node.FS.default_fs.File(posix_target), source = source_node)
				# and symlinks
				for link in [ \
					self.env.subst("${SHLIBPREFIX}" + self.target + "-%s.%s${SHLIBSUFFIX}" % version[:2]), \
					self.env.subst("${SHLIBPREFIX}" + self.target + "-%s${SHLIBSUFFIX}" % version[0]), \
					self.env.subst("${SHLIBPREFIX}" + self.target + "${SHLIBSUFFIX}") ]:

					n = self.env.Symlink(link, [ self.shared_node ])
					self.node.append(n)
					if install:
						bname = os.path.basename(str(self.shared_node))
						n = self.env.Symlink(os.path.join(self.env['AC_LIBDIR'], link), os.path.join(self.env['AC_LIBDIR'], bname))
						self.install_node.append(n)
			else:
				self.shared_node = self.env.SharedLibrary(target = self.target, source = source)

			# shared node over powers static node
			self.bin_node = self.shared_node
			if type(self.bin_node) == types.ListType:
				self.node.extend(self.shared_node)
			else:
				self.node.append(self.shared_node)
							
		if install:
			# install the library
			if build_shared:
				self._install("$AC_LIBDIR", self.shared_node)
			if build_static:
				self._install("$AC_LIBDIR", self.static_node)

			# install the headers
			# NOTE: I don't think this is a sane add-on
			#self.env["AC_INCLUDEDIR"] = os.path.join(self.env["AC_INCLUDEDIR"], self.target)
			self._install("$AC_INCLUDEDIR", headers)

			# install the import library (if there is one)
			if os.name == 'nt':
				pass
				# TODO: make a node for the import!
				#MyPackage.env.Install("AC_IMPORTDIR", self.import_node)
				#env.Alias('install', self.importdir)

			# make fake install target
			self.env.Alias('install_' + self.target, self.install_node)

		# dist
		if package:
			package.AddToDist(source)
			package.AddToDist(headers)

		# the output node
		lx_node = self.env.Command(self.target + ".lx", [], \
			SCons.Action.Action(self._BuildDefFunc, self._BuildDefString))
		for n in self.node:
			self.env.Depends(lx_node, n)
		self.node.append(lx_node)

		# add the dependancy actions
		pre_action = SCons.Action.Action(self._preBuild, None)
		post_action = SCons.Action.Action(self._postBuild, None)
		for d in self.node:
			d.add_pre_action(pre_action)
		for s in source_node:
			s.add_pre_action(pre_action)
		lx_node.add_post_action(post_action)

		return self.node

	def _decoder(self):
		""" Creates a dict of environment variables to replace the existing
		ones in the case that we are making a config file/script. """

		dec = {}
		if self.build_shared:
			dec['LIBRARY'] = self.env.subst("${SHLIBPREFIX}%s${SHLIBSUFFIX}" % self.target)
		else:
			dec['LIBRARY'] = self.env.subst("${LIBPREFIX}%s${LIBSUFFIX}" % self.target)
		dec['VERSION'] = string.join(map(lambda x: str(x), self.version), '.')
		dec['LIB_TARGET'] = self.target
		dec['LIB_TARGET_UPPER'] = self.target.upper()
		for key, value in self.dep_flags.items():
			if key == 'LIBPATH':
				self.env['_DEP_LIBPATH'] = value
				dec['DEP_LIBPATH'] = self.env.subst('${_concat(LIBDIRPREFIX, _DEP_LIBPATH, LIBDIRSUFFIX, __env__)}')
				del self.env['_DEP_LIBPATH']
			elif key == 'CPPPATH':
				self.env['_DEP_CPPPATH'] = value
				dec['DEP_CPPPATH'] = self.env.subst('${_concat(INCPREFIX, _DEP_CPPPATH, INCSUFFIX, __env__)}')
				del self.env['_DEP_CPPPATH']
			elif key == 'LIBS':
				self.env['_DEP_LIBS'] = value
				dec['DEP_LIBS'] = self.env.subst('${_concat(LIBLINKPREFIX, _DEP_LIBS, LIBLINKSUFFIX, __env__)}')
				del self.env['_DEP_LIBS']
			else:
				dec['DEP_' + key] = value
		dec['LIB_LIBS'] = self.env.subst("$_LIBFLAGS")
		dec['LIB_LIBPATH'] = self.env.subst("$_LIBDIRFLAGS")
		dec['LIB_CPPPATH'] = self.env.subst("$_CPPINCFLAGS")

		# copy the AC_* variables into the decoder
		for key, value in self.env.items():
			if key[:3] == "AC_":
				dec[key] = value
		
		return dec
	
	def BuildConfigScript(self, target = None, install = 1):
		if not self.owner:
			raise SCons.Errors.UserError, "Cannot build a *-config script without first calling Build() for this library"
		if target == None:
			target = self.target + "-config"
		conf_node = self.env.ExpandTemplate(target = target, source = [ Template('config-script') ], DECODER = self._decoder(), PERMISSION = 0755)
		self._install("$AC_BINDIR", conf_node)
		return conf_node
	
	def BuildAutoconfM4(self, target = None, install = 1):
		if not self.owner:
			raise SCons.Errors.UserError, "Cannot build an Autoconf M4 file without first calling Build() for this library"
		if target == None:
			target = self.target + ".m4"
		conf_node = self.env.ExpandTemplate(target = target, source = [ Template('autoconf.m4') ], DECODER = self._decoder())
		self._install(os.path.join("$AC_DATADIR", "autoconf"), conf_node)
		return conf_node
	
	def ApplyDependToEnv(self, env):
		""" Adds the depflags of this library to an environment.  This function performs
		a very simple task that is in its own function simply so that you can use the 
		configure aspects of Autcons without using ACObject and family.  Otherwise, calling
		Depends() is more appropriate. """
		
		# change 'LIBFLAGS' to '_LIBFLAGS'.  At this point we can assume that
		# we are using either SCons or A-A-P with an SCons engine.
		dep_flags = self.dep_flags.copy()
		dep_flags['_LIBFLAGS'] = dep_flags['LIBFLAGS']
		del dep_flags['LIBFLAGS']
		apply(env.Append, [], dep_flags)
		
		target_type = string.split(get_target(env), "-")[2]

		# NOTE: on linux, you must include the dependancies of your dependancies
		# as well (a property of ld-linux.so).
		if target_type == "linux":
			if self.env.Dictionary().has_key('LIBS'):
				env.Append(LIBS = self.env['LIBS'])
			if self.env.Dictionary().has_key('LIBPATH'):
				env.Append(LIBPATH = self.env['LIBPATH'])
			if self.env.Dictionary().has_key('ACLIBFLAGS'):
				env.Append(ACLIBFLAGS = self.env['ACLIBFLAGS'])

		if self.owner:
			env.Append(LIBS = [ self.target ])

	def ApplyDependToObject1(self, acobject, env):
		if self.owner:
			# look for the version of the library that we built first
			env.Prepend(LIBPATH = [ self.GetDir() ])
			env.Append(LIBS = [ self.target ])
		
	def ApplyDependToObject2(self, acobject, env):
		self.ApplyDependToEnv(env)
		
		have_gcc = "gcc" in self.env['TOOLS']
		
		# NOTE: Does this do anything?
		# for posix systems we must have the final paths of the lib built-in
		if self.owner and self.env['PLATFORM'] == 'posix':
			# TODO: this only works with gcc!! Add a check for gcc.
			# link to the local version of a library but tell the dynamic linker 
			# to really look in the installdir when actually run
			if self.install and (acobject.owner and acobject.install):
				ldflags = " -Wl,-rpath -Wl," + self.env["AC_LIBDIR"] + " -L" + self.env["AC_LIBDIR"] + " " + self.GetPath()
			else:
				#ldflags = " -L" + os.path.dirname(self.GetPath()) + " " + self.GetPath()
					# + os.path.join(MyPackage.Root, self.GetPath())
				ldflags = ""
			env.Append(AC_LIBFLAGS = ldflags)

			# in this case, scons doesn't see the dependancy on the library, so we
			# must add it explicitly!
			# TODO: Ooops!  We can't do this without access to the actual node!

	def ReadDepConfig(self, dep_cflags, dep_libs):
		arg_type = None
		for arg in dep_cflags.split():
			if arg_type != None:
				if arg_type == "-I":
					self.dep_flags['CPPPATH'].append(arg)
				elif arg_type == "-D":
					self.dep_flags['DEFINES'].append(arg)
				arg_type = None
			elif arg[:2] == "-I":
				if len(arg) == 2: arg_type = "-I"
				else: self.dep_flags['CPPPATH'].append(arg[2:])
			elif arg[:2] == "-D":
				if len(arg) == 2: arg_type = "-D"
				else: self.dep_flags['DEFINES'].append(arg[2:])
			else:
				self.dep_flags['CPPFLAGS'] += " " + arg
		for arg in dep_libs.split():
			if arg_type != None:
				if arg_type == "-L":
					self.dep_flags['LIBPATH'].append(arg)
				elif arg_type == "-l":
					self.dep_flags['LIBS'].append(arg)
				arg_type = None
			elif arg[:2] == "-L":
				if len(arg) == 2: arg_type = "-I"
				else: self.dep_flags['LIBPATH'].append(arg[2:])
			elif arg[:2] == "-l":
				if len(arg) == 2: arg_type = "-l"
				else: self.dep_flags['LIBS'].append(arg[2:])
			else:
				#self.dep_flags['SHLINKFLAGS'] += " " + arg
				#self.dep_flags['LINKFLAGS'] += " " + arg
				
				# HACK: this is a hack to get the --rpath stuff into
				# the libflags instead of right after the compiler.
				# The flag name used here is "LIBFLAGS" which is 
				# actually changed before being appended to an 
				# environment to "_LIBFLAGS".  This is because the
				# name "_LIBFLAGS" only makes sense to SCons users and
				# I want to foster A-A-P interest.
				self.dep_flags['LIBFLAGS'] += " " + arg
	
class Program(ACObject):
	def __init__(self, env, target, depends=None, **kw):
		""" Creates a program definition. """
		ACObject.__init__(self, env, target, depends, **kw)

		self.owner = 0
	
	def Build(self, source, install=0, package=None, **kw):
		# since we are building this program, mark as owner and set build info
		self.owner = 1
		self.install = install

		# add the extra keywords to the environment
		for key, value in kw.items():
			self.env[key] = value
		
		# build the source node
		source_node = []
		for s in source:
			n = self.env.Object(target = str(s).split('.')[0], source = s)
			source_node.append(n)
		
		self.node = self.env.Program(target=self.target, source=source_node)

		if install:
			self._install('$AC_BINDIR', self.node)

			# make fake install target
			self.env.Alias('install_' + self.target, self.install_node)

		# dist 
		if package:
			package.AddToDist(source)

		# TODO: maybe move some of this up into ACObject
		# add the dependancy actions
		pre_action = SCons.Action.Action(self._preBuild, None)
		post_action = SCons.Action.Action(self._postBuild, None)
		for s in source_node:
			s.add_pre_action(pre_action)
		self.node.add_pre_action(pre_action)
		self.node.add_post_action(post_action)


