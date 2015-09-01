Lass
====

Lass is a modular development kit for building 2D play. It features a framework that uses the object/component design pattern, allowing one to easily combine pre-existing modules in many different ways to create new objects and scenes. Programmers can also develop their own modules, and use them in their own projects or distribute them as plugins. Lass strives to use this modularity to become a new groundwork for accessible, collaborative, and unorthodox play design.

Lass is in its early prototype stage. Lass games are currently created using command-line tools and plaintext files, but a visual editor is in the works.

Build Requirements
------------------

The following must be installed before you build Lass:

**Linux, Windows, and OS X**  
* Python 2.7 or higher (https://www.python.org/)
* setuptools (https://pypi.python.org/pypi/setuptools)

**Additional requirements for Linux**  
* LÖVE (https://love2d.org/)

**Additional requirements for Windows**  
* py2exe (http://www.py2exe.org/)

Build and Install
-----------------

**Linux, Windows, and OS X**  
1. Download the Windows ("32-bit zipped") and OS X ("64-bit zipped") distributions of the LÖVE engine (https://love2d.org/).  
2. Unzip the Windows .zip file and move everything inside the main folder (but not the folder itself) to `engine/windows`.  
3. Unzip the OS X .zip file and move the love.app file to `engine/osx`.

**Additional instructions for Linux and OS X**  
The command to compile and install Lass is `python setup.py install`.

You will probably have to run it as root using the "sudo" prefix: `sudo python setup.py install`.

**Additional instructions for Windows**  
1. `python setup.py py2exe` will create a new folder, called "dist", containing the compiled program.  
2. Move the contents of the newly created "dist" folder wherever it pleases you to.  
3. (Optional) Add the location of the installed program directory to your system Path variable (http://www.computerhope.com/issues/ch000549.htm).

Usage
-----

The `lasspm` command-line tool allows you to create, preview, and compile Lass games. For help using it, run `lasspm --help`.

If you are on Windows and you have not added Lass to the system Path variable, you will only be able to run lasspm after navigating to the Lass program directory.

Test
----

Tests for the Lass Lua library and LÖVE are located in the tests/ directory, and can be run with lasspm:

`lasspm play -u <testname>`

For example, the "main" test is executed with `lasspm play -u main`.

Tests for lasspm itself are not yet available.

Uninstall
---------

There is no uninstall command in setup.py just yet, so if you wish to uninstall Lass you will need to remove all associated files manually.

**Linux and OS X**  
1. Remove lasspm. By default, it can be found in `/usr/local/bin`; use the `which lasspm` command to confirm this.  
2. Remove the Lass data files. These are stored in either `$XDG_DATA_HOME/Lass` (`~/.local/share/Lass`) or `~/.Lass`.  
3. If you have Lua 5.1 installed, then the Lass Lua library is probably still on your system. You can find and delete it in `/usr/local/share/lua/5.1`.  
4. If you wish, you can also remove the Lass config files from `$XDG_CONFIG_HOME/Lass` (`~/.config/Lass`)

**Windows**  
Lass for Windows is entirely portable: the setup.py script doesn't create any files other than those generated in the "dist" folder. Simply deleting the Lass program folder is enough to remove it from your system.
