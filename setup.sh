#!/usr/bin/env bash
set -euo pipefail

# Eaglecraft Web Setup Script
# Installs dependencies and downloads Eaglecraft 1.12.2 (WASM-GC) for browser play
# Idempotent: safe to run multiple times

EAGLECRAFT_DIR="$HOME/eaglecraft-web"
# Official Eaglecraft 1.12.2 WASM-GC offline download from eaglercraft.com CDN
EAGLECRAFT_DOWNLOAD_URL="https://cdn.eaglercraft.ru/dl/1.12.2/Eaglercraft_1.12.2_u3_WASM_Offline.zip"

echo "=== Eaglecraft Web Setup ==="

# --- Install dependencies ---
if ! command -v cloudflared &>/dev/null; then
    echo "Installing cloudflared..."
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o /tmp/cloudflared.deb
    sudo dpkg -i /tmp/cloudflared.deb 2>/dev/null || sudo apt install -y /tmp/cloudflared.deb
    rm -f /tmp/cloudflared.deb
fi

if ! command -v python3 &>/dev/null; then
    echo "Installing python3..."
    sudo apt update && sudo apt install -y python3
fi

if ! command -v unzip &>/dev/null; then
    echo "Installing unzip..."
    sudo apt update && sudo apt install -y unzip
fi

# --- Create directory ---
mkdir -p "$EAGLECRAFT_DIR"
cd "$EAGLECRAFT_DIR"

# --- Download Eaglecraft 1.12.2 WASM-GC Offline ---
echo "Downloading Eaglecraft 1.12.2 (WASM-GC)..."
curl -L "$EAGLECRAFT_DOWNLOAD_URL" -o /tmp/eaglecraft.zip

# Extract the zip — it contains the HTML/JS/WASM files for browser play
unzip -o /tmp/eaglecraft.zip -d "$EAGLECRAFT_DIR"
rm -f /tmp/eaglecraft.zip

# --- Create index.html that directly loads Eaglecraft in full-screen ---
# The Eaglecraft HTML file is designed to be served as the main page,
# NOT embedded in an iframe. We create an index.html that redirects
# to the Eaglecraft HTML file so the game renders at full size.
MAIN_HTML=""
for f in "$EAGLECRAFT_DIR"/*.html; do
    if [ -f "$f" ]; then
        MAIN_HTML="$(basename "$f")"
        break
    fi
done

cat > "$EAGLECRAFT_DIR/index.html" << HTMLEOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="0; url=./${MAIN_HTML:-eaglecraft.html}">
    <style>
        html, body {
            margin: 0;
            padding: 0;
            height: 100%;
            overflow: hidden;
            background: #000;
        }
    </style>
</head>
<body>
    <!-- Redirect to Eaglecraft — it handles full-screen rendering natively -->
    <script>
        window.location.href = "./${MAIN_HTML:-eaglecraft.html}";
    </script>
</body>
</html>
HTMLEOF

echo ""
echo "Setup complete!"
echo "Files downloaded to: $EAGLECRAFT_DIR"
echo "To start: bash start.sh"
echo ""
echo "Open the trycloudflare URL in your browser to play Minecraft 1.12.2."