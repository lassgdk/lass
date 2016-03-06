import sys, traceback
import lupa
from PySide import QtGui

from .. import dialogs
from ..application import app

def _loadPrefabOrScene(module_type, parent):

    if module_type == "prefab":
        method = app.loadPrefab
        dialogName = "Prefab"
        args = ("Load Prefab", ".", "Prefab files (*.lua)")
    elif module_type == "scene":
        method = app.loadScene
        dialogName = "Scene"
        args = ("Open Scene", ".", "Scene files (*.lua)")
    else:
        return

    fname, _ = QtGui.QFileDialog.getOpenFileName(parent, *args)
    error = ""

    try:
        r = method(fname)
    except lupa.LuaError:
        error = dialogs.errors["couldNotParse{0}".format(dialogName)]
    except Exception as e:
        error = dialogs.errors["couldNotLoad{0}".format(dialogName)]
        # tb = sys.exc_info()[2]
        # traceback.print_exc(tb)

    if error:
        QtGui.QMessageBox.critical(
            parent, "Could not load {0}".format(module_type), error, buttons=QtGui.QMessageBox.Ok
        )
        return

    return r


def loadPrefab(parent):
    prefab = _loadPrefabOrScene("prefab", parent)

    if not prefab:
        return

    try:
        prefab.toGameObject()
    except lupa.LuaError:
        error = dialogs.errors["couldNotParse{0}".format(dialogName)]

    return prefab

def loadScene(parent):
    return _loadPrefabOrScene("scene", parent)