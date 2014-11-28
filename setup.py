import os, subprocess, sys
try:
	from setuptools import setup
except ImportError:
	print ("ERROR: setuptools not found (https://pypi.python.org/pypi/setuptools)")

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

try:
	XDG_DATA_HOME = os.environ["XDG_DATA_HOME"]
except KeyError:
	XDG_DATA_HOME = os.path.join(os.environ["HOME"], ".local", "share")
try:
	XDG_CONFIG_HOME = os.environ["XDG_CONFIG_HOME"]
except KeyError:
	XDG_CONFIG_HOME = os.path.join(os.environ["HOME"], ".config")
DIR_LASS_DATA = os.path.join(XDG_DATA_HOME, "Lass")
DIR_LASS_CONF = os.path.join(XDG_CONFIG_HOME, "Lass")

#if lua5.1 is installed, put lass lib in /usr
if not subprocess.call(["which", "lua5.1"], stdout=open(os.devnull, "w"), close_fds=True) or\
(
	subprocess.call(["which", "lua"], stdout=open(os.devnull, "w"), close_fds=True) and
	subprocess.check_output(["lua", "-v"]).startswith("Lua 5.1")
):
	DIR_LUA = os.path.join(sys.prefix, "local", "share", "lua", "5.1")
#if lua is not installed, put lass lib in XDG_DATA_HOME
else:
	DIR_LUA = os.path.join(DIR_LASS_DATA, "lua", "5.1")

DATA_FILES =\
	reduce(lambda a,b: a + b, [listAll(x, True, DIR_LASS_DATA) for x in ("examples", "engine")])

os.chdir("lib")
DATA_FILES += listAll("lass", True, headPrefix=DIR_LUA, filePrefix="lib")
os.chdir(os.path.join("..", "conf"))
DATA_FILES += listAll(".", headPrefix=DIR_LASS_CONF, filePrefix="conf")
os.chdir("..")

print os.getcwd()

print "=========="
for d in DATA_FILES:
	print d

setup(
    name = "lass",
    version = "0.1.0dev",
    author = "Decky Coss",
    author_email = "coss@alum.hackerschool.com",
    description = "A 2D game framework powered by the LOVE engine.",
    packages = [],
    scripts = [os.path.join("bin", "lasspm")],
    data_files = DATA_FILES
)
