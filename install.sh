#!/usr/bin/env bash
#
# dronewatch installer
# ---------------------
# Installs a PASSIVE-ONLY radio/drone situational-awareness toolkit:
#   - Kismet          (RF/WiFi spectrum + device detection, monitor mode only)
#   - GQRX            (SDR receive/spectrum viewer)
#   - GNU Radio Companion (receive-only flowgraphs: FFT, waterfall, FHSS trace)
#   - dump1090-fa / readsb (ADS-B receive, for manned aircraft context)
#   - a Remote ID decoder (drone Remote ID broadcasts, receive-only)
#   - tshark/wireshark (packet capture/analysis, receive only — no injection use)
#   - SDR drivers (libhackrf, rtl-sdr, uhd host) — receive-side use only
#
# This script deliberately does NOT install or configure anything with
# transmit/injection/jamming capability (no aircrack-ng injection modes,
# no mdk3, no rogue-AP tooling, no SDR transmit chains). See README.md.
#
# Usage:
#   chmod +x install.sh
#   ./install.sh            # install everything
#   ./install.sh --gui      # install, then launch the tool menu
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/install.log"

# ---------- helpers ----------------------------------------------------

log() { echo -e "$1" | tee -a "$LOG_FILE"; }

need_root_pkg_mgr() {
    if [ "$(id -u)" -ne 0 ]; then
        log "This script needs sudo to install system packages."
        exec sudo -E bash "$0" "$@"
    fi
}

detect_pkg_mgr() {
    if command -v apt-get >/dev/null 2>&1; then echo "apt"
    elif command -v pacman >/dev/null 2>&1; then echo "pacman"
    elif command -v dnf >/dev/null 2>&1; then echo "dnf"
    else echo "unknown"
    fi
}

# ---------- package lists (receive-only stack) --------------------------

APT_PKGS=(
    kismet
    gqrx-sdr
    gnuradio
    gnuradio-dev
    gr-osmosdr
    rtl-sdr
    librtlsdr-dev
    hackrf
    libhackrf-dev
    uhd-host
    tshark
    wireshark
    zenity
    yad
    python3-pip
    python3-venv
    git
)

PACMAN_PKGS=(
    kismet
    gqrx
    gnuradio
    gnuradio-companion
    gr-osmosdr
    rtl-sdr
    hackrf
    uhd
    tshark
    wireshark-qt
    zenity
    yad
    python-pip
    git
)

DNF_PKGS=(
    kismet
    gqrx
    gnuradio
    gr-osmosdr
    rtl-sdr-devel
    hackrf-devel
    uhd
    wireshark-cli
    wireshark
    zenity
    yad
    python3-pip
    git
)

# ---------- install steps ------------------------------------------------

install_system_packages() {
    local mgr="$1"
    log "\n== Installing system packages via $mgr =="
    case "$mgr" in
        apt)
            apt-get update
            DEBIAN_FRONTEND=noninteractive apt-get install -y "${APT_PKGS[@]}"
            ;;
        pacman)
            pacman -Sy --noconfirm --needed "${PACMAN_PKGS[@]}"
            ;;
        dnf)
            dnf install -y "${DNF_PKGS[@]}"
            ;;
        *)
            log "Unsupported package manager. Install manually: kismet, gqrx, gnuradio, gr-osmosdr, rtl-sdr, hackrf, uhd, tshark/wireshark, zenity, yad."
            ;;
    esac
}

configure_kismet_receive_only() {
    log "\n== Configuring Kismet (detection-only, no packet injection) =="
    mkdir -p /etc/kismet
    if [ ! -f /etc/kismet/kismet_site.conf ]; then
        cat > /etc/kismet/kismet_site.conf <<'EOF'
# dronewatch site config — receive/detect only.
# Do not enable injection-capable sources or deauth-related plugins here.
EOF
    fi
    # add current invoking user to kismet group for capture perms
    if [ -n "${SUDO_USER:-}" ]; then
        usermod -aG kismet "$SUDO_USER" || true
    fi
}

setup_remoteid_decoder() {
    log "\n== Setting up drone Remote ID decoder (receive-only) =="
    local target_dir="$SCRIPT_DIR/tools/remoteid"
    mkdir -p "$target_dir"
    if [ ! -d "$target_dir/.git" ]; then
        git clone --depth 1 https://github.com/opendroneid/receiver-linux.git "$target_dir" \
            || log "  (clone failed — check network access, or install manually later)"
    fi
}

setup_python_env() {
    log "\n== Setting up Python venv for map/dashboard helper =="
    python3 -m venv "$SCRIPT_DIR/venv"
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/venv/bin/activate"
    pip install --upgrade pip
    pip install folium flask requests
    deactivate
}

# ---------- main -----------------------------------------------------

main() {
    : > "$LOG_FILE"
    log "dronewatch installer starting..."
    need_root_pkg_mgr "$@"

    local mgr
    mgr="$(detect_pkg_mgr)"
    install_system_packages "$mgr"
    configure_kismet_receive_only
    setup_remoteid_decoder
    setup_python_env

    chmod +x "$SCRIPT_DIR/dronewatch-menu.sh"
    chmod +x "$SCRIPT_DIR"/tools/*.sh 2>/dev/null || true

    log "\n== Install complete =="
    log "Run the tool menu any time with: $SCRIPT_DIR/dronewatch-menu.sh"

    for arg in "$@"; do
        if [ "$arg" = "--gui" ]; then
            log "Launching GUI menu..."
            exec "$SCRIPT_DIR/dronewatch-menu.sh"
        fi
    done
}

main "$@"
