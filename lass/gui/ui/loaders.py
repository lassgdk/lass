from __future__ import unicode_literals
import sys, traceback
import lupa
from PySide import QtGui

from . import modals
from ..application import app

def _loadPrefabOrScene(module_type, parent):

    if module_type == "prefab":
        method = app.loadPrefab
        dialogName = "Prefab"
        args = ("Load Prefab", ".", "Prefab files (*.prefab.lua);; Lua files (*.lua)")#, ~QtGui.QFileDialog.HideNameFilterDetails)
    elif module_type == "scene":
        method = app.loadScene
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
            errorMessageBox = modals.CouldNotParsePrefabMB(parent, sys.exc_info()[2])
        else:
            errorMessageBox = modals.CouldNotParseSceneMB(parent, sys.exc_info()[2])
    except Exception as e:
        if module_type == "prefab":
            errorMessageBox = modals.CouldNotLoadPrefabMB(parent, sys.exc_info()[2])
        else:
            errorMessageBox = modals.CouldNotLoadSceneMB(parent, sys.exc_info()[2])

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
        modals.CouldNotParsePrefabMB(parent, sys.exc_info()[2]).exec_()
        return

    return prefab

def loadScene(parent):
    return _loadPrefabOrScene("scene", parent)