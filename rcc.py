import subprocess, os

qrc = os.path.join("resources", "main.qrc")
out = os.path.join("lass", "gui", "resources.py")

subprocess.call(["pyside-rcc", qrc, "-o", out])
