#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from PySide import QtGui
from ..pmtools import ProjectManager

class Application(object):

    def __init__(self, qApp, projectManager):
        self.qApp = qApp
        self.projectManager = projectManager
        self.scenes = []
        self.currentSceneIndex = 0

    def run(self):

        from ui.general import MainWindow

        window = MainWindow()
        window.reloadStyle()
        window.show()
        return self.qApp.exec_()

    def loadScene(fileName):

        sceneData = self.projectManager.loadScene(fileName)
        scene = {"name":fileName, "scene":sceneData}

        if not self.scenes:
            self.scenes.append(scene)
        else:
            self.scenes[self.currentSceneIndex] = scene

        return scene

app = Application(QtGui.QApplication(sys.argv), ProjectManager())
