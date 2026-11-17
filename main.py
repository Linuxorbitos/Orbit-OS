import os
import sys
from pathlib import Path
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from orbit_backend import OrbitBackend

BASE = Path(__file__).resolve().parent
QGuiApplication.setDesktopFileName("orbit")
app = QGuiApplication(sys.argv)
app.setApplicationName("Orbit OS")
app.setOrganizationName("Orbit")
app.setWindowIcon(QIcon(str(BASE.parent / "assets" / "orbit.svg")))

engine = QQmlApplicationEngine()
backend = OrbitBackend()
engine.rootContext().setContextProperty("orbitBackend", backend)
engine.load(QUrl.fromLocalFile(str(BASE / "qml" / "Main.qml")))

if not engine.rootObjects():
    sys.exit(1)
sys.exit(app.exec())
