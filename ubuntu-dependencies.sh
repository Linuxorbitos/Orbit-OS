#!/usr/bin/env bash
set -euo pipefail
sudo apt update
sudo apt install -y python3 python3-venv python3-pip git build-essential \
  flatpak xdg-desktop-portal xdg-desktop-portal-gtk \
  network-manager linux-firmware mesa-vulkan-drivers
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo "Ubuntu dependencies and Flathub remote configured."
