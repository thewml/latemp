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

import re, os, string, types

class FileTreeTraverser:
	def __init__(self, root, match_patterns = [], ignore_pathes = [], ignore_files = [], ignore_patterns = []):
		self.Root = root
		self.IgnorePathes = ignore_pathes
		self.IgnoreFiles = ignore_files

		self.MatchPatterns = []
		for p in match_patterns:
			self.MatchPatterns.append(re.compile(p))
		self.IgnorePatterns = []
		for p in ignore_patterns:
			self.IgnorePatterns.append(re.compile(p))
	
	def match(self, pattern_list, s):
		for p in pattern_list:
			if p.match(s):
				return 1
		return 0
	
	def _visit(self, handler, path, names):
		# make a path relative to the top level dir
		# TODO: make this _ACTUALLY_ work with pathes instead of making
		# assumptions about the format of the string it is passed
		rel_path = path[len(self.Root) + 1:]
		
		full_names = []
		# remove ignored files
		for child in names[:]:
			fp = os.path.join(path, child)

			if os.path.join(rel_path, child) in self.IgnorePathes or \
			   child in self.IgnoreFiles or \
			   self.match(self.IgnorePatterns, child) or \
			   (not os.path.isdir(fp) and len(self.MatchPatterns) > 0 and not self.match(self.MatchPatterns, child)): 
			   	names.remove(child)
			else:
				full_names.append(fp)

		# call the handler
		handler(map(lambda x, path=path: os.path.join(path, x), names))

	def Traverse(self, handler):
		os.path.walk(self.Root, self._visit, handler)

class CollectFileHandler:
	def __init__(self):
		self.Filenames = []
	
	def __call__(self, names):
		self.Filenames += names

def Find(*args, **kw):
	handler = CollectFileHandler()
	traverser = apply(FileTreeTraverser, args, kw)
	traverser.Traverse(handler)
	return handler.Filenames

def MakeRelativePath(path, base):
	split_path = path.split(os.sep)
	split_base = base.split(os.sep)
	cwd = os.getcwd()

	# remove common portions
	for part in split_path[:]:
		if len(split_base) == 0:
			break
		if part == split_base[0]:
			del split_base[0]
			del split_path[0]
	
	# return reconstituted relative path
	return string.join(split_path, os.sep)

def flatten(lst):
	temp = []
	for l in lst:
		if type(l) is types.ListType:
			temp.extend(flatten(l))
		else:
			temp.append(l)
	return temp

def OpenProcess(process):
	""" Reads the standard output of a process, attempting to hide the 
	standard error stream if the platform allows.  Returns a tuple 
	containing 1 and a buffered file object on success and (0, None) on
	failure. """

	if os.name == 'posix':
		# use popen2.Popen3 to discard the stderr
		from popen2 import Popen3
		pobj = Popen3(process, 1)
		data = pobj.fromchild.read()
		ret = pobj.wait()
		if not (os.WIFEXITED(ret) and os.WEXITSTATUS(ret) == 0):
			return (0, None)
	elif os.name in ('nt', 'dos'):
		# use a temp file redirect the stderr into oblivion
		from tempfile import mktemp
		path = mktemp()
		stdout = os.popen(process + " 2>" + path, "rt")
		data = stdout.read()
		if stdout.close() != None:
			ret = 0
		else:
			ret = 1
		if os.path.exists(path):
			os.unlink(path)
		if not ret:
			return (0, None)
	else:
		# unable to redirect, just execute
		stdout = os.popen(process)
		data = stdout.read()
		if stdout.close() != None:
			return (0, None)
	
	try:
		from cStringIO import StringIO
	except ImportError:
		from StringIO import StringIO
	
	return (1, StringIO(data))

VersionError = "Autoscons.Configure.VersionError"
def SplitVersion(version_string):
	def SplitExtra(str):
		index = str.find("-")
		if index == -1:
			return (str, "")
		else:
			return (str[:index], str[index + 1:])
	
	split_version = version_string.split(".")
	try:
		if len(split_version) == 1:
			major, extra = SplitExtra(version_string)
			return (int(major), 0, 0, extra)
		elif len(split_version) == 2:
			major, minor = split_version
			minor, extra = SplitExtra(minor)
			return (int(major), int(minor), 0, extra)
		elif len(split_version) == 3:
			major, minor, revision = split_version
			revision, extra = SplitExtra(revision)
			return (int(major), int(minor), int(revision), extra)
		else:
			raise VersionError, "Unable to handle version with %i parts: %s" % (len(split_version), version_string)
	except ValueError:
		raise VersionError, "Bad version string: " + version_string
	
def CheckVersion(version_string, min_version_string):
	version = SplitVersion(version_string)
	min_version = SplitVersion(min_version_string)

	if version[0] >= min_version[0] and \
	   version[1] >= min_version[1] and \
	   version[2] >= min_version[2]:
		return 1
	return 0


