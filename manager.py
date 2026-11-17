import platform
import shutil
import subprocess
from .catalog import ALLOWED_PACKAGES, recommend_for
from .detector import scan_all, ubuntu_driver_report
from .models import Recommendation

class DriverManager:
    def platform_check(self):
        return {
            "system": platform.system(),
            "machine": platform.machine(),
            "ubuntu": shutil.which("apt") is not None,
            "sudo": shutil.which("sudo") is not None,
        }

    def scan(self):
        return scan_all()

    def recommendations(self):
        results = []
        seen = set()
        for device in self.scan():
            for package, reason, confidence in recommend_for(device):
                key = (device.device_id, package)
                if key not in seen:
                    results.append(Recommendation(device.device_id, package, reason, confidence))
                    seen.add(key)
        return results

    def ubuntu_report(self):
        return ubuntu_driver_report()

    def installed_version(self, package):
        if not shutil.which("dpkg-query"):
            return None
        p = subprocess.run(
            ["dpkg-query", "-W", "-f=${Version}", package],
            capture_output=True, text=True, check=False
        )
        return p.stdout.strip() if p.returncode == 0 else None

    def package_plan(self, package):
        if package not in ALLOWED_PACKAGES:
            raise ValueError("Package is not in Orbit's reviewed allowlist.")
        if not shutil.which("apt"):
            raise RuntimeError("APT was not found. This manager currently targets Ubuntu.")
        return ["sudo", "apt", "install", "--", package]

    def install(self, package, confirmed=False):
        command = self.package_plan(package)
        if not confirmed:
            raise PermissionError("Explicit confirmation is required before installing packages.")
        # apt performs its own dependency and signature checks and asks sudo for authorization.
        return subprocess.run(command, check=False).returncode
