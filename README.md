# Black Hole Screensaver

A real-time ray-traced Schwarzschild black hole for your Windows desktop.

Ported from [s0xDk/ghostty-blackhole](https://github.com/s0xDk/ghostty-blackhole) — originally a Ghostty terminal shader, now a standalone screensaver that needs no terminal at all.

## Demo

The black hole roams freely across your screen, growing and shrinking organically while cycling through 8 different accretion disk looks — Inferno, Gargantua, M87\* donut, Face-on ember, Quasar, Blazar, Pure lens — with smooth crossfades. Every 60-second loop is slightly different thanks to hash-based randomization.

## Physics

Every pixel computes its own Schwarzschild null geodesic. Nothing is painted on — it all falls out of the integration:

- **Shadow** — rays with impact parameter under `b_crit = (3√3/2) r_s` spiral into the horizon
- **Gravitational lensing** — escaped rays bend, magnify, and mirror inside the Einstein ring
- **Accretion disk** — Keplerian disk with Shakura–Sunyaev blackbody coloring, relativistic Doppler beaming, and gravitational time dilation
- **Photon ring** — emergent from rays winding near `1.5 r_s`, not drawn
- **Chromatic aberration** — blue bends slightly more than red in the weak-field region

## Download

Grab `blackhole.scr` from the [latest release](https://github.com/gkd2323c/blackhole-screensaver/releases/latest).

## Install

1. Copy `blackhole.scr` to `%SYSTEMROOT%\System32\`
2. Right-click Desktop → Personalize → Lock screen → Screen saver settings
3. Select **Black Hole** from the dropdown
4. Click **Settings** to adjust star brightness, disk opacity, and Doppler effect

Or just double-click `blackhole.scr` to preview it immediately.

## Build from Source

Requires MSVC (Visual Studio Build Tools). In a Developer Command Prompt:

```bat
cl /O2 /W3 /nologo /D_CRT_SECURE_NO_WARNINGS /Fe:blackhole.scr ^
    blackhole_screensaver.c opengl32.lib user32.lib gdi32.lib advapi32.lib shell32.lib comctl32.lib ^
    /link /SUBSYSTEM:WINDOWS
```

Or run `build.bat`.

## How It Works

A single C file (~30KB) embeds the entire GLSL fragment shader as a string literal. The Win32 host creates a fullscreen OpenGL 3.3 context, compiles the shader, and renders a fullscreen quad every frame. The vertex shader uses `gl_VertexID` to generate the quad without any vertex buffer.

- **Zero dependencies** — only Win32 API + OpenGL
- **Single .scr file** — no installer, no DLLs, no registry entries (beyond what Windows screensaver settings manage)
- **Config dialog** — three sliders for visual tuning, stored in `HKCU\Software\BlackHoleScreensaver`

## System Requirements

- Windows 10 or 11
- Any GPU with OpenGL 3.3 support (virtually all GPUs made after 2010)

## License

MIT License — see [LICENSE](LICENSE).

The accretion disk shader is adapted from [s0xDk/ghostty-blackhole](https://github.com/s0xDk/ghostty-blackhole) (also MIT). The Windows screensaver host is original.
