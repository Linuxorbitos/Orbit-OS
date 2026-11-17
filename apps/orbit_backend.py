import hashlib
import hmac
import os
import re
import sqlite3
from pathlib import Path
from PySide6.QtCore import QObject, Slot, Signal
import json
try:
    from orbit_drivers.manager import DriverManager
except ImportError:
    DriverManager = None

APP_DIR = Path.home() / ".local" / "share" / "orbit"
DB_PATH = APP_DIR / "accounts.sqlite3"
EMAIL_RE = re.compile(r"^[A-Za-z0-9._%+-]+@orbit\.com$")

class OrbitBackend(QObject):
    accountCreated = Signal(str)
    loginSucceeded = Signal(str)
    error = Signal(str)

    def __init__(self):
        super().__init__()
        APP_DIR.mkdir(parents=True, exist_ok=True)
        self._init_db()

    def _connect(self):
        con = sqlite3.connect(DB_PATH)
        con.execute("PRAGMA journal_mode=WAL")
        return con

    def _init_db(self):
        with self._connect() as con:
            con.execute("""
                CREATE TABLE IF NOT EXISTS accounts (
                    email TEXT PRIMARY KEY COLLATE NOCASE,
                    display_name TEXT NOT NULL,
                    salt BLOB NOT NULL,
                    password_hash BLOB NOT NULL,
                    created_at TEXT DEFAULT CURRENT_TIMESTAMP
                )
            """)

    @Slot(str, str, str, result=bool)
    def createAccount(self, name, email, password):
        name, email = name.strip(), email.strip().lower()
        if len(name) < 2:
            self.error.emit("Please enter a name with at least 2 characters.")
            return False
        if not EMAIL_RE.fullmatch(email):
            self.error.emit("Orbit email addresses must end in @orbit.com.")
            return False
        if len(password) < 10:
            self.error.emit("Use a password with at least 10 characters.")
            return False
        salt = os.urandom(16)
        digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, 310000)
        try:
            with self._connect() as con:
                con.execute(
                    "INSERT INTO accounts(email, display_name, salt, password_hash) VALUES(?,?,?,?)",
                    (email, name, salt, digest)
                )
        except sqlite3.IntegrityError:
            self.error.emit("An account with that email already exists on this device.")
            return False
        self.accountCreated.emit(name)
        return True

    @Slot(str, str, result=bool)
    def login(self, email, password):
        email = email.strip().lower()
        with self._connect() as con:
            row = con.execute(
                "SELECT display_name, salt, password_hash FROM accounts WHERE email=?",
                (email,)
            ).fetchone()
        if not row:
            self.error.emit("No Orbit account was found on this device. Create an account first.")
            return False
        name, salt, expected = row
        actual = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, 310000)
        if not hmac.compare_digest(actual, expected):
            self.error.emit("The email or password is incorrect.")
            return False
        self.loginSucceeded.emit(name)
        return True

    @Slot(result=str)
    def accountName(self):
        return "Orbit User"

    @Slot(str, result=str)
    def safeAppMessage(self, app_name):
        return app_name + " is a starter app in this Orbit prototype."


    @Slot(result=str)
    def scanHardware(self):
        if DriverManager is None:
            return json.dumps({"error": "Orbit Drivers module is unavailable."})
        try:
            manager = DriverManager()
            return json.dumps([d.to_dict() for d in manager.scan()], indent=2)
        except Exception as exc:
            return json.dumps({"error": str(exc)})

    @Slot(result=str)
    def driverRecommendations(self):
        if DriverManager is None:
            return json.dumps({"error": "Orbit Drivers module is unavailable."})
        try:
            manager = DriverManager()
            return json.dumps({
                "recommendations": [r.to_dict() for r in manager.recommendations()],
                "ubuntu_report": manager.ubuntu_report()
            }, indent=2)
        except Exception as exc:
            return json.dumps({"error": str(exc)})

    @Slot(str, result=str)
    def planDriverInstall(self, package):
        if DriverManager is None:
            return "Orbit Drivers module is unavailable."
        try:
            return " ".join(DriverManager().package_plan(package))
        except Exception as exc:
            return "Cannot prepare installation: " + str(exc)
