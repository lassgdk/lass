#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, linecache, os
from six import text_type
from PySide import QtGui
from ..pmtools import ProjectManager

class Project(object):

    def __init__(self, directory, initialize=False):

        if not isinstance(directory, text_type):
            raise TypeError("directory must be string")

        self.directory = os.path.abspath(os.path.expandvars(directory))
        self.projectManager = ProjectManager()

        if not initialize:
            self.projectManager.assertProjectIsValid(self.directory)

        self.scenes = []
        self.currentSceneIndex = 0
        self.settings = {}

    def isFileInProject(self, fileName):

        # we intentionally don't follow symlinks
        return os.path.abspath(os.path.expandvars(fileName)).startswith(self.directory)

    def loadScene(self, fileName):

        if not self.isFileInProject(fileName):
            return False

        scene = self.projectManager.loadScene(fileName)

        if not self.scenes:
            self.scenes.append(scene)
        else:
            self.scenes[self.currentSceneIndex] = scene

        return scene, self.currentSceneIndex

    def loadPrefab(self, fileName):

        if not self.isFileInProject(fileName):
            return False

        return self.projectManager.loadPrefab(fileName)


class Application(object):

    gameObjectDataHeaders = ["name", "prefab", "events", "components", "prefabComponents"]
    gameObjectDataDefaults = {
        "name": "Game Object",
        "prefab": "",
        "events": [],
        "components": [],
        "prefabComponents": []
    }

    def __init__(self, qApp):
        self.qApp = qApp
        self.projects = {}

    def run(self):

        from ui.general import MainWindow

        window = MainWindow()
        window.reloadStyle()
        window.show()

        return self.qApp.exec_()

    def project(self, window):

        return self.projects[window]

    def addWindow(self, window):

        self.projects[window] = None

    def setProject(self, window, directory):

        if directory:
            self.projects[window] = Project(directory)
        else:
            self.projects[window] = None

    def removeWindow(self, window):

        self.projects.pop(window)

    def exceptionString(self):
        #why is this even here?

        exc_type, exc_obj, tb = sys.exc_info()
        f = tb.tb_frame
        lineno = tb.tb_lineno
        filename = f.f_code.co_filename
        linecache.checkcache(filename)
        line = linecache.getline(filename, lineno, f.f_globals)
        return '{} in {}, line {}: {}'.format(exc_obj.__class__.__name__, filename, lineno, exc_obj)

app = Application(QtGui.QApplication(sys.argv))
