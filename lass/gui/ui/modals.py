import traceback
from PySide import QtGui, QtCore
from .. import dialogs

class ErrorMessageBox(QtGui.QMessageBox):

    def __init__(self, parent, title, text, trace=None):
        QtGui.QMessageBox.__init__(
            self,
            QtGui.QMessageBox.Critical,
            title,
            text,
            QtGui.QMessageBox.Ok,
            parent,
            flags=QtCore.Qt.WindowFlags(QtCore.Qt.WindowCloseButtonHint)
        )

        if traceback:
            self.setDetailedText(traceback.format_exc(trace))

class CouldNotParseSceneMB(ErrorMessageBox):

    def __init__(self, parent, trace):

        ErrorMessageBox.__init__(
            self,
            parent,
            "Could not load scene",
            dialogs.errors["couldNotParseScene"],
            trace
        )

class CouldNotLoadSceneMB(ErrorMessageBox):

    def __init__(self, parent, trace):

        ErrorMessageBox.__init__(
            self,
            parent,
            "Could not load scene",
            dialogs.errors["couldNotLoadScene"],
            trace
        )

class CouldNotParsePrefabMB(ErrorMessageBox):

    def __init__(self, parent, trace):

        ErrorMessageBox.__init__(
            self,
            parent,
            "Could not load scene",
            dialogs.errors["couldNotParsePrefab"],
            trace
        )

class CouldNotLoadPrefabMB(ErrorMessageBox):

    def __init__(self, parent, trace):

        ErrorMessageBox.__init__(
            self,
            parent,
            "Could not load prefab",
            dialogs.errors["couldNotLoadPrefab"],
            trace
        )
