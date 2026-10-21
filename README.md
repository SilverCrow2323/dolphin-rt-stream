# MockRt:Core

**Stream GameCube and Wii games from your PC to a muOS handheld — with a GameCube-style 2.5D interface on both ends.**

MockRt:Core keeps your ROMs and Dolphin on the PC, and turns your handheld (tested on the Anbernic RG35XX H) into a
console-like front end: a cover-flow library, a boot animation, and a streaming session through
[Sunshine](https://github.com/LizardByte/Sunshine) / [Moonlight](https://github.com/moonlight-stream/moonlight-embedded).
You can see **and edit the Dolphin controller mapping from the handheld itself**.

![MockRt:Core on the handheld: library, controller mapping, menus](docs/img/muos-hero.png)

## Highlights

**On the handheld (muOS app "Dolphin Stream")**
- Cover Flow / Grid / List library with GameCube, Wii and Favorites tabs (Recent games merged into Favorites), play
  counters, per-game stream profiles, live search
- GameCube-style boot animation (120-frame sprite sheet + "Mock Rt:Core" logo with electric flicker), animated menus,
  big touch-free UI made for a 3.5" screen
- **SERVER STATUS panel** with SUNSHINE and LIBRARY LEDs (green = reachable, red = down, gray = unknown), refreshed every
  15 s in the background
- **Pre-flight host check**: pressing A on a game pings the PC first. If the PC is off, you get a clear error instead of
  5 seconds of "CONNECTING TO STREAM"
- **Guide panel (M)**: on any menu item, press **M** to open a help panel with a short intro and, for options with
  selectable values, per-value descriptions with a ✓ recommended marker and a ▲ warning marker
- **Controls screen**: the virtual Xbox pad drawn on screen, the selected mapping lit up, left/right to change a binding,
  Y to switch profile — changes are validated and written to the PC
- **Menu structure**: quick actions (Search, Sync) on top, then STREAMING, CONTROLLER PROFILES, INTERFACE, TOOLS.
  Advanced options live in overlay panels with an intro and inline descriptions
- Colored icons per category across menus, submenus and overlays; uppercase section titles
- **Tools**: connection test, Sunshine pairing (PIN on screen), last-stream log, diagnostics export, verify Sunshine
  apps, disk space, measure latency, controller profiles, reset (statistics / favorites / streaming / cover cache), about
- 5 themes, on-screen keyboard, English UI, everything reachable with the handheld's own buttons

**On the PC (MockRt:Core Stream Portal, `.deb`)**
- Scans your ROM folders **at every start** (and on demand), downloads cover art, registers one Sunshine app per game
- Launches Dolphin **fullscreen, no main window, no desktop**; hides the XFCE panel while streaming
- Switches the PC to a **4:3 display mode during the stream** so a 4:3 game fills the handheld screen (no black bars),
  and restores it afterwards
- Controller **profile manager**: GCPad / Wiimote / Hotkeys families, written into Dolphin before every launch
- Library server for the handheld, autostart helpers (Sunshine, server, portal), optional LightDM autologin

## How it works

```
 ┌──────────── PC (Linux, X11) ────────────┐                    ┌──────── Handheld (muOS) ────────┐
 │  MockRt:Core portal  ── scans ROMs      │   HTTP :8765       │  Dolphin Stream (LÖVE app)      │
 │  Library server  ─────── library.tsv ───┼───────────────────▶│  cover flow, menus, Controls    │
 │                   ─────── profiles.tsv ─┼───────────────────▶│                                 │
 │                   ◀────── /ctl (token) ─┼────────────────────│  edit a binding                 │
 │  Sunshine ── one app per game           │   Moonlight        │  Moonlight (moonlight-embedded) │
 │   └ prep: profiles → panel → 4:3 mode   │◀═══ video/audio ═══│  pad ──▶ virtual Xbox pad       │
 │   └ Dolphin -b -e game -C Fullscreen    │════ controller ═══▶│                                 │
 └─────────────────────────────────────────┘                    └─────────────────────────────────┘
```

More detail: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) · wire formats and security: [docs/PROTOCOL.md](docs/PROTOCOL.md).

## Quick start

### Requirements
| | |
|---|---|
| PC | Linux with **X11** (XFCE / MX Linux tested), Python ≥ 3.9 with Tk, [Dolphin](https://dolphin-emu.org), [Sunshine](https://github.com/LizardByte/Sunshine) |
| Handheld | muOS with the LÖVE runtime and a `moonlight-embedded` build (the usual "Moonlight" port) |
| Network | LAN, or Tailscale/WireGuard between the two |

### 1. PC
```bash
sudo apt install ./spdw-stream-portal_<version>_all.deb       # pulls python3-tk, python3-pil, ...
spdw-stream-portal                                            # or start it from the menu: "MockRt:Core Stream Portal"
```
1. **LIBRARY**: add your GameCube / Wii ROM folders — the portal scans them right away (and at every start).
2. **SERVICES**: install/start Sunshine, start the library server. Tick the autostart boxes you want.
3. **SYSTEM**: the checklist should be green. Install the controller profiles, note the **edit token**.
4. Restart Sunshine once so it sees the new apps.

### 2. Handheld
1. Copy `DolphinStream/` to `ROMS/APPLICATIONS` (keep your own `love`, `libs/`, `moonlight/`, `keys/` next to it — they
   are not part of this repo).
2. Start it. **START ▸ Streaming**: set *PC host* (IP of the PC) and *Edit token* (from the portal).
3. **START ▸ Tools ▸ Pair with Sunshine**: type the PIN shown on screen into Sunshine's web UI (PIN tab).
4. **SELECT** to sync the library, **A** to play.

Leave a stream with the Moonlight combo **START + SELECT + L1 + R1**, or the Dolphin hotkey **MODE + START**.

## Controls on the handheld

| Button | Library | Menus | Overlays / Guides |
|---|---|---|---|
| D-pad ◀ ▶ | previous / next cover | change value / swap quick action | – |
| D-pad ▲ ▼ | jump 4 covers (Flow) / row | move | move / scroll |
| L1 / R1 | switch tab | previous / next section | – |
| A | play | confirm / open | select |
| X | favorite (or edit search) | – | – |
| Y | game menu (per-game profile) | switch profile (Controls) | – |
| **M** | – | **open guide** | **open guide** |
| SELECT | sync with the PC | – | toggle keyboard view (Controls) |
| START | main menu | close all | close |
| B | exit | back | back / close |

## Controller profiles in 30 seconds

Dolphin sees the handheld as a **Sunshine virtual Xbox pad**. The default `muos` profiles are in
[`pc/profiles`](pc/profiles); the full reference is in [docs/CONTROLS.md](docs/CONTROLS.md).

| Kind | Profiles | Notes |
|---|---|---|
| GCPad | `muos`, `muos-xbox` | `muos` = layout tested on the RG35XX H; `muos-xbox` = standard Xbox positions |
| Wiimote | `muos`, `muos-nunchuk` | sideways remote for 2D games; remote + nunchuk with IR on the right stick |
| Hotkeys | `muos`, `muos-minimal` | everything on a **MODE layer** (hold MODE): Exit, Pause, save/load state, volume, speed |

Hotkeys (`muos`): `MODE+START` exit · `MODE+SELECT` pause · `MODE+TL/TR` save/load slot 1 · `MODE+D-pad ▲▼` volume ·
`MODE+D-pad ◀▶` emulation speed · `MODE+Y` screenshot. *Toggle Fullscreen* is deliberately unmapped: it would bring the
desktop back into the stream.

Change anything from the handheld (**START ▸ CONTROLLER PROFILES**), from the portal (SYSTEM ▸ CONTROLLER PROFILES) or
the CLI:
```bash
spdw-stream profiles list
spdw-stream profiles set GCPad muos Buttons/Z TL      # edit one binding
spdw-stream profiles active Wiimote muos-nunchuk      # switch profile
spdw-stream profiles apply --backup                   # write the active ones into Dolphin now
```

## No more black bars

A 16:9 desktop is letterboxed on a 4:3 handheld, so 4:3 games end up small. While a game streams, MockRt:Core switches
the PC display to a **4:3 mode** (default `1280x960`, via `xrandr`, X11 only) and restores the original mode afterwards.
Dolphin fills that mode, the stream fills the handheld screen, nothing is stretched. Configure it in
**SYSTEM ▸ DISPLAY ▸ Stream display mode** (or keep the current mode). Stuck in 4:3 after a crash?
`sh /usr/lib/spdw-stream-portal/display-mode.sh restore`.

## Screenshots

| | |
|---|---|
| ![library](docs/img/portal-library.png) | ![services](docs/img/portal-services.png) |
| ![system](docs/img/portal-system.png) | ![profiles](docs/img/portal-system-profiles.png) |
| ![flow](docs/img/muos-flow.png) | ![controls](docs/img/muos-controls-gc.png) |
| ![hotkeys](docs/img/muos-controls-hotkeys.png) | ![menu](docs/img/muos-menu.png) |
| ![guide](docs/img/muos-guide.png) | ![server-status](docs/img/muos-server-status.png) |

Boot animation (frames): ![boot](docs/img/muos-boot.png)

*All cover art in the screenshots is generated demo art.*

## Repository layout

```
muos/DolphinStream/   handheld app (LÖVE/Lua + POSIX shell)         → copy to ROMS/APPLICATIONS
pc/portal/            Tk portal, core, profile manager, helper scripts
pc/profiles/          Dolphin controller profiles (GCPad / Wiimote / Hotkeys)
pc/assets/            logos, cube sprites, Orbitron font (OFL)
pc/standalone/        no-GUI script: scan ROMs, write Sunshine apps, serve the library
pc/packaging/debian/  .deb metadata
tools/                build-deb.sh, build-muos.sh
tests/                unit tests + headless GUI tests
docs/                 architecture, protocol, controls, troubleshooting, development
```

## Build and test from source

```bash
make test        # python unittest + headless Lua GUI tests (pip install lupa pillow; apt install python3-tk)
make deb         # dist/spdw-stream-portal_<version>_all.deb
make muos        # dist/DolphinStream-muOS-<version>.zip
```
Details in [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Status

| Area | Verified |
|---|---|
| Profile manager, server, token checks, standalone script | automated tests (CI) |
| Handheld UI, boot animation, Controls screen | rendered with real LÖVE 11.5 (software GL) and a headless mock fuzz |
| Handheld → PC profile edit | tested end-to-end (LÖVE app ↔ real library server) |
| Search, pre-flight ping, health LEDs, guide panel | tested on MX Linux (desktop, windowed LÖVE 11.5) and on real RG35XX H hardware |
| Dolphin `-C` fullscreen flags, hotkey/Wiimote key names, `xrandr` 4:3 switch, panel hiding, Moonlight pairing | written to Dolphin/Moonlight/XFCE conventions, **confirmed on real hardware for the base flow**; please report your device if something differs |

## Credits and licenses

- Code: [MIT](LICENSE). Logos (Dolphin Rt:Core, MockRt:Core, SPDW) © SPDW Factory Lab, not covered by the MIT license.
- Font: [Orbitron](https://github.com/theleagueof/orbitron), SIL Open Font License 1.1 (`pc/assets/OFL-Orbitron.txt`).
- Built on [Dolphin](https://dolphin-emu.org), [Sunshine](https://github.com/LizardByte/Sunshine),
  [Moonlight](https://github.com/moonlight-stream), [LÖVE](https://love2d.org), cover art lookups on
  [GameTDB](https://www.gametdb.com).
- *GameCube* and *Wii* are trademarks of Nintendo. This project is not affiliated with or endorsed by Nintendo. The
  GC/Wii logos used as small tab icons can be removed from `assets/` without affecting functionality.
- **No ROMs, BIOS or firmware are included or distributed.** Use your own legally obtained backups.