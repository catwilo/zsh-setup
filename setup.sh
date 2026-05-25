#!/bin/sh
# setup.sh — zsh environment setup entrypoint
# Usage: sh setup.sh [--mpd] [--dry-run]

set -e

SETUP_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Parse flags ──────────────────────────────────────────────────────────────
SETUP_MPD=0
for _arg in "$@"; do
  case "$_arg" in
    --mpd)     SETUP_MPD=1 ;;
    --dry-run) DRY_RUN=1   ;;
  esac
done
export DRY_RUN="${DRY_RUN:-0}"

# ── Source libs ──────────────────────────────────────────────────────────────
. "$SETUP_DIR/lib/core.sh"
. "$SETUP_DIR/lib/detect.sh"
. "$SETUP_DIR/lib/pkg.sh"
. "$SETUP_DIR/lib/plugins.sh"
. "$SETUP_DIR/lib/links.sh"

# ── Main ─────────────────────────────────────────────────────────────────────
init_platform

pkg_install_file "$SETUP_DIR/packages/$PLATFORM.env"

install_plugins

link_dotfiles

verify_plugins

if [ "$SETUP_MPD" = "1" ]; then
  . "$SETUP_DIR/optional/mpd/install.sh"
  setup_mpd
fi

step "Setup completo"
ok "Plataforma: $PLATFORM"
