from __future__ import unicode_literals
import sys, traceback, os, shutil
import lupa
from PySide import QtGui

from . import modals
from ..application import app

def importAsset(parent, fileName=""):

    try:
        project = app.project(parent)
        noProject = not project
    except KeyError:
        noProject = True
    finally:
        if noProject:
            return

    shutil.copy(fileName, project.sourceDirectory)
    return os.path.join(project.sourceDirectory, os.path.basename(fileName))

def _loadPrefabOrScene(module_type, parent, fileName=""):

    noProject = False

    try:
        project = app.project(parent)
        noProject = not project
    except KeyError:
        noProject = True
    finally:
        if noProject:
            # as long as load actions are disabled until the window is
            # associated with a project, we should not be possible to reach this
            # point. however, it's still good to have a fallback
            modals.CouldNotPerformActionWithoutProjectMB(parent).exec_()
            return

    if module_type == "prefab":
        method = project.loadPrefab
        dialogName = "Prefab"
        args = ("Load Prefab", project.sourceDirectory, "Prefab files (*.prefab.lua);; Lua files (*.lua)")
    elif module_type == "scene":
        method = project.loadScene
        dialogName = "Scene"
        args = ("Open Scene", project.sourceDirectory, "Scene files (*.scene.lua);; Lua files (*.lua)")
    else:
        return

    fname, _ = QtGui.QFileDialog.getOpenFileName(parent, *args)
    errorMessageBox = None

    if not fname:
        return

    # if the file is outside of the project directory, we should ask if the user
    # wants to import it
    if not os.path.abspath(fname).startswith(project.sourceDirectory):
        buttonPressed = modals.ConfirmImportExternalAssetMB(parent).exec_()
        if buttonPressed != QtGui.QMessageBox.Open:
            return

        try:
            fname = importAsset(parent, fileName=fname)
        except:
            return modals.GenericErrorMB(parent, trace=sys.exc_info()[2])._exec()

    # parse the prefab or scene
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

def loadPrefab(parent, fileName=""):

    prefab = _loadPrefabOrScene("prefab", parent, fileName)

    if not prefab:
        return

    try:
        prefab.toGameObject()
    except (lupa.LuaError, AttributeError):
        modals.CouldNotParsePrefabMB(parent, trace=sys.exc_info()[2]).exec_()
        return

    return prefab

def loadScene(parent, fileName=""):
    return _loadPrefabOrScene("scene", parent, fileName)

def loadProject(parent):

    fname = QtGui.QFileDialog.getExistingDirectory(parent, "Open Project")
    return fname

def newProject(parent):

    fname, _ = QtGui.QFileDialog.getSaveFileName(parent, "Create New Project")
    return fname
