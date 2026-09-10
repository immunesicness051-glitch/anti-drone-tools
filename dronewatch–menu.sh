#!/usr/bin/env bash
#
# dronewatch-menu.sh
# Zenity-based launcher menu for the passive RF/drone-detection toolkit.
# Every action here is receive/detect only — nothing in this menu transmits,
# injects, deauths, or jams.
#
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v zenity >/dev/null 2>&1; then
    echo "zenity not found — run install.sh first." >&2
    exit 1
fi

pick_wifi_iface() {
    iw dev 2>/dev/null | awk '$1=="Interface"{print $2}' | \
        zenity --list --title "Select WiFi adapter" --column "Interface" --height=250 --width=350
}
