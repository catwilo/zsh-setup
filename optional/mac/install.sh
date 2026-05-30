# mac.sh — macOS bootstrap: Nix + deps + PATH + clipboard recovery.
# Absorbed from former setup-mac repo. Requires: core.sh (log helpers).
# Guarded: macOS-only; no-op elsewhere.

setup_mac() {
  if [ "$(uname)" != "Darwin" ]; then
    warn "setup_mac: not macOS — skipping"
    return 0
  fi
  _MAC_HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
  # shellcheck disable=SC1091
  . "$_MAC_HERE/versions.env"
  # shellcheck disable=SC1091
  . "$_MAC_HERE/lib/nix.sh"
  # shellcheck disable=SC1091
  . "$_MAC_HERE/lib/deps.sh"
  # shellcheck disable=SC1091
  . "$_MAC_HERE/lib/path.sh"

  step "1/4  Detect Nix state"
  _state="$(classify_nix_state)"
  info "Nix state: $_state"
  if [ "$_state" = "broken" ]; then
    err "Nix broken. Run: optional/mac/repair-nix.sh  then reboot, then re-run."
    return 1
  fi
  step "2/4  Ensure Nix"
  ensure_nix || return 1
  step "3/4  Ensure packages (${NIX_PACKAGES[*]})"
  ensure_packages
  step "4/4  Wire PATH for non-interactive shells"
  ensure_path_zshenv
  ok "setup_mac complete — open a new SSH session to pick up PATH"
}

# fix_clipboard — recover a hung macOS pasteboard after a stuck clipboard
# listener (nc | pbcopy) wedges copy/paste. Safe to run anytime on macOS.
fix_clipboard() {
  [ "$(uname)" = "Darwin" ] || { warn "fix_clipboard: macOS-only"; return 0; }
  launchctl bootout "gui/$(id -u)/io.clipd.agent" 2>/dev/null || true
  pkill -9 -f "nc -lU" 2>/dev/null || true
  pkill -9 pbcopy 2>/dev/null || true
  killall pboard 2>/dev/null || true
  ok "pasteboard reset (pboard restarted, stray listeners killed)"
}
