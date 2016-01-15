#!/usr/bin/env python

error = ""

import os, subprocess, sys, struct
try:
	import ConfigParser as configparser
except:
	import configparser
from distutils import log
try:
	from setuptools import setup
	from setuptools.command.install import install
except ImportError:
	error += "ImportError: setuptools not found (https://pypi.python.org/pypi/setuptools)\n"
if sys.platform.startswith("win32"):
	try:
		import py2exe
	except ImportError:
		error += "ImportError: py2exe not found (http://www.py2exe.org)\n"

if error:
	sys.exit(error)

def listAll(dir, joinBase=False, headPrefix="", filePrefix=""):
	"""
	return all files as list of tuples, where first element is prefix
	and second element is list of files in current directory

	parameters:
		joinBase: if True, set the second element to full path name instead of base name
		headPrefix: prefix for the first element of each tuple
		filePrefix: prefix for each file of the second element of each tuple (after joinBase is applied)
	"""

	allFiles = []

	for i, wtup in enumerate(os.walk(dir)):
		head = os.path.join(headPrefix, wtup[0])

		files = []
		for j, f in enumerate(wtup[2]):
			if j == 0:
				#we do this here instead of before the loop so there are no empty lists
				allFiles.append((head, files))
			if joinBase:
				f = os.path.join(wtup[0], f)
			files.append(os.path.join(filePrefix, f))

	return allFiles

#if using posix, we'll move all data and lua files according to XDG spec
if os.name == "posix" or sys.platform == "cygwin":

	cparser = configparser.ConfigParser()
	cparser.add_section("path")
	cparser.set("path", "DIR_LASS_DATA", "$XDG_DATA_HOME/Lass;$HOME/.local/share/Lass;$HOME/.Lass")

	if not cparser.read(os.path.join("conf", "lassconf.ini")):
		log.warn("Warning: config/lassconf.ini not found")

	for d in cparser.get("path", "DIR_LASS_DATA").split(";"):
		d = os.path.expanduser(os.path.expandvars(d))
		DIR_LASS_DATA = d
		if os.path.exists(os.path.dirname(d)):
			break

	for d in ["$XDG_CONFIG_HOME/Lass", "$HOME/.config/Lass"]:
		d = os.path.expanduser(os.path.expandvars(d))
		print d
		DIR_LASS_CONF = d
		if os.path.exists(os.path.dirname(d)):
			break

	#if lua5.1 is installed, put lass lib in /usr
	if not subprocess.call(["which", "lua5.1"], stdout=open(os.devnull, "w"), close_fds=True) or (
		not subprocess.call(["which", "lua"], stdout=open(os.devnull, "w"), close_fds=True) and
		subprocess.check_output(["lua", "-v"]).startswith("Lua 5.1")
	):
		DIR_LUA = os.path.join(sys.prefix, "local", "share", "lua", "5.1")
	#if lua is not installed, put lass lib in XDG_DATA_HOME
	else:
		DIR_LUA = os.path.join(DIR_LASS_DATA, "lua", "5.1")

#if using windows, we'll just put everything in the program folder
#TODO: detect if lua is installed
elif sys.platform.startswith("win32"):
	DIR_LASS_DATA, DIR_LASS_CONF = "", ""
	DIR_LUA = os.path.join("lua", "5.1")

else:
	sys.exit("OS Error: Operating system not supported")

os.chdir("data")
DATA_FILES =\
	reduce(lambda a,b: a + b, [
		listAll(x, True, DIR_LASS_DATA, "data") for x in (
			"examples", "engine", "templates", "docs", "tests"
		)
	])

os.chdir(os.path.join("..", "lib"))
DATA_FILES += listAll("lass", True, headPrefix=DIR_LUA, filePrefix="lib")
os.chdir(os.path.join("..", "conf"))
DATA_FILES += listAll(".", headPrefix=DIR_LASS_CONF, filePrefix="conf")

os.chdir("..")

#find the owner of a data file; assume for now that all data files share this owner
UID = os.stat(DATA_FILES[0][1][0]).st_uid
GID = os.stat(DATA_FILES[0][1][0]).st_gid

class CustomInstall(install):

	def run(self):
		if sys.platform.startswith("win32"):
			sys.exit("Error: 'install' command not available for Windows. Use 'py2exe' command instead")

		install.run(self)

		#ensure that the original owner, not just the root user, owns the new data files
		log.info("changing owner of data files to %s" % UID)
		for root, dirs, files in os.walk(DIR_LASS_DATA):
			# log.info("changing owner of %s to %d" % (root, UID))
			os.chown(root, UID, GID)
			for f in files:
				# log.info("changing owner of %s to %d" % (os.path.join(root, f), UID))
				os.chown(os.path.join(root, f), UID, GID)
		log.info("done")

options = {}
if sys.platform.startswith("win32"):
	scripts = []
	console = [os.path.join("bin", "lasspm")]

	# if python is 32-bit, enable bundle_files
	if struct.calcsize("P") == 4:
		options["py2exe"] = {'bundle_files': 1, 'compressed': True}
else:
	scripts = [os.path.join("bin", "lasspm")]
	console = []

setup(
	name = "lass",
	version = "0.1.0.dev0",
	author = "Decky Coss",
	author_email = "coss@cosstropolis.com",
	description = "A modular development kit for 2D videogames.",
	packages = ["lass"],
	install_requires = ["jinja2", "lupa"],
	scripts = scripts,
	console = console,
	data_files = DATA_FILES,
	cmdclass = {"install": CustomInstall},
	options = options,
	zipfile = None
)
