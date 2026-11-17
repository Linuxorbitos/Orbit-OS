import sys
from PySide6.QtCore import QObject, Slot, Signal
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from .manager import DriverManager

class DriverBackend(QObject):
    inventoryChanged = Signal(str)
    reportChanged = Signal(str)

    def __init__(self):
        super().__init__()
        self.manager = DriverManager()

    @Slot()
    def scan(self):
        import json
        devices = [d.to_dict() for d in self.manager.scan()]
        self.inventoryChanged.emit(json.dumps(devices, indent=2))

    @Slot()
    def showUbuntuReport(self):
        self.reportChanged.emit(self.manager.ubuntu_report() or "ubuntu-drivers is not installed.")

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
backend = DriverBackend()
engine.rootContext().setContextProperty("driverBackend", backend)
engine.load("orbit_drivers/qml/Main.qml")
if not engine.rootObjects():
    sys.exit(1)
sys.exit(app.exec())
