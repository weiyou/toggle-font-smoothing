#!/bin/bash

# font-smoothing.sh
# Manage macOS font smoothing:
#   - legacy LCD / subpixel path (CGFontRenderingFontSmoothingDisabled)
#   - smoothing strength (AppleFontSmoothing: 0–3)
#
# Useful for non-Retina externals (e.g. Thunderbolt Display) and for
# thinning text on Retina (e.g. Studio Display / Terminal).

set -euo pipefail

KEY="CGFontRenderingFontSmoothingDisabled"
SMOOTH_KEY="AppleFontSmoothing"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

level_label() {
    case "$1" in
        0) echo "off" ;;
        1) echo "light" ;;
        2) echo "medium" ;;
        3) echo "strong" ;;
        *) echo "unknown" ;;
    esac
}

get_disabled_value() {
    if defaults read -g "$KEY" &>/dev/null; then
        defaults read -g "$KEY"
    else
        # Not set → post-Mojave default is disabled (true / 1)
        echo "1"
    fi
}

is_legacy_enabled() {
    local val
    val=$(get_disabled_value)
    # 0 / NO / false → legacy smoothing enabled
    if [[ "$val" == "0" || "$val" == "NO" || "$val" == "false" || "$val" == "False" ]]; then
        return 0
    else
        return 1
    fi
}

get_level() {
    if defaults -currentHost read -g "$SMOOTH_KEY" &>/dev/null; then
        defaults -currentHost read -g "$SMOOTH_KEY"
    else
        echo ""
    fi
}

show_level_line() {
    local level
    level=$(get_level)
    if [[ -n "$level" ]]; then
        echo "  AppleFontSmoothing = $level ($(level_label "$level"))"
    else
        echo "  AppleFontSmoothing = (not set)"
    fi
}

show_state() {
    echo -e "${BLUE}macOS Font Smoothing${NC}"
    echo "----------------------"

    if is_legacy_enabled; then
        echo -e "Legacy LCD / subpixel: ${GREEN}ENABLED${NC}"
    else
        echo -e "Legacy LCD / subpixel: ${RED}DISABLED${NC} (macOS default)"
    fi

    local level
    level=$(get_level)
    if [[ -n "$level" ]]; then
        echo -e "Strength (AppleFontSmoothing): ${GREEN}$level${NC} ($(level_label "$level"))"
    else
        echo -e "Strength (AppleFontSmoothing): ${YELLOW}(not set)${NC}"
    fi

    echo
    echo "Details:"
    if defaults read -g "$KEY" &>/dev/null; then
        echo "  CGFontRenderingFontSmoothingDisabled = $(defaults read -g "$KEY")"
    else
        echo "  CGFontRenderingFontSmoothingDisabled = (not set → disabled by default)"
    fi
    show_level_line

    echo
    echo -e "${YELLOW}Note:${NC} Changes often need logout/login, or at least quit/reopen the app (e.g. Terminal)."
}

enable_legacy() {
    defaults write -g "$KEY" -bool NO
    # Sensible default for non-Retina LCDs; override with: level N
    defaults -currentHost write -g "$SMOOTH_KEY" -int 2

    echo -e "${GREEN}✓ Enabled${NC} legacy LCD / subpixel font smoothing."
    echo "  (AppleFontSmoothing set to 2 = medium; use 'level N' to fine-tune)"
    echo
    echo -e "${YELLOW}→ Log out/in, or quit and reopen apps, for the change to apply.${NC}"
    echo
    show_state
}

disable_legacy() {
    defaults write -g "$KEY" -bool YES
    defaults -currentHost delete -g "$SMOOTH_KEY" 2>/dev/null || true

    echo -e "${RED}✓ Disabled${NC} legacy LCD / subpixel font smoothing."
    echo "  (restored macOS default; AppleFontSmoothing cleared)"
    echo
    echo -e "${YELLOW}→ Log out/in, or quit and reopen apps, for the change to apply.${NC}"
    echo
    show_state
}

set_level() {
    local n="$1"

    if [[ ! "$n" =~ ^[0-3]$ ]]; then
        echo -e "${RED}Invalid level: $n${NC}"
        echo "Use 0 (off), 1 (light), 2 (medium), or 3 (strong)."
        exit 1
    fi

    defaults -currentHost write -g "$SMOOTH_KEY" -int "$n"

    # Level alone does little if legacy path is off — turn it on for 1–3
    if [[ "$n" -ge 1 ]]; then
        if ! is_legacy_enabled; then
            defaults write -g "$KEY" -bool NO
            echo -e "${YELLOW}Note:${NC} Legacy path was off; enabled it so strength can take effect."
        fi
    fi

    echo -e "${GREEN}✓ AppleFontSmoothing${NC} set to ${GREEN}$n${NC} ($(level_label "$n"))."
    case "$n" in
        0) echo "  Off — thinnest / least smoothed (often preferred on Retina)." ;;
        1) echo "  Light — subtle; good if medium feels too thick (e.g. Terminal on Studio Display)." ;;
        2) echo "  Medium — classic non-Retina LCD feel." ;;
        3) echo "  Strong — heaviest smoothing." ;;
    esac
    echo
    echo -e "${YELLOW}→ Quit and reopen Terminal (or log out/in) to see the change.${NC}"
    echo
    show_state
}

usage() {
    cat <<HELP
Usage: $(basename "$0") [COMMAND]

Manage macOS font smoothing (legacy LCD path + strength).

Commands:
  (none) | status | show     Show current settings
  enable | on | -e           Enable legacy LCD/subpixel smoothing
  disable | off | -d         Disable it (macOS default)
  level [0|1|2|3]            Set (or show) AppleFontSmoothing strength
  help | -h | --help         Show this help

Strength levels:
  0  off     — thinnest (often best on Retina / Studio Display)
  1  light   — subtle; try if Terminal looks too heavy
  2  medium  — classic non-Retina LCD (default when enabling legacy)
  3  strong  — heaviest

Examples:
  $(basename "$0")              # status
  $(basename "$0") enable       # legacy on + medium
  $(basename "$0") level 1      # light strength (thinner than medium)
  $(basename "$0") level 0      # off
  $(basename "$0") disable      # restore macOS default

Note: These are system-wide defaults (not Terminal-only). After changing,
quit/reopen the app or log out and back in.
HELP
}

# Main
cmd="${1:-}"
case "$cmd" in
    ""|status|show)
        show_state
        ;;
    enable|on|--enable|-e)
        enable_legacy
        ;;
    disable|off|--disable|-d)
        disable_legacy
        ;;
    level|--level|-l)
        if [[ $# -eq 1 ]]; then
            level=$(get_level)
            if [[ -n "$level" ]]; then
                echo "AppleFontSmoothing = $level ($(level_label "$level"))"
            else
                echo "AppleFontSmoothing = (not set)"
            fi
        else
            set_level "$2"
        fi
        ;;
    help|-h|--help)
        usage
        ;;
    *)
        # Allow: font-smoothing 1  →  shorthand for level 1
        if [[ "$cmd" =~ ^[0-3]$ ]]; then
            set_level "$cmd"
        else
            echo -e "${RED}Unknown command: $cmd${NC}"
            echo
            usage
            exit 1
        fi
        ;;
esac
