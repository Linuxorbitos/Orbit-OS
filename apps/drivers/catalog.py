"""
Conservative Ubuntu package recommendations.

This is intentionally not a device-to-driver database. Exact package selection
must be confirmed against the installed Ubuntu release and Ubuntu's own tools.
"""
ALLOWED_PACKAGES = {
    "ubuntu-drivers-common",
    "linux-firmware",
    "firmware-iwlwifi",
    "bluez",
    "bluez-firmware",
    "alsa-utils",
    "mesa-vulkan-drivers",
    "mesa-utils",
    "printer-driver-all",
    "cups",
    "fwupd",
}

def recommend_for(device):
    text = f"{device.vendor} {device.name} {device.device_class}".lower()
    out = []

    def add(pkg, reason, confidence="Review"):
        out.append((pkg, reason, confidence))

    if "nvidia" in text and device.device_class == "Graphics":
        add("ubuntu-drivers-common",
            "Use Ubuntu's hardware-aware ubuntu-drivers tool to identify the recommended NVIDIA branch.")
    elif any(v in text for v in ("intel", "advanced micro devices", "amd")) and device.device_class == "Graphics":
        add("mesa-vulkan-drivers",
            "Ubuntu Mesa userspace support; the kernel driver is normally supplied by the Ubuntu kernel.")
    elif device.device_class == "Network":
        add("linux-firmware",
            "Common Ubuntu firmware bundle; verify the exact Wi-Fi chipset and firmware requirement.")
        if "intel" in text:
            add("firmware-iwlwifi",
                "Potential Intel wireless firmware package; confirm the adapter model and Ubuntu release.")
    elif device.device_class == "Bluetooth":
        add("bluez", "Bluetooth userspace stack; kernel support is provided by Ubuntu.")
    elif device.device_class == "Audio":
        add("alsa-utils", "Audio diagnostic utilities; kernel audio drivers are provided by Ubuntu.")
    elif device.device_class == "Printer":
        add("cups", "Printing service; confirm printer model and supported driver.")
        add("printer-driver-all", "Broad collection of open-source printer drivers.")
    elif device.device_class in ("Storage", "USB", "Input", "Camera", "Other"):
        add("linux-firmware",
            "Some devices require firmware from Ubuntu's firmware package; check device-specific documentation.")
    return out
