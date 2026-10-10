# shellcheck shell=bash
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
#
# Only the packages that are actually missing are handed to the package
# manager. That makes the install idempotent at the package-manager
# boundary: a second run touches nothing, and a temporary failure of the
# upstream mirror (rate limit, maintenance) cannot break a node whose
# packages are already installed.
#
# dpkg -s is the universal query: Termux ships dpkg too, so the same test
# works on both platforms without a per-PMGMR branch.
_pkg_missing() {
  local _pm_pkg
  for _pm_pkg in "$@"; do
    dpkg -s "$_pm_pkg" >/dev/null 2>&1 || printf '%s\n' "$_pm_pkg"
  done
}

pkg_install_file() {
  require_file "$1"
  local pkgs
  pkgs="$(grep -v '^\s*#' "$1" | grep -v '^\s*$' | tr '\n' ' ')"
  [ -z "$pkgs" ] && { warn "Lista vacía: $1"; return 0; }
  # shellcheck disable=SC2086
  local missing
  missing="$(_pkg_missing $pkgs | tr '\n' ' ')"
  if [ -z "$missing" ]; then
    ok "Paquetes ya instalados: $(printf '%s' "$pkgs" | wc -w)"
    return 0
  fi
  warn "Paquetes a instalar: $missing"
  # shellcheck disable=SC2086
  pkg_install $missing
}
