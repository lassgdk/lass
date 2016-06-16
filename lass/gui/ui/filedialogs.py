from __future__ import unicode_literals
import sys, traceback
import lupa
from PySide import QtGui

from . import modals
from ..application import app

def _loadPrefabOrScene(module_type, parent):

    noProject = False

    try:
        project = app.project(parent)
        noProject = not project
    except KeyError:
        noProject = True
    finally:
        if noProject:
            # as long as load actions are disabled until the window is
            # associated with a project, it should not be possible to reach this
            # point. however, it's still good to have a fallback
            modals.CouldNotPerformActionWithoutProjectMB(parent).exec_()
            return

    if module_type == "prefab":
        method = project.loadPrefab
        dialogName = "Prefab"
        args = ("Load Prefab", ".", "Prefab files (*.prefab.lua);; Lua files (*.lua)")#, ~QtGui.QFileDialog.HideNameFilterDetails)
    elif module_type == "scene":
        method = project.loadScene
        dialogName = "Scene"
        args = ("Open Scene", ".", "Scene files (*.scene.lua);; Lua files (*.lua)")#, ~QtGui.QFileDialog.HideNameFilterDetails)
    else:
        return

    fname, _ = QtGui.QFileDialog.getOpenFileName(parent, *args)
    errorMessageBox = None

    if not fname:
        return

    try:
        r = method(fname)
    except lupa.LuaError:
        if module_type == "prefab":
            errorMessageBox = modals.CouldNotParsePrefabMB(parent, trace=sys.exc_info()[2])
        else:
            errorMessageBox = modals.CouldNotParseSceneMB(parent, trace=sys.exc_info()[2])
    except Exception as e:
        if module_type == "prefab":
            errorMessageBox = modals.CouldNotLoadPrefabMB(parent, trace=sys.exc_info()[2])
        else:
            errorMessageBox = modals.CouldNotLoadSceneMB(parent, trace=sys.exc_info()[2])

    if errorMessageBox:
        return errorMessageBox.exec_()

    return r

def loadPrefab(parent):

    prefab = _loadPrefabOrScene("prefab", parent)

    if not prefab:
        return

    try:
        prefab.toGameObject()
    except (lupa.LuaError, AttributeError):
        modals.CouldNotParsePrefabMB(parent, trace=sys.exc_info()[2]).exec_()
        return

    return prefab

def loadScene(parent):
    return _loadPrefabOrScene("scene", parent)

def loadProject(parent):

    fname =  QtGui.QFileDialog.getExistingDirectory(parent, "Open Project")
    return fname

def newProject(parent):

    fname, _ = QtGui.QFileDialog.getSaveFileName(parent, "Create New Project")
    return fname
