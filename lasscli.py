from __future__ import print_function
import os, sys, shutil, zipfile, argparse
try:
	import ConfigParser
except:
	import configparser

DIR_PROJECTS = "examples"
DIR_LASS = os.path.join("lib", "lass")
DIR_BUILD = "build"
DIR_TEMP = "tmp"
DIR_BIN_WINDOWS = os.path.join("bin", "love", "windows")
DIR_BIN_OSX = os.path.join("bin", "love", "osx")

def getLoveEngineCommand():
	if sys.platform.startswith("linux"):
		return "love %s"

def buildapp(loveFileName, dest="."):
	pass

def buildexe(loveFileName, exeFolderName=None, exeFileName=None, dest="."):

	gameName = ".".join(loveFileName.split(".")[:-1])

	if not exeFileName:
		exeFileName = gameName + ".exe"
	if not exeFolderName:
		exeFolderName = gameName

	if exeFolderName in os.listdir(dest):
		os.rmdir(os.path.join(dest, exeFolderName))

	shutil.copytree(DIR_BIN_WINDOWS, os.path.join(dest, exeFolderName))
	#rename love.exe
	os.rename(os.path.join(dest, "love.exe"), os.path.join(dest, exeFileName))

	#append love file to renamed love.exe
	with open(os.path.join(dest, exeFileName), "ab") as exeFile, open(loveFileName, "b") as loveFile:
		exeFile.write(loveFile.read())

def buildgame(sendToTemp=False):

	projName = sys.argv[2]
	projPath = os.path.join(DIR_PROJECTS, projName)
	if sendToTemp:
		buildPath = DIR_TEMP
	else:
		buildPath = os.path.join(projPath, DIR_BUILD)

	try:
		if not sendToTemp and not DIR_BUILD in os.listdir(projPath):
			os.mkdir(buildPath)
		elif sendToTemp and not DIR_TEMP in os.listdir("."):
			os.mkdir(buildPath)
	except OSError as e:
		print(e)
		return 

	projFiles = os.listdir(projPath)
	loveFileName = os.path.join(buildPath, projName + ".love")
	origDir = os.getcwd()

	with zipfile.ZipFile(loveFileName, mode='w') as loveFile:

		#add project files
		for f in projFiles:
			if f != "build":
				loveFile.write(os.path.join(projPath, f), f)

		#add lass library
		os.chdir(DIR_LASS)
		for i, wtup in enumerate(os.walk(".")):
			for j, f in enumerate(wtup[2]):
				fullName = os.path.join(wtup[0], f)
				loveFile.write(fullName, os.path.join("lass", fullName))

	os.chdir(origDir)

	return os.path.abspath(loveFileName)

def newgame():
	pass

def playgame():
	game = buildgame(True)
	os.system(getLoveEngineCommand() % game)
	os.remove(game)

def main():
	try:
		{
			"build": buildgame,
			"new": newgame,
			"play": playgame
		}[sys.argv[1]]()
	except (IndexError, KeyError):
		print("usage: hugahgsd")

if __name__ == "__main__":
	main()
