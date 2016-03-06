try:
    import cPickle as pickle
except ImportError:
    import pickle
from PySide import QtGui, QtCore
from six import text_type, binary_type

class TreeItem(object):

    def __init__(self, data, parent=None):
        self.itemData = list(data)
        self.childItems = []

        if parent:
            parent.appendChild(self)
        else:
            self.parentItem = None

    def parent(self):
        return self.parentItem

    def child(self, row):
        try:
            return self.childItems[row]
        except IndexError:
            return

    def row(self):
        if self.parentItem:
            return self.parentItem.childItems.index(self)

    def columnCount(self):
        return len(self.itemData)

    def data(self, column):

        try:
            return self.itemData[column]
        except IndexError:
            return

    def appendChild(self, item):

        self.childItems.append(item)
        item.parentItem = self

    def insertChild(self, item, position=0):

        try:
            self.childItems.insert(position, item)
            item.parentItem = self
            return True
        except:
            return False

    def removeChild(self, row):

        try:
            item = self.childItems.pop(row)
            item.parentItem = None
            return True
        except IndexError:
            return False

    def setData(self, column, value):

        try:
            self.itemData[column] = value
            return True
        except IndexError:
            return False

class TreeModel(QtCore.QAbstractItemModel):

    def __init__(self, initialData, headers, defaults, parent=None, itemClass=TreeItem):
        QtCore.QAbstractItemModel.__init__(self, parent)
        self.itemClass = itemClass
        self.rootItem = itemClass(headers)
        self.headers = headers
        self.defaults = defaults
        self.initializeTree(initialData)

    def index(self, row, column, parent=QtCore.QModelIndex()):
        if not self.hasIndex(row, column, parent):
            return QtCore.QModelIndex()

        if not parent.isValid():
            parentItem = self.rootItem
        else:
            parentItem = parent.internalPointer()

        childItem = parentItem.child(row)
        if childItem:
            return self.createIndex(row, column, childItem)
        else:
            return QtCore.QModelIndex()

    def rowCount(self, parentIndex=QtCore.QModelIndex()):

        if not parentIndex.isValid():
            item = self.rootItem
        else:
            item = parentIndex.internalPointer()

        return len(item.childItems)

    def columnCount(self, parentIndex):

        if not parentIndex.isValid():
            item = self.rootItem
        else:
            item = parentIndex.internalPointer()
        return item.columnCount()

    def parent(self, index):

        if not index.isValid():
            return QtCore.QModelIndex()

        childItem = index.internalPointer()
        parentItem = childItem.parent()

        if parentItem == self.rootItem:
            return QtCore.QModelIndex()
        elif parentItem:
            return self.createIndex(parentItem.row(), 0, parentItem)
        else:
            return QtCore.QModelIndex()

    def data(self, index, role):

        if not index.isValid():
            return
        elif role != QtCore.Qt.DisplayRole:
            return

        item = index.internalPointer()

        return item.data(index.column())

    def toDict(self, index):

        if not index.isValid():
            return

        item = index.internalPointer()
        d = {"data":{}, "children":[]}

        for i in range(item.columnCount()):
            d["data"][self.headers[i]] = item.data(i)

        for i in range(self.rowCount(index)):
            child = self.toDict(self.index(i, 0, index))
            d["children"].append(child)

        return d

    def item(self, index):

        if not index.isValid():
            i = self.rootItem
        else:
            i = index.internalPointer()

        return i

    def headerData(self, section, orientation, role):

        if orientation == QtCore.Qt.Horizontal and role == QtCore.Qt.DisplayRole:
            return self.rootItem.data(section)

    def initializeTree(self, nodes, parentIndex=QtCore.QModelIndex(), position=None):

        # parent = parent or self.rootItem
        # parent = self.item(parentIndex)
        if position == None:
            position = self.rowCount(parentIndex)

        indices = []

        for node in nodes:
            data = []
            for header in self.headers:
                data.append(node["data"].get(header, self.defaults[header]))

            # child = self.newItem(data)
            # parent.appendChild(child)
            r = self.insertRows(position, 1, parentIndex)

            childIndex = self.index(position, 0, parentIndex)
            child = self.item(childIndex)

            indices.append(childIndex)

            for i, datum in enumerate(data):
                self.setData(self.index(position, i, parentIndex), datum, QtCore.Qt.EditRole)

                # print node, datum

            # print child.data(0)

            if node.get("children"):
                self.initializeTree(node["children"], childIndex)

            position += 1

        return indices

    def clearTree(self):

        self.removeRows(0, self.rowCount())

    def setData(self, index, value, role):

        if not index.isValid() or role != QtCore.Qt.EditRole:
            return False

        r = index.internalPointer().setData(index.column(), value)
        if r:
            self.dataChanged.emit(index, index)

        return r

    def insertRows(self, first, count, parentIndex=QtCore.QModelIndex()):

        self.beginInsertRows(parentIndex, first, first + count - 1)

        parentItem = self.item(parentIndex)
        rows = []

        for i in range(first, first+count):
            item = self.newItem()
            r = parentItem.insertChild(item=item, position=first)

            if not r:
                self.endInsertRows()
                return False

            rows.append(i)

        self.endInsertRows()

        return True

    def removeRows(self, first, count, parentIndex=QtCore.QModelIndex()):

        self.beginRemoveRows(parentIndex, first, first + count - 1)

        parentItem = self.item(parentIndex)

        for i in range(first, first+count):
            r = parentItem.removeChild(first)

            if not r:
                self.endRemoveRows()
                return False

        self.endRemoveRows()
        return True

    def newItem(self, data=tuple()):

        data = list(data)
        data += [None for i in range(len(self.headers) - len(data))]

        for i, header in enumerate(self.headers):
            if data[i] == None:
                data[i] = self.defaults.get(header)

        return self.itemClass(data)

    def supportedDropActions(self):
        return QtCore.Qt.MoveAction

    def flags(self, index):
        if index.isValid():
            return (
                QtCore.Qt.ItemIsDragEnabled | 
                QtCore.Qt.ItemIsDropEnabled | 
                QtCore.Qt.ItemIsSelectable | 
                QtCore.Qt.ItemIsEditable | 
                QtCore.Qt.ItemIsEnabled
            )
        else:
            return QtCore.Qt.ItemIsDropEnabled

    def mimeTypes(self):
        # return ["application/vnd.text.list"]
        return ["application/python-pickle"]

    def mimeData(self, indices):

        md = QtCore.QMimeData()
        objects = []
        descendants = set()

        for index in indices:
            descendants = descendants.union(set(self.descendants(index)))

        for index in indices:
            if index.isValid() and index not in descendants:
                d = self.toDict(index)
                objects.append(self.toDict(index))

        md.setData(self.mimeTypes()[0], pickle.dumps(objects))

        return md

    def descendants(self, index):

        desc = []

        for i in range(self.rowCount(index)):
            childIndex = self.index(i, 0, index)
            desc += [childIndex] + self.descendants(childIndex)

        return desc

    def dropMimeData(self, data, action, row, column, parent):

        if action == QtCore.Qt.IgnoreAction:
            return True
        elif column > 0 or not data.hasFormat(self.mimeTypes()[0]):
            return False

        # if row != -1:
        #     firstRow = row
        # elif parent.isValid():
        #     firstRow = parent.row()
        # else:
        #     firstRow = self.rowCount()

        if row == -1:
            if parent.isValid():
                row = 0
            else:
                row = self.rowCount()

        decodedData = binary_type(data.data(self.mimeTypes()[0]))
        objects = pickle.loads(decodedData)
        self.initializeTree(objects, parent, row)

        # index = self.index(firstRow, 0, parent)
        # self.setData(index, decodedData, QtCore.Qt.EditRole)

        return True

class GameObjectTreeItem(TreeItem):

    def setData(self, column, value):

        if value == "":
            return False

        try:
            self.itemData[column] = value
            return True
        except IndexError:
            return False
