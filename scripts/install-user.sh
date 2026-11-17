#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/scalable/apps"
cat > "$HOME/.local/bin/orbit" <<EOF
#!/usr/bin/env bash
ROOT="$ROOT"
cd "\$ROOT"
source "\$ROOT/.venv/bin/activate"
export PYTHONPATH="\$ROOT/app"
exec python "\$ROOT/app/main.py" "\$@"
EOF
chmod +x "$HOME/.local/bin/orbit"
cp "$ROOT/packaging/orbit.desktop" "$HOME/.local/share/applications/orbit.desktop"
cp "$ROOT/assets/orbit.svg" "$HOME/.local/share/icons/hicolor/scalable/apps/orbit.svg"
echo "Orbit launcher installed for this user. Ensure ~/.local/bin is in PATH."
