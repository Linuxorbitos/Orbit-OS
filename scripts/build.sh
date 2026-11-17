#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/dist/Orbit-OS"
rm -rf "$OUT"
mkdir -p "$OUT"
cp -r "$ROOT/app" "$ROOT/assets" "$ROOT/packaging" "$ROOT/requirements.txt" "$OUT/"
cp "$ROOT/README.md" "$OUT/"
cat > "$OUT/run-orbit.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
export PYTHONPATH="$PWD/app"
exec python app/main.py
EOF
chmod +x "$OUT/run-orbit.sh"
echo "Created $OUT"
