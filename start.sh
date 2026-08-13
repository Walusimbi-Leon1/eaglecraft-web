#!/usr/bin/env bash
set -euo pipefail

# Eaglecraft Web Start Script
# Launches a static file server for Eaglecraft and creates a trycloudflare tunnel

EAGLECRAFT_DIR="$HOME/eaglecraft-web"
PORT=8080

cd "$EAGLECRAFT_DIR"

echo "=== Starting Eaglecraft Web ==="
echo "Serving files from: $EAGLECRAFT_DIR"
echo ""

# --- Start the HTTP server in background ---
echo "Starting static file server on port $PORT..."
python3 -m http.server $PORT > "$EAGLECRAFT_DIR/server.log" 2>&1 &
HTTP_PID=$!

# Wait for server to be ready
sleep 1
if curl -s "http://localhost:$PORT/" > /dev/null 2>&1; then
    echo "Static server is running."
else
    echo "ERROR: Static server failed to start. Check server.log"
    exit 1
fi

# --- Create trycloudflare tunnel ---
echo "Creating trycloudflare tunnel..."
# Generate a random subdomain
RANDOM_SUBDOMAIN=$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c 8)

# Start cloudflared tunnel in background, capturing the URL
cloudflared tunnel --url http://localhost:$PORT --hostname "$RANDOM_SUBDOMAIN--eaglecraft.trycloudflare.com" > "$EAGLECRAFT_DIR/tunnel.log" 2>&1 &
TUNNEL_PID=$!

# Wait for tunnel to be established and extract the URL
echo "Waiting for tunnel..."
TUNNEL_URL=""
for i in $(seq 1 15); do
    sleep 1
    # Look for the trycloudflare URL in the log
    TUNNEL_URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$EAGLECRAFT_DIR/tunnel.log" | head -1 || true)
    if [ -n "$TUNNEL_URL" ]; then
        break
    fi
done

if [ -n "$TUNNEL_URL" ]; then
    echo ""
    echo "========================================"
    echo " Eaglecraft is now running!"
    echo "========================================"
    echo "URL: $TUNNEL_URL"
    echo ""
    echo "Open this URL in any browser to play Minecraft 1.12.2."
    echo "The tunnel forwards HTTP to the Eaglecraft static file server on port $PORT."
    echo ""
    echo "Server PID: $HTTP_PID"
    echo "Tunnel PID: $TUNNEL_PID"
    echo ""
    echo "To stop: kill $HTTP_PID $TUNNEL_PID"
else
    echo "ERROR: Failed to establish trycloudflare tunnel."
    echo "Check tunnel.log:"
    cat "$EAGLECRAFT_DIR/tunnel.log"
fi

# Keep the script running so the PIDs aren't orphaned
wait $TUNNEL_PID 2>/dev/null || true