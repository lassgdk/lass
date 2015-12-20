#!/usr/bin/env python

# Copyright 2014, 2015 Decky Coss

# This file is part of Lass.

# Lass is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Lass is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with Lass.  If not, see <http://www.gnu.org/licenses/>.

from __future__ import print_function, unicode_literals
import os, sys, shutil, zipfile, subprocess
try:
	import ConfigParser as configparser
except:
	import configparser
import lupa
from lass import luatools, six

#set a bunch of global constants

#load config file
#if on windows, look in directory where lasspm lives
if sys.platform == "win32":
	# XDG_CONFIG_HOME = os.path.dirname(os.path.realpath(__file__))
	DIR_LASS_CONF = os.path.dirname(os.path.realpath(sys.argv[0]))
#else, look in the $HOME directory
else:
	try:
		XDG_CONFIG_HOME = os.environ["XDG_CONFIG_HOME"]
	except KeyError:
		XDG_CONFIG_HOME = os.path.join(os.environ["HOME"], ".config")
	DIR_LASS_CONF = os.path.join(XDG_CONFIG_HOME, "Lass")

cparser = configparser.ConfigParser({
	"DIR_LASS_DATA":"$XDG_DATA_HOME/Lass",
	"FB_DIR_LASS_DATA":"$HOME/.local/share/Lass",
	"DIR_PROJECTS":"$HOME/Documents/Lass"
})
if not cparser.read(os.path.join(DIR_LASS_CONF, "lassconf.ini")):
	raise IOError(os.path.join(DIR_LASS_CONF, "lassconf.ini") + " could not be loaded")

#if windows, assume everything lives in the program folder
if sys.platform == "win32":
	DIR_LASS_DATA = DIR_LASS_CONF
	DIR_LASS_LIB = os.path.join(DIR_LASS_DATA, "lua", "5.1", "lass")
	DIR_PROJECTS = os.path.join(DIR_LASS_DATA, "projects")
	DIR_TEMP = os.path.join(DIR_LASS_DATA, "tmp")
#else, set global variables from config file
else:
	try:
		DIR_LASS_DATA = os.path.expandvars(cparser.get("path", "DIR_LASS_DATA"))
		os.listdir(DIR_LASS_DATA)
	except OSError:
		DIR_LASS_DATA = os.path.expandvars(cparser.get("path", "FB_DIR_LASS_DATA"))
	try:
		DIR_LASS_LIB = os.path.join(sys.prefix, "local", "share", "lua", "5.1", "lass")
		os.listdir(DIR_LASS_LIB)
	except OSError:
		DIR_LASS_LIB = os.path.join(DIR_LASS_DATA, "lua", "5.1", "lass")

	DIR_PROJECTS = os.path.expandvars(cparser.get("path", "DIR_PROJECTS"))
	DIR_TEMP = "/tmp"

DIR_ENGINE_WINDOWS = os.path.join(DIR_LASS_DATA, "engine", "windows")
DIR_ENGINE_OSX = os.path.join(DIR_LASS_DATA, "engine", "osx")
DIR_EXAMPLES = os.path.join(DIR_LASS_DATA, "examples")
DIR_TESTS = os.path.join(DIR_LASS_DATA, "tests")
DIR_TEMPLATES_LUA = os.path.join(DIR_LASS_DATA, "templates", "lua")

ID_WINDOWS = "w"
ID_LINUX = "l"
ID_OSX = "o"

# class ProjectManager(object):
#main functions

def buildGame(game, sendToTemp=False, projects=False, examples=False, tests=False, target="l"):
	"""
	build a .love file, plus optional binary distributions

	args:
		game: name of game project
		sendToTemp: store compiled game in temp folder
		projects: search for project in default projects folder (deprecated)
		examples: search for project in examples folder, if not found in projects
		tests: search for project in tests folder, if not found in examples
		target: target platform--must be combination of w, l, o
	"""

	if not (projects or examples or tests):
		if os.path.isabs(game):
			projPath = game
		else:
			projPath = os.path.join(os.getcwd(), game)
	#search for game in projects folder first, then examples
	else:
		if os.path.isabs(game):
			# sys.exit("OS Error: Can't use -p or -e options with absolute path")
			raise OSError("Can't use -e option with absolute path")
		dirs = []
		if projects:
			dirs.append(DIR_PROJECTS)
		if examples:
			dirs.append(DIR_EXAMPLES)
		if tests:
			dirs.append(DIR_TESTS)
		projPath = findGame(game, dirs)

	#in case game is '.', find the 'real' name
	game = os.path.basename(os.path.abspath(projPath))

	if sendToTemp:
		buildPath = DIR_TEMP
		try:
			os.listdir(DIR_TEMP)
		except OSError:
			os.mkdir(DIR_TEMP)
	else:
		buildPath = os.path.join(projPath, "build")

	sourcePath = os.path.join(projPath, "src")

	#make sure project exists and can be compiled
	try:
		if not "main.lua" in os.listdir(sourcePath):
			raise OSError("Cannot find main.lua in project")
	except OSError as e:
		raise OSError("Cannot find " + sourcePath)

	if not sendToTemp and not "build" in os.listdir(projPath):
		os.mkdir(buildPath)

	origDir = os.getcwd()

	# projFiles = os.listdir(sourcePath)
	projFiles = []
	os.chdir(sourcePath)

	for layer in os.walk("."):
		pr = layer[0]
		if pr == ".":
			pr = ""

		for d in layer[1]:
			projFiles.append(os.path.join(pr, d))
		for f in layer[2]:
			projFiles.append(os.path.join(pr, f))

	os.chdir(origDir)

	loveFileName = game + ".love"

	with zipfile.ZipFile(os.path.join(buildPath, loveFileName), mode='w') as loveFile:

		#add project files
		for f in projFiles:
			if f != "build":
				loveFile.write(os.path.join(sourcePath, f), f)

		#add lass library
		os.chdir(DIR_LASS_LIB)
		for i, wtup in enumerate(os.walk(".")):
			for j, f in enumerate(wtup[2]):
				fullName = os.path.join(wtup[0], f)
				loveFile.write(fullName, os.path.join("lass", fullName))

	os.chdir(origDir)

	if not sendToTemp:
		if "w" in target:
			buildExe(os.path.join(buildPath, loveFileName), dest=buildPath)
		elif "o" in target:
			buildApp(os.path.join(buildPath, loveFileName), dest=buildPath)

	return os.path.abspath(os.path.join(buildPath, loveFileName))

def newGame(game, projects=False):
	"""
	create a new Lass project

	args:
		game: name of new project
		projects: set location of new project to default projects folder
	"""

	if projects and game==".":
		raise OSError(
			"Cannot initiate project in %s - try supplying project name" % os.path.join(DIR_PROJECTS, game)
		)
	elif projects:
		projPath = os.path.join(DIR_PROJECTS, game)
	else:
		projPath = os.path.abspath(game)

	#make project directory
	if game!=".":
		try:
			os.mkdir(projPath)
		except OSError as e:
			raise OSError("OS Error: Cannot create directory %s" % projPath)

	#make project subdirectories
	os.chdir(projPath)

	for folder in ["build", "include", "src"]:
		try:
			os.mkdir(folder)
			print("Created {} folder".format(folder))
		except OSError:
			raise OSError("Could not create {} folder".format(folder))

	for t in ["main.lua", "settings.lua", "scene_main.lua"]:
		shutil.copy(os.path.join(DIR_TEMPLATES_LUA, t), "src")

def playGame(game, scene="", **kwargs):
	"""
	temporarily build and play a Lass project

	args:
		projects: search for project in default projects folder
		examples: search for project in examples folder, if not found in projects
	"""

	game = buildGame(game, sendToTemp=True, **kwargs)

	# argString = ""
	args = ["--scene=" + scene] if scene else []

	# os.system(getLoveEngineCommand().format(game, argString))
	proc = subprocess.Popen(getLoveEngineCommand(game, args), stdout=subprocess.PIPE)
	while proc.poll() == None:
		out = proc.stdout.readline()
		sys.stdout.write(out)
		sys.stdout.flush()

	os.remove(game)

def newPrefab(fileName):
	shutil.copy(
		os.path.join(DIR_TEMPLATES_LUA, "prefab.lua"),
		os.path.join("src", fileName)
	)

def loadScene(fileName):

	lua = lupa.LuaRuntime(unpack_returned_tuples=True)
	lua.execute("t = loadfile('{}')".format(fileName))
	scene = None

	if lua.globals().t:
		try:
			scene = lua.globals().t()
		except lupa.LuaError as e:
			raise e("Could not parse " + fileName)
	else:
		raise OSError("{} not found".format(fileName))

	return _luaTableToObjectList(scene.gameObjects)

#helper functions

def _luaTableToObjectList(table):

	gameObjects = []

	for node in table:
		o = {"data": {
			"name": six.text_type(node.name) or "",
			"components": luatools.luaTableToDict(node.components) or {},
			"transform": luatools.luaTableToDict(node.transform) or {}
		}}

		o["children"] = _luaTableToObjectList(node.children)

		gameObjects.append(o)

	return gameObjects

def findGame(game, *folders):
	"""
	search through list of folders until game project is found
	(assumes game is a relative path)
	"""

	if hasattr(folders[0], "__iter__"):
		folders = folders[0]

	for f in folders:
		if game in os.listdir(f):
			return os.path.join(os.path.abspath(f), game)

# careful with the default args value--only copy or concatenate it
def getLoveEngineCommand(game, args=[]):
	if sys.platform.startswith("win32"):
		return [os.path.join(DIR_ENGINE_WINDOWS, "love.exe"), game] + args
	elif sys.platform.startswith("darwin"):
		return ["open", game, "-a", os.path.join(DIR_ENGINE_OSX, "love.app"), "--args"] + args
	else:
		return ["love", game] + args

def buildApp(loveFileNameFull, appFolderName=None, dest="."):

	gameName = ".".join(os.path.basename(loveFileNameFull).split(".")[:-1])

	if not appFolderName:
		appFolderName = gameName + ".app"

	if appFolderName in os.listdir(dest):
		shutil.rmtree(os.path.join(dest, appFolderName))

	# copy and rename love.app
	shutil.copytree(os.path.join(DIR_ENGINE_OSX, "love.app"), os.path.join(dest, appFolderName))

	#add love file to app folder
	shutil.copy(loveFileNameFull, os.path.join(dest, appFolderName, "Contents", "Resources"))

	#TODO: update Info.plist file with custom metadata

def buildExe(loveFileNameFull, exeFolderName=None, exeFileName=None, dest="."):

	gameName = ".".join(os.path.basename(loveFileNameFull).split(".")[:-1])

	if not exeFileName:
		exeFileName = gameName + ".exe"
	if not exeFolderName:
		exeFolderName = gameName

	if exeFolderName in os.listdir(dest):
		shutil.rmtree(os.path.join(dest, exeFolderName))

	shutil.copytree(DIR_ENGINE_WINDOWS, os.path.join(dest, exeFolderName))

	exeFileNameFull = os.path.join(dest, exeFolderName, exeFileName)
	# loveFileNameFull = os.path.join(dest, exeFolderName, exeFileName)

	#rename love.exe
	os.rename(os.path.join(dest, exeFolderName, "love.exe"), exeFileNameFull)

	#append love file to renamed love.exe
	with open(exeFileNameFull, "ab") as exeFile, open(loveFileNameFull, "rb") as loveFile:
		bytes = loveFile.read()
		exeFile.write(bytes)
