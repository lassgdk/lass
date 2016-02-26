#!/usr/bin/env python

import sys
from PySide import QtGui
from lass.pmtools import DIR_LASS_DATA
import ui.general

if __name__ == '__main__':

    app = QtGui.QApplication(sys.argv)
    with open("main.qss") as styleSheetFile:
        app.setStyleSheet(styleSheetFile.read())
    window = ui.general.MainWindow()
    window.show()
    ret = app.exec_()
    sys.exit( ret )
