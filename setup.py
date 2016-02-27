#!/usr/bin/env python

error = ""

import os, subprocess, sys, struct
try:
	import ConfigParser as configparser
except:
	import configparser
from distutils import log, dir_util, sysconfig
try:
	from setuptools import setup
	from setuptools.command.install import install
except ImportError:
	error += "ImportError: setuptools not found (https://pypi.python.org/pypi/setuptools)\n"

if error:
	sys.exit(error)

class CustomInstall(install):

	def run(self):

		install.run(self)

		data_home = os.path.join("lass", "data")
		lua_home = "lib"

		destination = self.install_lib
		data_destination = os.path.join(destination, "lass", "data")

		if os.name == "posix" or sys.platform == "cygwin":

			#if lua5.1 is installed, put lass lib in /usr
			if not subprocess.call(["which", "lua5.1"], stdout=open(os.devnull, "w"), close_fds=True) or (
				not subprocess.call(["which", "lua"], stdout=open(os.devnull, "w"), close_fds=True) and
				subprocess.check_output(["lua", "-v"]).startswith("Lua 5.1")
			):
				lua_destination = os.path.join(sys.prefix, "local", "share", "lua", "5.1")
			#if lua is not installed, put lass lib in package directory
			else:
				lua_destination = os.path.join(data_destination, "lua", "5.1")

		else:
			lua_destination = os.path.join(data_destination, "lua", "5.1")

		#copy all data and lua files
		dir_util.copy_tree(data_home, data_destination, update=1, preserve_mode=1)
		dir_util.copy_tree(lua_home, lua_destination, update=1, preserve_mode=1)

		if sys.platform.startswith("win32"):
			log.info("done")
			return

		#ensure that the original owner, not just the root user, owns the new data files
		UID = os.stat(data_home).st_uid
		GID = os.stat(data_home).st_gid

		log.info("changing owner of data files to %s" % UID)
		for root, dirs, files in os.walk(data_destination):
			# log.info("changing owner of %s to %d" % (root, UID))
			os.chown(root, UID, GID)
			for f in files:
				# log.info("changing owner of %s to %d" % (os.path.join(root, f), UID))
				os.chown(os.path.join(root, f), UID, GID)
		log.info("done")

setup(
	name = "lass",
	version = "0.1.0.dev0",
	author = "Decky Coss",
	author_email = "coss@cosstropolis.com",
	description = "A modular development kit for 2D videogames.",
	packages = ["lass", "lass.gui", "lass.gui.ui"],
	install_requires = ["jinja2", "lupa", "six", "pyside"],
	scripts = [os.path.join("bin", "lasspm"), os.path.join("bin", "lass")],
	cmdclass = {"install": CustomInstall},
	include_package_data=True
)
