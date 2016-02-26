import re
from PySide import QtGui

class TreeItemLineEditor(QtGui.QLineEdit):
    def __init__(self, parent, index):
        QtGui.QLineEdit.__init__(self, parent)

        self.textChanged.connect(self.textChangedEvent)
        self.neverEdited = True
        self.initialData = index.internalPointer().data(index.column())
        self.setText(self.initialData)

        self.textChanged.connect(self.textChangedEvent)

    def textChangedEvent(self, text):

        if self.neverEdited and text == "":
            self.neverEdited = False
            self.setText(self.initialData)
        elif "\n" in text:
            self.setText(re.sub("(\r\n)|\n", "", text, re.M))
