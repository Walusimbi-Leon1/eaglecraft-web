#!/usr/bin/env bash
set -euo pipefail

# Eaglecraft Web Setup Script
# Installs dependencies and downloads Eaglecraft 1.12.2 for browser play
# Idempotent: safe to run multiple times

EAGLECRAFT_DIR="$HOME/eaglecraft-web"
EAGLECRAFT_RELEASE_URL="https://github.com/armorstark/eaglejs/releases/latest/download/eaglecraft-1.12.2-web.zip"
CONFIG_URL="https://raw.githubusercontent.com/armorstark/eaglejs/master/configs/default_1.12.2.json"

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

# --- Create directory ---
mkdir -p "$EAGLECRAFT_DIR"
cd "$EAGLECRAFT_DIR"

# --- Download Eaglecraft ---
echo "Downloading Eaglecraft 1.12.2..."
if [ ! -f "eaglecraft.html" ]; then
    # Download the release zip and extract
    curl -L "$EAGLECRAFT_RELEASE_URL" -o /tmp/eaglecraft.zip
    # Check if it's a zip or single file
    if file /tmp/eaglecraft.zip | grep -q "Zip"; then
        unzip -o /tmp/eaglecraft.zip -d "$EAGLECRAFT_DIR" 2>/dev/null || true
    fi
    rm -f /tmp/eaglecraft.zip
fi

# If the release zip didn't give us the HTML file, download the standalone version
if [ ! -f "$EAGLECRAFT_DIR/eaglecraft.html" ]; then
    echo "Falling back to direct download..."
    curl -L "https://raw.githubusercontent.com/armorstark/eaglejs/master/dist/eaglecraft-1.12.2-web.html" -o "$EAGLECRAFT_DIR/eaglecraft.html" 2>/dev/null || true
fi

# --- Download or create config ---
curl -s "$CONFIG_URL" -o "$EAGLECRAFT_DIR/config.json" 2>/dev/null || true

if [ ! -f "$EAGLECRAFT_DIR/config.json" ]; then
    cat > "$EAGLECRAFT_DIR/config.json" << 'JSONEOF'
{
    "name": "Eaglecraft 1.12.2",
    "version": "1.12.2",
    "servers": [
        {"name": "Minemen", "address": "minemen.club"},
        {"name": "Jart", "address": "mc.jart.codes"},
        {"name": "Eagler", "address": "eaglerbriggs.mcc.gg"}
    ]
}
JSONEOF
fi

# --- Create a simple index.html that loads Eaglecraft ---
if [ ! -f "$EAGLECRAFT_DIR/index.html" ]; then
    cat > "$EAGLECRAFT_DIR/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>Eaglecraft Web</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>body { margin: 0; padding: 0; overflow: hidden; background: #000; }</style>
</head>
<body>
    <div id="eaglecraft-container"></div>
    <script src="eaglecraft.html" type="module"></script>
</body>
</html>
HTMLEOF
fi

echo "Setup complete! Files in $EAGLECRAFT_DIR"
echo "Run 'bash $EAGLECRAFT_DIR/../start.sh' to start the server."