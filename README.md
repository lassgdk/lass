Lass
====

Lass is a modular development kit for building 2D play. It features a framework that uses the object/component design pattern, allowing one to easily combine pre-existing modules in many different ways to create new objects and scenes. Programmers can also develop their own modules, and use them in their own projects or distribute them as plugins. Lass strives to use this modularity to become a new groundwork for accessible, collaborative, and unorthodox play design.

Lass is in its early prototype stage. Lass games are currently created using command-line tools and plaintext files, but a visual editor is in the works.

Build Requirements
------------------

The following must be installed before you build Lass:

### Linux, Windows, and OS X

* Python 2.7 or higher (https://www.python.org/)
* setuptools (https://pypi.python.org/pypi/setuptools)
* lupa (https://pypi.python.org/pypi/lupa)

### Additional requirements for Linux

* LÖVE (https://love2d.org/)

### Additional requirements for Windows

* cx_Freeze (http://cx-freeze.sourceforge.net/)

Build and Install
-----------------

### Linux, Windows, and OS X

1. Download the Windows ("32-bit zipped") and OS X ("64-bit zipped") distributions of LÖVE 0.10.1 (https://love2d.org/).
2. Unzip the Windows .zip file and move everything inside the main folder (but not the folder itself) to engine/windows.
3. Unzip the OS X .zip file and move the love.app file to engine/osx.

### Additional instructions for Linux and OS X

The command to compile and install Lass is `python setup.py install`.

You may have to run it as root using the "sudo" prefix: `sudo python setup.py install`.

If you want to install a copy of the Lua libraries to your system, use `python setup.py install_lua_libs` or `python setup.py install --install-lua-libs`.

### Additional instructions for Windows

1. `python cx_setup.py build_exe` will create a new folder, called "dist", containing the compiled program.
2. Move the contents of the newly created "dist" folder wherever it pleases you to.
3. (Optional) Add the location of the installed program directory to your system Path variable (http://www.computerhope.com/issues/ch000549.htm).

Usage
-----

The `lasspm` command-line tool allows you to create, preview, and compile Lass games. For help using it, run `lasspm --help`.

If you are on Windows and you have not added Lass to the system Path variable, you will only be able to run lasspm after navigating to the Lass program directory.

Test
----

Tests for the Lass Lua library and LÖVE are located in the lass/data/tests/ directory, and can be run with lasspm:

`lasspm play -u <testname>`

For example, the "main" test is executed with `lasspm play -u main`.

Tests for the Python library are not yet available.

Uninstall
---------

There is no uninstall command in setup.py just yet, so if you wish to uninstall Lass you will need to remove all associated files manually.

### Linux and OS X

1. Remove lasspm. Use the `which lasspm` command to find out where it's stored.
2. Remove the Python library. Use the following command to find it: `python -c "import lass, os; print (os.path.dirname(lass.__file__))"`
3. If you have chosen to install the Lua libraries to your system, then you can find and delete them in `/usr/local/share/lua/5.1`.

### Windows

Lass for Windows is entirely portable: the cx_setup.py script doesn't create any files other than those generated in the "dist" folder. Simply deleting the Lass program folder is enough to remove it from your system.

Contribute
----------

Please see our [contributing guide](http://tracker.lassgdk.com/projects/meta/wiki/Contributing) if you are interested in getting involved with this project.

License
-------

Copyright 2014–2016 the Lass Team.

Lass is licensed under the terms of the GNU Lesser General Public License. These terms can be found in the files `license-gpl.txt` and `license-lgpl.txt`. You must agree to these terms in order to modify, redistribute, or develop with Lass.

Lass is intended to be used with LÖVE. If you use Lass with LÖVE, then you must also agree to the terms of the LÖVE license.
