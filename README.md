# font-smoothing

Small macOS CLI for **font smoothing** — both the legacy LCD / subpixel path and the strength knob (`AppleFontSmoothing`).

Handy when:

- Text looks thin or soft on a **non-Retina** external (e.g. Apple Thunderbolt Display)
- Text looks a bit **too thick** on **Retina** (e.g. Studio Display + Terminal) and you want a lighter setting

## Two related controls

| Key | What it does |
|-----|----------------|
| `CGFontRenderingFontSmoothingDisabled` | Master switch for the legacy LCD / subpixel path |
| `AppleFontSmoothing` | Strength: **0** off → **1** light → **2** medium → **3** strong |

They belong together: strength alone does little if the legacy path is off. This tool manages both in one place (no need for a second script).

**System-wide** (via `defaults`), not Terminal-only. Quit and reopen Terminal (or log out/in) after changes.

## Install

```bash
git clone https://github.com/weiyou/toggle-font-smoothing.git
cd toggle-font-smoothing

chmod +x font-smoothing.sh
# optional PATH install
ln -s "$(pwd)/font-smoothing.sh" /usr/local/bin/font-smoothing
```

`toggle-font-smoothing.sh` is a symlink to the same script (old name still works).

## Usage

```bash
# show current settings
./font-smoothing.sh

# enable legacy LCD path (sets strength to medium)
./font-smoothing.sh enable

# disable / restore macOS default
./font-smoothing.sh disable

# set strength only (0–3)
./font-smoothing.sh level 1    # light — good if Terminal feels too heavy on Retina
./font-smoothing.sh level 0    # off — thinnest
./font-smoothing.sh level 2    # medium — classic non-Retina feel
./font-smoothing.sh level 3    # strong

# shorthand
./font-smoothing.sh 1          # same as: level 1
./font-smoothing.sh level      # print strength only
```

Aliases: `on` / `off`, `-e` / `-d`, `status` / `show`.

### Strength guide

| Level | Name   | When to use |
|------:|--------|-------------|
| 0 | off | Thinnest; often preferred on pure Retina |
| 1 | light | Slightly smoothed; try if medium feels thick in Terminal |
| 2 | medium | Default when you `enable`; solid for non-Retina LCDs |
| 3 | strong | Heaviest |

## Example: thinner Terminal on Studio Display

If you like the non-Retina LCD look but Terminal is a bit heavy on a Retina panel:

```bash
./font-smoothing.sh enable   # if not already on
./font-smoothing.sh level 1  # or 0
# then quit and reopen Terminal
```

## Example status

```
macOS Font Smoothing
----------------------
Legacy LCD / subpixel: ENABLED
Strength (AppleFontSmoothing): 1 (light)

Details:
  CGFontRenderingFontSmoothingDisabled = 0
  AppleFontSmoothing = 1 (light)

Note: Changes often need logout/login, or at least quit/reopen the app (e.g. Terminal).
```

## Notes

- `enable` turns the legacy path on and sets strength to **2 (medium)**; use `level` afterward to fine-tune.
- `disable` turns the legacy path off and clears `AppleFontSmoothing`.
- Setting `level` 1–3 enables the legacy path if it was off.
- Only those two defaults are touched.

## License

MIT — free to use, copy, and modify.
