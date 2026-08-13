# Eaglecraft Web

Host Eaglecraft 1.12.2 (Minecraft for the browser) on a VPS, served through a trycloudflare tunnel.

## What is this?

[Eaglecraft](https://www.eaglercraft.com/) is an open-source Minecraft client written in JavaScript/WASM that runs entirely in a browser. It lets you play Minecraft 1.12.2 — including connecting to Minecraft servers — with **no client download required**. Just open the URL and play.

This repo provides scripts to deploy Eaglecraft on a Linux VPS so you can play from any device with a browser, using the VPS's resources instead of your local machine.

## Quick Start

On a fresh VPS (Ubuntu 22.04 / Debian 12 recommended):

```bash
curl -sL https://raw.githubusercontent.com/Walusimbi-Leon1/eaglecraft-web/main/setup.sh | bash -s --
curl -sL https://raw.githubusercontent.com/Walusimbi-Leon1/eaglecraft-web/main/start.sh | bash -s --
```

This will install all dependencies, download Eaglecraft 1.12.2, and launch it behind a trycloudflare tunnel.

## What's Included

- `setup.sh` — installs dependencies, downloads Eaglecraft 1.12.2 (WASM-GC offline), extracts to `~/eaglecraft-web/`
- `start.sh` — launches a static file server on port 8080 and creates a trycloudflare tunnel URL
- `README.md` — this file

## Requirements

- A Linux VPS (minimum 2GB RAM, 1 CPU core recommended)
- Root or sudo access
- ~150MB disk for Eaglecraft files + cloudflared

## How It Works

1. **setup.sh** installs `cloudflared`, `python3`, and `unzip`, then downloads the [official Eaglecraft 1.12.2 WASM-GC offline zip](https://www.eaglercraft.com/p/downloads) from `cdn.eaglercraft.ru`. The files are extracted to `~/eaglecraft-web/`.

2. **start.sh** launches a lightweight static file server (`python3 -m http.server 8080`) to serve the Eaglecraft HTML/JS/WASM files, then starts a `cloudflared` quick tunnel so you get a public `https://<random>.trycloudflare.com` URL.

3. Open that URL in any browser → play Minecraft 1.12.2 using the VPS's CPU/network. Your browser handles rendering with WASM.

The tunnel forwards HTTP traffic from the Cloudflare edge to port 8080 on the VPS where Eaglecraft is served. Your client (e.g., a phone or low-RAM laptop) downloads the WASM module once, then streams world data from the Minecraft server you connect to through the VPS.

## Files

| File | Description |
|---|---|
| `setup.sh` | One-command install + download script (idempotent) |
| `start.sh` | Launches Eaglecraft + cloudflared tunnel, prints URL |
| `README.md` | This file |

## Notes

- The trycloudflare URL is random and changes each time you run `start.sh`.
- To stop Eaglecraft: `pkill -f "cloudflared tunnel"` and `pkill -f "http.server 8080"`
- Eaglecraft 1.12.2 (u3, WASM-GC) is the latest official release.
- The `index.html` file created by setup.sh redirects to the main Eaglecraft HTML file for proper full-screen rendering. Do **not** wrap it in an iframe — Eaglecraft handles its own full-size rendering.