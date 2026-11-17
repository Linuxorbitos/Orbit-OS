import os
import re
import shutil
import subprocess
from pathlib import Path
from .models import HardwareDevice

SYS = Path("/sys")

def _read(path):
    try:
        return Path(path).read_text(errors="replace").strip()
    except (OSError, UnicodeError):
        return ""

def _run(args):
    if not shutil.which(args[0]):
        return ""
    try:
        p = subprocess.run(args, capture_output=True, text=True, timeout=8, check=False)
        return p.stdout
    except (OSError, subprocess.TimeoutExpired):
        return ""

PCI_VENDOR_NAMES = {
    "0x8086": "Intel",
    "0x1002": "AMD",
    "0x1022": "AMD",
    "0x10de": "NVIDIA",
    "0x10ec": "Realtek",
    "0x14e4": "Broadcom",
    "0x168c": "Qualcomm Atheros",
    "0x17cb": "Qualcomm",
}

def _classify(name, cls=""):
    t = (name + " " + cls).lower()
    # Linux PCI class codes: 03=display, 02=network, 04=multimedia,
    # 0c03=USB controller, 01=mass storage.
    code = cls.lower().removeprefix("0x")
    if code.startswith("03"):
        return "Graphics"
    if code.startswith("02"):
        return "Network"
    if code.startswith("04"):
        return "Audio"
    if code.startswith("01"):
        return "Storage"
    if code.startswith("0c03"):
        return "USB"
    if any(x in t for x in ("vga", "3d controller", "display controller", "gpu", "graphics")):
        return "Graphics"
    if any(x in t for x in ("network controller", "ethernet", "wireless", "wi-fi", "wifi")):
        return "Network"
    if "bluetooth" in t:
        return "Bluetooth"
    if any(x in t for x in ("audio", "multimedia", "sound")):
        return "Audio"
    if any(x in t for x in ("usb controller", "usb hub")):
        return "USB"
    if any(x in t for x in ("sata", "nvme", "storage", "raid", "non-volatile")):
        return "Storage"
    if any(x in t for x in ("touchpad", "keyboard", "input")):
        return "Input"
    if any(x in t for x in ("camera", "webcam")):
        return "Camera"
    if "printer" in t:
        return "Printer"
    return "Other"

def scan_pci():
    devices = []
    base = SYS / "bus/pci/devices"
    if not base.exists():
        return devices
    for path in sorted(base.iterdir()):
        vendor = _read(path / "vendor")
        device = _read(path / "device")
        cls = _read(path / "class")
        driver_link = path / "driver"
        driver = driver_link.resolve().name if driver_link.exists() else None
        vendor_name = PCI_VENDOR_NAMES.get(vendor.lower(), vendor or "Unknown")
        name = f"{vendor_name} PCI device {vendor}:{device} class {cls}"
        devices.append(HardwareDevice(
            source="PCI", device_id=path.name, name=name,
            vendor=vendor_name, device_class=_classify(name, cls),
            driver_in_use=driver, modalias=_read(path / "modalias") or None
        ))
    return devices

def scan_usb():
    devices = []
    base = SYS / "bus/usb/devices"
    if not base.exists():
        return devices
    for path in sorted(base.iterdir()):
        vendor = _read(path / "idVendor")
        product = _read(path / "idProduct")
        if not vendor or not product:
            continue
        manufacturer = _read(path / "manufacturer")
        product_name = _read(path / "product")
        name = " ".join(x for x in (manufacturer, product_name) if x) or f"USB {vendor}:{product}"
        driver_link = path / "driver"
        driver = driver_link.resolve().name if driver_link.exists() else None
        devices.append(HardwareDevice(
            source="USB", device_id=path.name, name=name,
            vendor=vendor, device_class=_classify(name),
            driver_in_use=driver
        ))
    return devices

def scan_classes():
    devices = []
    for class_name, category in (
        ("net", "Network"), ("sound", "Audio"), ("bluetooth", "Bluetooth"),
        ("backlight", "Display"), ("drm", "Graphics"), ("input", "Input"),
    ):
        base = SYS / "class" / class_name
        if not base.exists():
            continue
        for path in sorted(base.iterdir()):
            real = path.resolve()
            driver = None
            for parent in (real, *real.parents):
                link = parent / "driver"
                if link.exists():
                    driver = link.resolve().name
                    break
            devices.append(HardwareDevice(
                source=f"sysfs:{class_name}", device_id=path.name,
                name=path.name, vendor="Linux subsystem",
                device_class=category, driver_in_use=driver
            ))
    return devices

def ubuntu_driver_report():
    return _run(["ubuntu-drivers", "devices"])

def scan_all():
    # De-duplicate only by source + device path; PCI/USB and sysfs are useful views.
    return scan_pci() + scan_usb() + scan_classes()
