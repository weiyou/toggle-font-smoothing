#!/bin/bash

# toggle-font-smoothing.sh
# Toggle legacy LCD / subpixel font smoothing on macOS
# (the setting that makes text look better on non-Retina displays like the Apple Thunderbolt Display)

set -euo pipefail

KEY="CGFontRenderingFontSmoothingDisabled"
SMOOTH_KEY="AppleFontSmoothing"

# Colors for nicer output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

get_disabled_value() {
    if defaults read -g "$KEY" &>/dev/null; then
        defaults read -g "$KEY"
    else
        # Key not set → macOS default after Mojave is disabled (true)
        echo "1"
    fi
}

is_enabled() {
    local val
    val=$(get_disabled_value)
    # 0 / NO / false → enabled
    if [[ "$val" == "0" || "$val" == "NO" || "$val" == "false" || "$val" == "False" ]]; then
        return 0
    else
        return 1
    fi
}

show_state() {
    echo -e "${BLUE}Legacy LCD / Subpixel Font Smoothing${NC}"
    echo "-------------------------------------"

    if is_enabled; then
        echo -e "Status: ${GREEN}ENABLED${NC}"
    else
        echo -e "Status: ${RED}DISABLED${NC} (macOS default)"
    fi

    echo
    echo "Details:"
    if defaults read -g "$KEY" &>/dev/null; then
        echo "  CGFontRenderingFontSmoothingDisabled = $(defaults read -g "$KEY")"
    else
        echo "  CGFontRenderingFontSmoothingDisabled = (not set → disabled by default)"
    fi

    if defaults -currentHost read -g "$SMOOTH_KEY" &>/dev/null; then
        local level
        level=$(defaults -currentHost read -g "$SMOOTH_KEY")
        case "$level" in
            0) echo "  AppleFontSmoothing = 0 (off)" ;;
            1) echo "  AppleFontSmoothing = 1 (light)" ;;
            2) echo "  AppleFontSmoothing = 2 (medium)" ;;
            3) echo "  AppleFontSmoothing = 3 (strong)" ;;
            *) echo "  AppleFontSmoothing = $level" ;;
        esac
    else
        echo "  AppleFontSmoothing = (not set)"
    fi

    echo
    echo -e "${YELLOW}Note:${NC} Changes require logout/login or restart to fully take effect."
}

enable_smoothing() {
    defaults write -g "$KEY" -bool NO
    # Set a sensible default strength (medium) for non-Retina displays
    defaults -currentHost write -g "$SMOOTH_KEY" -int 2

    echo -e "${GREEN}✓ Enabled${NC} legacy LCD / subpixel font smoothing."
    echo "  (AppleFontSmoothing set to 2 = medium)"
    echo
    echo -e "${YELLOW}→ Please log out and log back in (or restart) for the change to apply.${NC}"
    echo
    show_state
}

disable_smoothing() {
    defaults write -g "$KEY" -bool YES
    # Clean up the strength setting
    defaults -currentHost delete -g "$SMOOTH_KEY" 2>/dev/null || true

    echo -e "${RED}✓ Disabled${NC} legacy LCD / subpixel font smoothing."
    echo "  (restored macOS default behavior)"
    echo
    echo -e "${YELLOW}→ Please log out and log back in (or restart) for the change to apply.${NC}"
    echo
    show_state
}

usage() {
    cat <<HELP
Usage: $(basename "$0") [OPTION]

Toggle legacy LCD/subpixel font smoothing (useful for Apple Thunderbolt Display
and other non-Retina monitors when a Retina display is also present).

Options:
  --enable,  -e     Enable legacy LCD font smoothing
  --disable, -d     Disable it (restore default)
  (no argument)     Show current state
  --help,    -h     Show this help

Examples:
  $(basename "$0")              # show status
  $(basename "$0") --enable     # turn on
  $(basename "$0") --disable    # turn off
HELP
}

# Main
case "${1:-}" in
    --enable|-e)
        enable_smoothing
        ;;
    --disable|-d)
        disable_smoothing
        ;;
    --help|-h)
        usage
        ;;
    "")
        show_state
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo
        usage
        exit 1
        ;;
esac
