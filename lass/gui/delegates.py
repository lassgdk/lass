from PySide import QtGui

from six import string_types
from .ui.editors import TreeItemLineEditor

class TreeItemDelegate(QtGui.QStyledItemDelegate):

    def createEditor(self, parent, option, index):

        d = index.internalPointer().data(index.column())
        r = None
        if isinstance(d, string_types):
            r = TreeItemLineEditor(parent, index)
        elif type(d) == int:
            r = QtGui.QSpinBox(parent)

        return r
