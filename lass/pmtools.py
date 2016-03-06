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
from distutils import sysconfig
import lupa, six
from . import luatools

#set a bunch of global constants

if getattr(sys, 'frozen', False):
	DIR_LASS_DATA = os.path.join(os.path.dirname(sys.executable), "data")
else:
	DIR_LASS_DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")

DIR_ENGINE_WINDOWS = os.path.join(DIR_LASS_DATA, "engine", "windows")
DIR_ENGINE_OSX = os.path.join(DIR_LASS_DATA, "engine", "osx")
DIR_EXAMPLES = os.path.join(DIR_LASS_DATA, "examples")
DIR_TESTS = os.path.join(DIR_LASS_DATA, "tests")
DIR_TEMPLATES_LUA = os.path.join(DIR_LASS_DATA, "templates", "lua")
DIR_LASS_LIB = os.path.join(DIR_LASS_DATA, "lua", "5.1", "lass")

if sys.platform == "win32":
	DIR_TEMP = os.path.join(DIR_LASS_DATA, "tmp")
else:
	DIR_TEMP = "/tmp"

class ProjectManager(object):

	#main functions

	def __init__(self, lua=None):

		self.lua = lua or lupa.LuaRuntime(unpack_returned_tuples=True)

	def buildGame(self, game, sendToTemp=False, examples=False, tests=False, target="l"):
		"""
		build a .love file, plus optional binary distributions

		args:
			game: name of game project
			sendToTemp: store compiled game in temp folder
			examples: search for project in examples folder
			tests: search for project in tests folder, if not found in examples
			target: target platform--must be combination of w, l, o
		"""

		if not (examples or tests):
			if os.path.isabs(game):
				projPath = game
			else:
				projPath = os.path.join(os.getcwd(), game)
		#search for game in examples folder first, then test
		else:
			if os.path.isabs(game):
				raise OSError("Can't use -e option with absolute path")
			dirs = []
			if examples:
				dirs.append(DIR_EXAMPLES)
			if tests:
				dirs.append(DIR_TESTS)
			projPath = self.findGame(game, dirs)

		if not projPath:
			raise OSError("Project not found")

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

	def newGame(self, game):
		"""
		create a new Lass project

		args:
			game: name of new project
		"""

		# if projects and game==".":
		# 	raise OSError(
		# 		"Cannot initiate project in %s - try supplying project name" % os.path.join(DIR_PROJECTS, game)
		# 	)
		# elif projects:
		# 	projPath = os.path.join(DIR_PROJECTS, game)
		# else:
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

	def playGame(self, game, scene="", **kwargs):
		"""
		temporarily build and play a Lass project

		args:
			scene: filename of scene to play
			examples: search for project in examples folder
		"""

		game = self.buildGame(game, sendToTemp=True, **kwargs)

		# argString = ""
		args = ["--scene=" + scene] if scene else []

		# os.system(_getLoveEngineCommand().format(game, argString))
		proc = subprocess.Popen(self._getLoveEngineCommand(game, args), stdout=subprocess.PIPE)
		while proc.poll() == None:
			out = proc.stdout.readline()
			sys.stdout.write(out)
			sys.stdout.flush()

		os.remove(game)

	def newPrefab(self, fileName):
		shutil.copy(
			os.path.join(DIR_TEMPLATES_LUA, "prefab.lua"),
			os.path.join("src", fileName)
		)

	def _loadLuaModule(self, fileName):

		self.lua.execute("t = loadfile('{}')".format(fileName))
		module = None

		if self.lua.globals().t:
			try:
				module = self.lua.globals().t()
			except lupa.LuaError as e:
				raise lupa.LuaError("Could not parse " + fileName)
		else:
			raise OSError("{} not found".format(fileName))

		return module

	def loadScene(self, fileName):

		module = self._loadLuaModule(fileName)
		return Scene(fileName, module, self.lua)

	def loadPrefab(self, fileName):

		module = self._loadLuaModule(fileName)
		return Prefab(fileName, module, self.lua)


	# def loadPrefab(self, fileName):

	#helper functions

	# def _luaTableToObjectList(self, table):

	# 	if lupa.lua_type(table) != "table":
	# 		return

	# 	gameObjects = []

	# 	for i, node in luatools.ipairs(table):
	# 		o = {"data": {
	# 			"name": six.text_type(node.name) or "",
	# 			"components": luatools.luaTableToDict(node.components, self.lua) or {},
	# 			"transform": luatools.luaTableToDict(node.transform, self.lua) or {}
	# 		}}

	# 		o["children"] = self._luaTableToObjectList(node.children)

	# 		gameObjects.append(o)

	# 	return gameObjects

	def findGame(self, game, *folders):
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
	def _getLoveEngineCommand(self, game, args=[]):
		if sys.platform.startswith("win32"):
			return [os.path.join(DIR_ENGINE_WINDOWS, "love.exe"), game] + args
		elif sys.platform.startswith("darwin"):
			return ["open", game, "-a", os.path.join(DIR_ENGINE_OSX, "love.app"), "--args"] + args
		else:
			return ["love", game] + args

	def buildApp(self, loveFileNameFull, appFolderName=None, dest="."):

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

	def buildExe(self, loveFileNameFull, exeFolderName=None, exeFileName=None, dest="."):

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

class Scene(object):

	def __init__(self, name, data, lua):
		self.name = name
		self.data = data
		self.lua = lua

	def _gameObjects(self, table):

		objects = []

		for i, node in luatools.ipairs(table or {}):
			o = {"data": {
				"name": six.text_type(node.name),
				"prefab": six.text_type(node.prefab),
				"prefabComponents": luatools.luaTableToList(node.prefabComponents or self.lua.table(), self.lua),
				"components": luatools.luaTableToList(node.components or self.lua.table(), self.lua),
				"transform": luatools.luaTableToDict(node.transform, self.lua) or {}
			}}

			o["children"] = self._gameObjects(node.children)

			objects.append(o)

		return objects

	@property
	def gameObjects(self):

		# objects = []
		# for i, gameObject in luatools.ipairs(self.data.gameObjects or {}):
		# 	objects.append(luatools.luaTableToDict(gameObject, self.lua))

		# return objects

		return self._gameObjects(self.data.gameObjects)

	@property
	def settings(self):

		return luatools.luaTableToDict(self.data.settings, self.lua)

class Prefab(object):

	def __init__(self, name, data, lua):
		self.name = name
		self.data = data
		self.lua = lua

	def toGameObject(self):

		o = {"data": {
			"name": self.data.name or "",
			"prefab": self.name,
			"prefabComponents": luatools.luaTableToList(self.data.components or self.lua.table(), self.lua),
			"components": [],
			"transform": {},
		}, "children":[]}

		# for i, child in luatools.ipairs(self.data.children or self.lua.table()):
		# 	prefab = 
		# , "children": luatools.luaTableToList(self.data.children or self.lua.table(), self.lua)}

		return o