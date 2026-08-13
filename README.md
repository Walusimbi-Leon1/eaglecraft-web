# Eaglecraft Web

Host Eaglecraft 1.12.2 (Minecraft for the browser) on a VPS, served through a trycloudflare tunnel.

## What is this?

[Eaglecraft](https://github.com/armorstark/eaglejs) is an open-source Minecraft client written in JavaScript that runs entirely in a browser. It lets you play Minecraft 1.12.2 — including connecting to any Minecraft server — with **no client download required**. Just open the URL and play.

This repo provides scripts to deploy Eaglecraft on a Linux VPS so you can play from any device with a browser, using the VPS's resources instead of your local machine.

## Quick Start

On a fresh VPS (Ubuntu 22.04 / Debian 12 recommended):

```bash
curl -sL https://raw.githubusercontent.com/Walusimbi-Leon1/eaglecraft-web/main/setup.sh | bash -s --
curl -sL https://raw.githubusercontent.com/Walusimbi-Leon1/eaglecraft-web/main/start.sh | bash -s --
```

This will install all dependencies, download Eaglecraft, and launch it behind a trycloudflare tunnel.

## What's Included

- `setup.sh` — installs Node.js, downloads Eaglecraft 1.12.2, and sets up the server
- `start.sh` — launches Eaglecraft and creates a trycloudflare tunnel URL you can open in any browser
- `config.json` — Eaglecraft configuration (server list, settings)

## Requirements

- A Linux VPS (minimum 2GB RAM recommended; Eaglecraft is lightweight but the Minecraft server connection uses memory)
- Root or sudo access

## How It Works

1. **setup.sh** installs Node.js, downloads the Eaglecraft client from the official GitHub releases, and writes a `config.json` with server presets.
2. **start.sh** launches a lightweight static file server (`python3 -m http.server`) to serve the Eaglecraft HTML/JS files, then starts a `cloudflared` tunnel so you get a public `https://<subdomain>.trycloudflare.com` URL.
3. Open that URL in any browser → play Minecraft 1.12.2 using the VPS's CPU/network for the connection. Your browser handles rendering.

The tunnel forwards HTTP/HTTPS to port 8080 where Eaglecraft is served. Your client (e.g., a phone or low-RAM laptop) downloads the JS/WASM once, then streams world data from the server you connect to through the VPS.

## Files

| File | Description |
|---|---|
| `setup.sh` | One-command install script (idempotent) |
| `start.sh` | Launches Eaglecraft + cloudflared tunnel, prints URL |
| `config.json` | Eaglecraft settings and server list |
| `README.md` | This file |
