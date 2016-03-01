#!/usr/bin/env python

error = ""

import os, subprocess, sys
from distutils import log, dir_util, sysconfig
try:
	from setuptools import setup, Command
	from setuptools.command.install import install
	from setuptools.command.bdist_egg import bdist_egg
except ImportError:
	error += "ImportError: setuptools not found (https://pypi.python.org/pypi/setuptools)\n"

if error:
	sys.exit(error)

class CustomBdistEgg(bdist_egg):

	user_options = bdist_egg.user_options + [
		("install-lua-libs", None, "Install the Lua libraries to the system Lua lib directory")
	]

	def initialize_options(self):

		bdist_egg.initialize_options(self)
		self.install_lua_libs = False

	def run(self):

		bdist_egg.run(self)

		if self.install_lua_libs:
			self.run_command("install_lua_libs")

class InstallLualibs(Command):

	user_options = []

	def initialize_options(self):
		pass

	def finalize_options(self):
		pass

	def run(self):

		if not (os.name == "posix" or sys.platform == "cygwin"):
			log.error("Error: install_lua_libs is not supported on Windows")
			return

		lua_destination = os.path.join(sys.prefix, "local", "share", "lua", "5.1")

		self.execute(dir_util.copy_tree, (
			os.path.join("lass", "data", "lua", "5.1"),
			lua_destination,
			1, #preserve mode
			1, #preserve times
			0, #preserve symlinks
			1 #update
		), "copying Lua libraries to {0}".format(lua_destination))

class CustomInstall(install):

	user_options = install.user_options + [
		("install-lua-libs", None, "Install the Lua libraries to the system Lua lib directory")
	]

	def initialize_options(self):

		install.initialize_options(self)
		self.install_lua_libs = False

	def finalize_options(self):

		install.finalize_options(self)
		if self.install_lua_libs:
			#TODO: figure out how to get this to work in install.run
			self.run_command("install_lua_libs")

setup(
	name = "lass",
	version = "0.1.0.dev0",
	author = "Decky Coss",
	author_email = "coss@cosstropolis.com",
	description = "A modular development kit for 2D videogames.",
	packages = ["lass", "lass.gui", "lass.gui.ui"],
	install_requires = ["jinja2", "lupa", "six", "PySide"],
	scripts = [os.path.join("bin", "lasspm"), os.path.join("bin", "lass")],
	cmdclass = {
		"bdist_egg": CustomBdistEgg,
		"install": CustomInstall,
		"install_lua_libs": InstallLualibs
	},
	include_package_data=True
)
