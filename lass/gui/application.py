#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys, linecache
from PySide import QtGui
from ..pmtools import ProjectManager

class Application(object):

    gameObjectDataHeaders = ["name", "prefab", "events", "components", "prefabComponents"]
    gameObjectDataDefaults = {
        "name": "Game Object",
        "prefab": "",
        "events": [],
        "components": [],
        "prefabComponents": []
    }

    def __init__(self, qApp, projectManager):
        self.qApp = qApp
        self.projectManager = projectManager
        self.scenes = []
        self.currentSceneIndex = 0
        self.settings = {}

    def run(self):

        from ui.general import MainWindow

        window = MainWindow()
        window.reloadStyle()
        window.show()
        return self.qApp.exec_()

    def loadScene(self, fileName):

        scene = self.projectManager.loadScene(fileName)

        if not self.scenes:
            self.scenes.append(scene)
        else:
            self.scenes[self.currentSceneIndex] = scene

        return scene, self.currentSceneIndex

    def loadPrefab(self, fileName):

        return self.projectManager.loadPrefab(fileName)

    def exceptionString(self):
        exc_type, exc_obj, tb = sys.exc_info()
        f = tb.tb_frame
        lineno = tb.tb_lineno
        filename = f.f_code.co_filename
        linecache.checkcache(filename)
        line = linecache.getline(filename, lineno, f.f_globals)
        return '{} in {}, line {}: {}'.format(exc_obj.__class__.__name__, filename, lineno, exc_obj)

app = Application(QtGui.QApplication(sys.argv), ProjectManager())
