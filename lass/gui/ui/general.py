from __future__ import unicode_literals
import os
from PySide import QtGui, QtCore, QtUiTools

from .. import resources
from ...pmtools import DIR_LASS_DATA
from .. import models
from .. import delegates

def loadUi(filename):

    loader = QtUiTools.QUiLoader()
    file = QtCore.QFile(filename)
    file.open(QtCore.QFile.ReadOnly)
    ui = loader.load(file)
    file.close()

    return ui

class MainMenuBar(QtGui.QMenuBar):
    def __init__(self):

        QtGui.QMenuBar.__init__(self)

        fileMenu = self.addMenu("File")
        newAction = fileMenu.addAction("New")
        openAction = fileMenu.addAction("Open")

        newAction.setShortcut(QtGui.QKeySequence.New)
    #     newAction.triggered.connect(self.newActionTriggered)

    # def newActionTriggered(self):
    #     print self.window().gameObjectTreeContainer.gameObjectTree.model().rootItem.child(0).data(0)

class MainWindow(QtGui.QMainWindow):

    def __init__(self):
        QtGui.QMainWindow.__init__(self)

        self.central = QtGui.QWidget(self)
        layout = QtGui.QHBoxLayout()
        self.central.setLayout(layout)
        self.central.setObjectName("central")
        self.setCentralWidget(self.central)

        self.statusbar = QtGui.QStatusBar(self)
        self.statusbar.setObjectName("statusbar")
        self.setStatusBar(self.statusbar)

        self.splitter = QtGui.QSplitter(self)
        self.splitter.setOrientation(QtCore.Qt.Horizontal)
        layout.addWidget(self.splitter)

        self.gameObjectTreeContainer = GameObjectTreeContainer()
        self.inspectorContainer = InspectorContainer()
        self.splitter.setChildrenCollapsible(False)
        self.splitter.addWidget(self.gameObjectTreeContainer)
        self.splitter.addWidget(self.inspectorContainer)

        self.gameObjectTreeContainer.gameObjectTree.dragStarted.connect(self.reloadStyle)
        self.gameObjectTreeContainer.gameObjectTree.dropStarted.connect(self.reloadStyle)

        self.setMenuBar(MainMenuBar())
        self.setWindowState(QtCore.Qt.WindowMaximized)

    def reloadStyle(self):
        with open(os.path.join(DIR_LASS_DATA, "gui", "main.qss")) as styleSheetFile:
            self.setStyleSheet(styleSheetFile.read())

class GameObjectTreeContainer(QtGui.QWidget):

    def __init__(self):
        QtGui.QWidget.__init__(self)

        self.setObjectName("gameObjectTreeContainer")
        # self.resize(270, 458)
        self.gameObjectTreeContainerLayout = QtGui.QVBoxLayout(self)
        self.gameObjectTreeContainerLayout.setContentsMargins(0, 0, 0, 0)
        self.gameObjectTreeContainerLayout.setObjectName("gameObjectTreeContainerLayout")
        self.gameObjectTreeLayout = QtGui.QVBoxLayout()
        self.gameObjectTreeLayout.setSpacing(2)
        self.gameObjectTreeLayout.setObjectName("gameObjectTreeLayout")

        self.gameObjectTreeContainerLayout.addLayout(self.gameObjectTreeLayout)

        self.label = QtGui.QLabel()
        self.label.setObjectName("label")
        self.gameObjectTree = GameObjectTree(self)
        self.gameObjectTreeToolbar = GameObjectTreeToolbar(self)

        self.gameObjectTreeLayout.addWidget(self.label)
        self.gameObjectTreeLayout.addWidget(self.gameObjectTreeToolbar)
        self.gameObjectTreeLayout.addWidget(self.gameObjectTree)

        self.label.setText("Game Objects")

    #     self.retranslateUi(GameObjectTreeContainer)
    #     QtCore.QMetaObject.connectSlotsByName(GameObjectTreeContainer)

    # def retranslateUi(self, GameObjectTreeContainer):
    #     GameObjectTreeContainer.setWindowTitle(QtGui.QApplication.translate("GameObjectTreeContainer", "Form", None, QtGui.QApplication.UnicodeUTF8))
    #     self.label.setText("Game Objects")

class GameObjectTree(QtGui.QTreeView):

    dragStarted = QtCore.Signal()
    dropStarted = QtCore.Signal()

    def __init__(self, parent=None):

        QtGui.QTreeView.__init__(self, parent)

        tree = [
            {
                "data": {"name": "Test Object 1", "components": 4},
                "children":[
                    {
                        "data": {"name": "Test Child 1", "components": 1}
                    },
                    {
                        "data": {"name": "Test Child 2", "components": 1}
                    }
                ]
            },
            {
                "data": {"name": "Test Object 2", "components": 6}
            }
        ]

        headers = ["name", "components"]
        defaults = {"name": "Game Object", "components": 0}

        g = models.TreeModel(tree, headers, defaults=defaults, itemClass=models.GameObjectTreeItem)
        d = delegates.TreeItemDelegate()
        self.setModel(g)
        self.setItemDelegate(d)

        self.setProperty("dragging", "false")

        self.setHeaderHidden(True)
        self.setExpandsOnDoubleClick(False)
        self.setObjectName("gameObjectTree")
        self.setIndentation(20)
        self.hideColumn(1)
        self.setDragDropMode(QtGui.QAbstractItemView.DragDrop)
        # self.setFocusPolicy(QtCore.Qt.ClickFocus)
        self.setDropIndicatorShown(True);
        self.setSelectionBehavior(QtGui.QTreeView.SelectRows)
        self.setSelectionMode(QtGui.QTreeView.ExtendedSelection)

        # palette = self.palette()
        # palette.setColor(QtGui.QPalette.Active, QtGui.QPalette.Window, QtGui.QColor(245, 77, 175, .5))
        # self.setStyleSheet("QTreeView::item:selected {background-color: rgb(245, 77, 175);color: white;}")

    def mousePressEvent(self, event):

        QtGui.QTreeView.mousePressEvent(self, event)
        if not self.indexAt(event.pos()).isValid():
            self.clearSelection()
            self.mousePressStartPosition = None
        elif event.button() == QtCore.Qt.LeftButton:
            self.mousePressStartPosition = event.pos()

    # def mouseMoveEvent(self, event):

    #     # if event != self.DragSelectingState:
    #         # QtGui.QTreeView.mouseMoveEvent(self, event)

    #     startDragDistance = QtGui.QApplication.startDragDistance()
    #     if (
    #         event.buttons() & QtCore.Qt.LeftButton and
    #         self.mousePressStartPosition and
    #         event.pos().manhattanLength() - self.mousePressStartPosition.manhattanLength() >= 5
    #     ):
    #         drag = QtGui.QDrag(self)
    #         # drag.set
    #         # self.mousePressStartPosition = None
    #     elif event != self.DragSelectingState:
    #         QtGui.QTreeView.mouseMoveEvent(self, event)

    def dragEnterEvent(self, event):

        if event.mimeData().hasFormat(self.model().mimeTypes()[0]):
            event.setDropAction(QtCore.Qt.MoveAction)
            event.accept()
        else:
            event.ignore()

        QtGui.QTreeView.dragEnterEvent(self, event)

    def dropEvent(self, event):

        index = self.indexAt(event.pos())
        self.setExpanded(index, True)

        self.setProperty("dragging", "false")
        QtGui.QTreeView.dropEvent(self, event)

    def startDrag(self, event):

        indices = self.selectedIndexes()
        self.dragStarted.emit()

        self.setProperty("dragging", "true")
        # self.setStyleSheet("QTreeView::item:selected {background-color: rgba(245, 77, 175, 50%);}")
        print self.styleSheet()
        QtGui.QTreeView.startDrag(self, event)

    def selectionChanged(self, selected, deselected):

        toolbar = self.parent().gameObjectTreeToolbar

        if len(self.selectedIndexes()) == 1:
            toolbar.setChildActionsEnabled(True)
            toolbar.setDeleteActionsEnabled(True)
        elif len(self.selectedIndexes()) > 1:
            toolbar.setChildActionsEnabled(False)
            toolbar.setDeleteActionsEnabled(True)
        else:
            toolbar.setChildActionsEnabled(False)
            toolbar.setDeleteActionsEnabled(False)

        QtGui.QTreeView.selectionChanged(self, selected, deselected)

    def createGameObject(self, createAsChild=False):

        selected = self.selectedIndexes()
        if len(selected) == 1 and createAsChild:
            position = self.model().rowCount(selected[0])
            parent = selected[0]
        elif selected:
            selected.sort(key=(lambda index: index.row()), reverse=True)
            position = selected[0].row() + 1
            parent = selected[0].parent()
        else:
            position = self.model().rowCount()
            parent = None

        if parent:
            self.model().insertRows(position, 1, parentIndex=parent)
            index = self.model().index(position, 0, parent)
            # self.expand(parent)
            # self.setCurrentIndex()
        else:
            self.model().insertRows(position, 1)
            index = self.model().index(position, 0)

        self.setCurrentIndex(index)

        self.edit(index)

    def createGameObjectAsChild(self):
        self.createGameObject(True)

    def deleteGameObject(self):

        selected = self.selectedIndexes()
        if not selected:
            return

        # rows = sorted([index.row() for index in selected])
        selected.sort(key=(lambda index: index.row()))

        #if rows form an unbroken range where step==1, we only need to call removeRows once
        for i in range(len(selected)-1):
            if (selected[i+1].row() - selected[i].row() != 1) or (selected[i+1].parent() != selected[i].parent()):
                break
        else:
            count = selected[-1].row() - selected[0].row() + 1
            self.model().removeRows(selected[0].row(), count, selected[0].parent())
            return

        for index in selected:
            position = index.row()
            self.model().removeRows(position, 1, index.parent())

class GameObjectTreeToolbar(QtGui.QFrame):

    def __init__(self, parent=None):
        QtGui.QFrame.__init__(self, parent)

        self.setObjectName("gameObjectTreeToolbar")

        layout = QtGui.QHBoxLayout()
        layout.setAlignment(QtCore.Qt.AlignLeft)
        layout.setSpacing(4)
        layout.setContentsMargins(0, 0, 0, 0)
        self.setLayout(layout)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        self.setSizePolicy(sizePolicy)

        self.createGameObjectButton = CreateGameObjectButton()
        self.deleteGameObjectButton = QtGui.QPushButton()
        self.deleteGameObjectButton.setObjectName("deleteGameObjectButton")
        self.deleteGameObjectButton.setToolTip("Delete Game Object")

        layout.addWidget(self.createGameObjectButton)
        layout.addWidget(self.deleteGameObjectButton)

        self.createGameObjectButton.newObjectAction.triggered.connect(
            self.parent().gameObjectTree.createGameObject
        )
        self.createGameObjectButton.newObjectAsChildAction.triggered.connect(
            self.parent().gameObjectTree.createGameObjectAsChild
        )

        self.setChildActionsEnabled(False)
        self.setDeleteActionsEnabled(False)
        self.deleteGameObjectButton.clicked.connect(self.parent().gameObjectTree.deleteGameObject)

    def setChildActionsEnabled(self, enable):

        actions = (self.createGameObjectButton.newObjectAsChildAction,)
        for action in actions:
            action.setEnabled(enable)

    def setDeleteActionsEnabled(self, enable):
        self.deleteGameObjectButton.setEnabled(enable)

class CreateGameObjectButton(QtGui.QToolButton):
    def __init__(self, parent=None, objectName="createGameObjectButton"):
        QtGui.QToolButton.__init__(self, parent)

        self.setObjectName(objectName)
        self.createGameObjectButtonMenu = QtGui.QMenu()
        self.setPopupMode(QtGui.QToolButton.InstantPopup)
        self.createGameObjectButtonMenu.setObjectName("createGameObjectButtonMenu")

        self.newObjectAction = self.createGameObjectButtonMenu.addAction("New Object")
        self.newObjectAsChildAction = self.createGameObjectButtonMenu.addAction("New Child Object")
        self.newObjectFromPrefabAction = self.createGameObjectButtonMenu.addAction("New Object from Prefab")

        self.newObjectFromPrefabAction.setEnabled(False)

        self.setMenu(self.createGameObjectButtonMenu)
        self.setToolTip("Create Game Object")

class InspectorContainer(QtGui.QWidget):

    def __init__(self):
        QtGui.QWidget.__init__(self)

        self.setObjectName("InspectorContainer")
        self.resize(290, 398)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.sizePolicy().hasHeightForWidth())
        self.setSizePolicy(sizePolicy)
        self.verticalLayout_2 = QtGui.QVBoxLayout(self)
        self.verticalLayout_2.setContentsMargins(0, 0, 0, 0)
        self.verticalLayout_2.setObjectName("verticalLayout_2")
        self.inspectorLayout = QtGui.QVBoxLayout()
        self.inspectorLayout.setSpacing(2)
        self.inspectorLayout.setSizeConstraint(QtGui.QLayout.SetDefaultConstraint)
        self.inspectorLayout.setContentsMargins(0, -1, -1, -1)
        self.inspectorLayout.setObjectName("inspectorLayout")
        self.label = QtGui.QLabel()
        self.label.setText("Inspector")
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Maximum)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.label.sizePolicy().hasHeightForWidth())
        self.label.setSizePolicy(sizePolicy)
        self.label.setObjectName("label")
        self.inspectorLayout.addWidget(self.label)
        self.inspector = QtGui.QFrame()
        self.inspector.setMinimumSize(QtCore.QSize(0, 0))
        self.inspector.setFrameShape(QtGui.QFrame.StyledPanel)
        self.inspector.setFrameShadow(QtGui.QFrame.Raised)
        self.inspector.setObjectName("inspector")
        self.inspectorLayout.addWidget(self.inspector)
        self.verticalLayout_2.addLayout(self.inspectorLayout)

        self.label.setText("Object Editor")
