# toggle-font-smoothing

Toggle **legacy LCD / subpixel font smoothing** on macOS — the setting that makes text look sharp on non-Retina displays (especially useful when you use an Apple Thunderbolt Display or similar alongside a Retina screen).

Apple disabled this by default after Mojave. On external non-Retina monitors, text can look thin or blurry. This script turns it back on (or off) with one command.

## Why this exists

When a Retina Mac is connected to a non-Retina external display, macOS often leaves subpixel antialiasing off. That hurts readability on older LCDs. This tool flips the relevant defaults:

| Key | Purpose |
|-----|---------|
| `CGFontRenderingFontSmoothingDisabled` | Master switch for legacy font smoothing |
| `AppleFontSmoothing` | Strength: 0 off → 1 light → 2 medium → 3 strong |

## Requirements

- macOS (tested on modern versions; uses standard `defaults`)
- No extra dependencies

## Install

```bash
# clone
git clone https://github.com/weiyou/toggle-font-smoothing.git
cd toggle-font-smoothing

# optional: put it on your PATH
chmod +x toggle-font-smoothing.sh
ln -s "$(pwd)/toggle-font-smoothing.sh" /usr/local/bin/toggle-font-smoothing
```

Or run it directly:

```bash
./toggle-font-smoothing.sh
```

## Usage

```bash
# show current status
./toggle-font-smoothing.sh

# enable (medium strength — good default for non-Retina)
./toggle-font-smoothing.sh --enable
# or: -e

# disable (restore macOS default)
./toggle-font-smoothing.sh --disable
# or: -d

# help
./toggle-font-smoothing.sh --help
```

**Important:** After enabling or disabling, log out and back in (or restart) so the change fully applies.

## Example output

```
Legacy LCD / Subpixel Font Smoothing
-------------------------------------
Status: ENABLED

Details:
  CGFontRenderingFontSmoothingDisabled = 0
  AppleFontSmoothing = 2 (medium)

Note: Changes require logout/login or restart to fully take effect.
```

## Notes

- Enabling sets `AppleFontSmoothing` to **2 (medium)**, a sensible default for non-Retina LCDs.
- Disabling removes the strength key and restores the post-Mojave default (smoothing off).
- Safe to re-run; it only touches the two font-smoothing related defaults above.

## License

MIT — free to use, copy, and modify.
