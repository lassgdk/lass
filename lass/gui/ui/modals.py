import traceback
from PySide import QtGui, QtCore
from .. import dialogs

class ErrorMessageBox(QtGui.QMessageBox):

    def __init__(self, parent, title=None, text=None, trace=None, formatArgs=tuple()):
        
        if title == None:
            title = self.messageTitle
        if text == None:
            text = self.messageText

        text = text.format(*formatArgs)

        QtGui.QMessageBox.__init__(
            self,
            QtGui.QMessageBox.Critical,
            title,
            text,
            QtGui.QMessageBox.Ok,
            parent,
            flags=QtCore.Qt.WindowFlags(QtCore.Qt.WindowCloseButtonHint)
        )

        if trace:
            self.setDetailedText(traceback.format_exc(trace))

def _createEMBClass(name, dialogKey):

    globals()[name] = type(name, (ErrorMessageBox,), {
        "messageText": dialogs.errors[dialogKey]["body"],
        "messageTitle": dialogs.errors[dialogKey]["title"]
    })
    
_createEMBClass("CouldNotParseSceneMB", "couldNotParseScene")
_createEMBClass("CouldNotLoadSceneMB", "couldNotLoadScene")
_createEMBClass("CouldNotParsePrefabMB", "couldNotParsePrefab")
_createEMBClass("CouldNotLoadPrefabMB", "couldNotLoadPrefab")
_createEMBClass("CouldNotOpenProjectMB", "couldNotOpenProject")
_createEMBClass("CouldNotPerformActionWithoutProjectMB", "couldNotPerformActionWithoutProject")
