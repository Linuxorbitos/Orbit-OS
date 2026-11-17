# Orbit OS

Orbit OS is an Ubuntu-based x86_64 desktop project with a Qt 6 / QML interface.
This repository currently contains a **runnable desktop prototype**: setup wizard,
desktop shell, app launcher, settings, and starter apps. It is not yet a complete
Linux distribution or bootable ISO.

## Features in this source release

- Purple-and-orange Orbit visual theme
- First-run flow: Welcome/language → Wi-Fi guidance → Login or Create Account → Finished
- Local demo account registration and login using SQLite + PBKDF2 password hashes
- Desktop wallpaper, desktop shortcuts, Trash shortcut, taskbar, profile menu, date/time
- All Apps launcher with search
- Settings sections: Personalization, Account, Security, Advanced, Drivers
- Integrated Orbit hardware inventory and Ubuntu driver recommendations
- Flathub link and DuckDuckGo browser shortcut
- Clock, Files, Calculator, Calendar, Music, Photos, Terminal, Weather starter apps
- Ubuntu setup scripts and `.desktop` launcher

## Important implementation boundaries

- The account service in this prototype stores accounts **locally on the computer** in
  `~/.local/share/orbit/accounts.sqlite3`. It does not create real `@orbit.com` mailboxes
  and does not sync credentials to a remote server.
- Passwords are never stored in plaintext; PBKDF2-HMAC-SHA256 hashes and random salts
  are stored locally. A production service needs HTTPS, server-side password hashing,
  rate limiting, account recovery, verified email ownership, and a carefully designed
  sync protocol. Do not collect real user passwords with an unfinished server.
- The Flathub page opens in the system browser. A production app store needs a Flatpak
  client integration, permissions review, install/uninstall/update workflows, and
  user confirmation.
- The browser shortcut opens DuckDuckGo in the system's default browser. It is not a
  bundled browser engine yet.
- Orbit's integrated Drivers settings page performs read-only hardware scans and shows
  Ubuntu driver recommendations. Package installation is deliberately not automatic;
  use the reviewed Orbit Drivers CLI workflow for explicit confirmation.
- Linux hardware drivers are supplied by the Ubuntu/Linux kernel packages. This repo
  does not contain proprietary or custom kernel drivers.
- Reset and update controls in this prototype explain the intended action; they do not
  erase disks or modify system packages.

## Requirements

- Ubuntu 24.04 LTS (recommended) or a recent Ubuntu release
- x86_64 PC
- Python 3.10+
- Internet connection for first-time dependency installation

## Run from source

```bash
chmod +x scripts/*.sh
./scripts/run-dev.sh
```

The development script creates `.venv`, installs PySide6, then launches Orbit.

## Install desktop launcher for the current user

```bash
./scripts/install-user.sh
```

## Build a distributable folder

```bash
./scripts/build.sh
```

This creates `dist/Orbit-OS/` with the application sources and launcher.
For a real bootable OS image, create an Ubuntu-based image using Ubuntu live-build
tools or Cubic, add this application as a package, configure a display manager
session, and test in a VM before installing on physical hardware.

## Project layout

```text
Orbit-OS/
├── app/
│   ├── main.py
│   ├── orbit_backend.py
│   ├── orbit_drivers/
│   └── qml/
│       ├── Main.qml
│       └── components/
├── assets/
│   ├── orbit.svg
│   └── wallpapers/
├── packaging/
│   └── orbit.desktop
├── scripts/
│   ├── build.sh
│   ├── install-user.sh
│   └── run-dev.sh
├── requirements.txt
└── README.md
```

## Next milestones

1. Package Orbit as a proper Ubuntu `.deb`.
2. Add a dedicated Wayland desktop session and display-manager entry.
3. Integrate Flatpak through `flatpak`/`xdg-desktop-portal`.
4. Add a real browser using Qt WebEngine or ship a maintained browser.
5. Design a remote account API before enabling cloud accounts.
6. Build and test a bootable Ubuntu-based ISO in a virtual machine.
7. Validate hardware support against a documented device compatibility list.

## License

MIT. See `LICENSE`.
