# pkg.sh — unified package install abstraction
# shellcheck shell=sh
# Requires: core.sh, detect.sh (PKGMGR set via init_platform)

# ── Internal dispatchers ──────────────────────────────────────────────────────
_pkg_termux() { run pkg install -y "$@"; }
_pkg_debian() {
  # Deploy never blocks on root: if passwordless sudo is unavailable, warn and skip.
  if sudo -n true 2>/dev/null; then
    run sudo apt-get install -y "$@"
  else
    warn "sudo sin password no disponible — omitiendo apt (manual: sudo apt-get install -y $*)"
  fi
}
# _pkg_macos()  { run nix-env -iA nixpkgs."$@"; }  # stub: macos/nix

# ── Public interface ──────────────────────────────────────────────────────────
pkg_install() {
  [ $# -eq 0 ] && return 0
  case "${PKGMGR:?PKGMGR not set — run init_platform first}" in
    pkg) _pkg_termux "$@" ;;
    apt) _pkg_debian "$@" ;;
    # nix) _pkg_macos "$@" ;;
    *)   die "Gestor de paquetes no soportado: $PKGMGR" ;;
  esac
}

# ── Install from .env list ────────────────────────────────────────────────────
# Format: one package per line, # comments allowed
pkg_install_file() {
  require_file "$1"
  local pkgs
  pkgs="$(grep -v '^\s*#' "$1" | grep -v '^\s*$' | tr '\n' ' ')"
  [ -z "$pkgs" ] && { warn "Lista vacía: $1"; return 0; }
  # shellcheck disable=SC2086
  pkg_install $pkgs
}
