from __future__ import unicode_literals
import os, sys
from PySide import QtGui, QtCore, QtUiTools

from . import filedialogs, modals
from .. import resources, models, delegates, dialogs
from ..application import app
from ... import pmtools

# def loadUi(filename):

#     loader = QtUiTools.QUiLoader()
#     file = QtCore.QFile(filename)
#     file.open(QtCore.QFile.ReadOnly)
#     ui = loader.load(file)
#     file.close()

#     return ui

class MainMenuBar(QtGui.QMenuBar):

    def __init__(self, parent):

        QtGui.QMenuBar.__init__(self)

        self.fileMenu = self.addMenu("File")
        self.newProjectAction = self.fileMenu.addAction("New Project")
        self.newProjectInNewWindowAction = self.fileMenu.addAction("New Project in New Window")
        self.newSceneAction = self.fileMenu.addAction("New Scene")
        self.openProjectAction = self.fileMenu.addAction("Open Project")
        self.openProjectInNewWindowAction = self.fileMenu.addAction("Open Project in New Window")
        self.openSceneAction = self.fileMenu.addAction("Open Scene")

        self.openSceneAction.setShortcut(QtGui.QKeySequence.Open)

        self.newProjectAction.triggered.connect(parent.newProjectActionTriggered)
        self.newProjectInNewWindowAction.triggered.connect(parent.newProjectInNewWindowActionTriggered)
        self.newSceneAction.triggered.connect(parent.newSceneActionTriggered)
        self.openProjectAction.triggered.connect(parent.openProjectActionTriggered)
        self.openProjectInNewWindowAction.triggered.connect(parent.openProjectInNewWindowActionTriggered)
        self.openSceneAction.triggered.connect(parent.openSceneActionTriggered)

        self.newSceneAction.setEnabled(False)
        self.openSceneAction.setEnabled(False)

class MainWindow(QtGui.QMainWindow):

    def __init__(self):
        QtGui.QMainWindow.__init__(self)

        self.setMenuBar(MainMenuBar(self))
        self.setWindowState(QtCore.Qt.WindowMaximized)

        self.central = QtGui.QWidget(self)
        self.central.setObjectName("central")
        self.setCentralWidget(self.central)
        layout = QtGui.QHBoxLayout()
        self.central.setLayout(layout)

        self.startupFrame = QtGui.QFrame(self)
        layout.addWidget(self.startupFrame)

        self.startupFrame.setLayout(QtGui.QHBoxLayout())
        self.startupFrame.setObjectName("startupFrame")

        self.startupNewProjectButton = QtGui.QToolButton(self)
        self.startupNewProjectButton.setText("New Project")
        self.startupNewProjectButton.setObjectName("startupNewProjectButton")
        self.startupFrame.layout().addWidget(self.startupNewProjectButton)
        self.startupNewProjectButton.clicked.connect(self.newProjectActionTriggered)

        self.startupOpenProjectButton = QtGui.QToolButton(self)
        self.startupOpenProjectButton.setText("Open Project")
        self.startupOpenProjectButton.setObjectName("startupOpenProjectButton")
        self.startupFrame.layout().addWidget(self.startupOpenProjectButton)
        self.startupOpenProjectButton.clicked.connect(self.openProjectActionTriggered)

        # prevent one of the buttons from starting in focus
        self.startupFrame.setFocus()

    def showWorkspace(self):

        self.central.layout().removeWidget(self.startupFrame)
        self.startupFrame.hide()

        del self.startupFrame
        del self.startupNewProjectButton
        del self.startupOpenProjectButton

        self.statusbar = QtGui.QStatusBar(self)
        self.statusbar.setObjectName("statusbar")
        self.setStatusBar(self.statusbar)

        self.splitter = QtGui.QSplitter(self)
        self.splitter.setOrientation(QtCore.Qt.Horizontal)
        self.central.layout().addWidget(self.splitter)

        self.gameObjectTreeContainer = GameObjectTreeContainer(self)
        self.inspectorContainer = InspectorContainer(self)
        self.splitter.setChildrenCollapsible(False)
        self.splitter.addWidget(self.gameObjectTreeContainer)
        self.splitter.addWidget(self.inspectorContainer)

        self.gameObjectTreeContainer.gameObjectTree.dragStarted.connect(self.reloadStyle)
        self.gameObjectTreeContainer.gameObjectTree.dropStarted.connect(self.reloadStyle)

        self.menuBar().newSceneAction.setEnabled(True)
        self.menuBar().openSceneAction.setEnabled(True)

    def reloadStyle(self):
        with open(os.path.join(pmtools.DIR_LASS_DATA, "gui", "main.qss")) as styleSheetFile:
            self.setStyleSheet(styleSheetFile.read())

    def newProjectActionTriggered(self):

        projectDirectory = filedialogs.newProject(self)
        if not projectDirectory:
            return

        try:
            app.setProject(self, projectDirectory, initialize=True)
        except:
            modals.GenericErrorMB(self, trace=sys.exc_info()[2]).exec_()
            return

        self.showWorkspace()

    def newProjectInNewWindowActionTriggered(self):

        newWindow = MainWindow()
        newWindow.reloadStyle()
        newWindow.show()
        app.addWindow(newWindow)

        newWindow.newProjectActionTriggered()

    def newSceneActionTriggered(self):
        pass

    def openProjectActionTriggered(self):

        projectDirectory = filedialogs.loadProject(self)
        if not projectDirectory:
            return

        try:
            app.setProject(self, projectDirectory)
        except OSError as e:
            modals.CouldNotOpenProjectMB(self, formatArgs=(e,)).exec_()
            return

        self.showWorkspace()

    def openProjectInNewWindowActionTriggered(self):

        newWindow = MainWindow()
        newWindow.reloadStyle()
        newWindow.show()
        app.addWindow(newWindow)

        newWindow.openProjectActionTriggered()


    def openSceneActionTriggered(self):

        try:
            scene, sceneIndex = filedialogs.loadScene(self)
        except TypeError:
            return

        try:
            gameObjects = scene.gameObjects
        except AttributeError:
            modals.CouldNotParseSceneMB(self, trace=sys.exc_info()[2]).exec_()
            return

        treeModel = self.gameObjectTreeContainer.gameObjectTree.model()
        treeModel.clearTree()
        treeModel.initializeTree(scene.gameObjects)

class GameObjectTreeContainer(QtGui.QWidget):

    def __init__(self, parent):
        QtGui.QWidget.__init__(self, parent)

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

class GameObjectTree(QtGui.QTreeView):

    dragStarted = QtCore.Signal()
    dropStarted = QtCore.Signal()

    def __init__(self, parent=None):

        QtGui.QTreeView.__init__(self, parent)

        tree = []
        # tree = [
        #     {
        #         "data": {"name": "Test Object 1", "components": 4},
        #         "children":[
        #             {
        #                 "data": {"name": "Test Child 1", "components": 1}
        #             },
        #             {
        #                 "data": {"name": "Test Child 2", "components": 1}
        #             }
        #         ]
        #     },
        #     {
        #         "data": {"name": "Test Object 2", "components": 6}
        #     }
        # ]

        headers = app.gameObjectDataHeaders
        defaults = app.gameObjectDataDefaults

        g = models.TreeModel(tree, headers, defaults=defaults, itemClass=models.GameObjectTreeItem)
        d = delegates.TreeItemDelegate()
        self.setModel(g)
        self.setItemDelegate(d)

        self.setProperty("dragging", "false")

        self.setHeaderHidden(True)
        self.setExpandsOnDoubleClick(False)
        self.setObjectName("gameObjectTree")
        self.setIndentation(20)

        for i in range(1, len(headers)):
            self.hideColumn(i)
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

    def createGameObject(self, createAsChild=False, data=None):

        selected = self.selectedIndexes()

        # set position and parent
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

        # create the game object
        node = data or {"data":{}}
        if parent:
            indices = self.model().initializeTree([node], parentIndex=parent, position=position)
        else:
            indices = self.model().initializeTree([node], position=position)

        index = indices[0]

        # if parent:
        #     self.model().insertRows(position, 1, parentIndex=parent)
        #     index = self.model().index(position, 0, parent)
        #     # self.expand(parent)
        #     # self.setCurrentIndex()
        # else:
        #     self.model().insertRows(position, 1)
        #     index = self.model().index(position, 0)

        self.setCurrentIndex(index)

        # if data:
        #     self.model().initializeTree([data], position=)

        self.edit(index)

    def createChildGameObject(self):
        self.createGameObject(True)

    def createGameObjectFromPrefab(self):

        prefab = filedialogs.loadPrefab(self)
        if not prefab:
            return

        data = prefab.toGameObject()

        self.createGameObject(data=data)

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
        self.deleteGameObjectButton.setShortcut(QtGui.QKeySequence("Del"))

        layout.addWidget(self.createGameObjectButton)
        layout.addWidget(self.deleteGameObjectButton)

        self.createGameObjectButton.newObjectAction.triggered.connect(
            self.parent().gameObjectTree.createGameObject
        )
        self.createGameObjectButton.newChildObject.triggered.connect(
            self.parent().gameObjectTree.createChildGameObject
        )
        self.createGameObjectButton.newObjectFromPrefabAction.triggered.connect(
            self.parent().gameObjectTree.createGameObjectFromPrefab
        )

        self.setChildActionsEnabled(False)
        self.setDeleteActionsEnabled(False)
        self.deleteGameObjectButton.clicked.connect(self.parent().gameObjectTree.deleteGameObject)

    def setChildActionsEnabled(self, enable):

        actions = (self.createGameObjectButton.newChildObject,)
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
        self.newChildObject = self.createGameObjectButtonMenu.addAction("New Child Object")
        self.newObjectFromPrefabAction = self.createGameObjectButtonMenu.addAction("New Object from Prefab")

        self.setMenu(self.createGameObjectButtonMenu)
        self.setToolTip("Create Game Object")

class InspectorContainer(QtGui.QWidget):

    def __init__(self, parent):
        QtGui.QWidget.__init__(self, parent)

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
        self.label.setText("Object Editor")
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
