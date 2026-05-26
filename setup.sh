#!/bin/sh
# setup.sh — zsh environment setup entrypoint
# Usage: sh setup.sh [--mpd] [--mac] [--dry-run]

set -e

SETUP_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Parse flags ──────────────────────────────────────────────────────────────
SETUP_MPD=0
SETUP_MAC=0
for _arg in "$@"; do
  case "$_arg" in
    --mpd)     SETUP_MPD=1 ;;
    --mac)     SETUP_MAC=1 ;;
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

# ── Shell default ────────────────────────────────────────────────────────────
_set_default_shell() {
  step "Shell por defecto"
  local zsh_bin
  zsh_bin="$(command -v zsh)"
  if [ "$SHELL" = "$zsh_bin" ]; then
    ok "zsh ya es el shell activo"
    return 0
  fi
  case "$PLATFORM" in
    termux) run chsh -s zsh ;;
    debian) run chsh -s "$zsh_bin" ;;
    macos)  info "macOS: cambia shell con chsh manualmente si es necesario" ;;
  esac
  ok "Shell cambiado a zsh — reinicia la terminal"
}

# ── Main ─────────────────────────────────────────────────────────────────────
init_platform

pkg_install_file "$SETUP_DIR/packages/$PLATFORM.env"

install_plugins

link_dotfiles

_set_default_shell

verify_plugins

if [ "$SETUP_MPD" = "1" ]; then
  . "$SETUP_DIR/optional/mpd/install.sh"
  setup_mpd
fi

# macOS bootstrap — sourced only under Darwin so POSIX sh never parses the
# bash-array syntax inside optional/mac/install.sh.
if [ "$SETUP_MAC" = "1" ] || [ "$(uname)" = "Darwin" ]; then
  if [ "$(uname)" = "Darwin" ]; then
    . "$SETUP_DIR/optional/mac/install.sh"
    setup_mac
  else
    warn "--mac ignored: not macOS"
  fi
fi

step "Setup completo"
ok "Plataforma: $PLATFORM"
