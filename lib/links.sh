# shellcheck shell=bash
# links.sh -- copy the canonical dotfiles from the repo into $HOME.
# Requires: core.sh (ok/info/err/step/warn/die), detect.sh ($PLATFORM).

# _link <relpath> -- atomic copy of dotfiles/<relpath> to $HOME/<relpath>.
# Stages into a temp dir next to the destination, then moves over the old
# one. Never rm before the new copy exists: an OOM-kill mid-rm (Android
# killing Termux) must never leave the destination missing.
_link() {
  local rel="$1"
  local src="$SETUP_DIR/dotfiles/$rel"
  local dst="$HOME/$rel"
  local dstdir tmp
  [ -e "$src" ] || { err "missing source: dotfiles/$rel"; return 1; }
  dstdir="$(dirname "$dst")"
  mkdir -p "$dstdir"
  tmp="$(mktemp -d "$dstdir/.link-tmp.XXXXXX")"
  if cp -RfL "$src" "$tmp/$rel" 2>/dev/null || cp -RfL "$src" "$tmp/"; then
    rm -rf "$dst"
    if [ -e "$tmp/$rel" ]; then
      mv -f "$tmp/$rel" "$dst"
    else
      mv -f "$tmp/$(basename "$rel")" "$dst"
    fi
    ok "$rel"
  else
    err "failed: $rel"
  fi
  rm -rf "$tmp" 2>/dev/null || true
}

# link_dotfiles -- walk every dotfile the current platform needs and copy
# it into $HOME. Idempotent: re-running converges to the current tree.
# Called from install.sh after init_platform so $PLATFORM is set.
link_dotfiles() {
  step "Copying dotfiles to \$HOME"

  # Shared, every platform.
  _link .zshenv
  _link .zshrc
  _link .zprofile
  _link .gitconfig
  _link .vimrc
  _link .prettierrc
  mkdir -p "$HOME/.addons-zsh"
  _link .addons-zsh/aliass

  # Config subdir present everywhere.
  _link .config/ranger

  # Ifconfig shim: on Termux without root, toybox ifconfig cannot read
  # /proc/net/dev and prints a warning on every call. Byobu pre-computes
  # the ip_address module even when the bar does not show it, so the
  # warning fires at every session start. The shim lives in
  # ~/.local/bin/ifconfig (prepended to PATH by .zshrc) and, when
  # /proc/net/dev is unreadable, exits without invoking toybox. When it
  # is readable, execs the real ifconfig unchanged.
  _link .local/bin/ifconfig
  chmod +x "$HOME/.local/bin/ifconfig"

  # Suppress the login motd. Termux prints /data/data/com.termux/files/usr/etc/motd
  # on every login shell; byobu clears the screen when it paints its layout
  # and that motd is lost anyway. Instead, .zshrc shows the motd once per
  # tmux session (see "motd on first shell of a tmux session"). ~/.hushlogin
  # is the standard UNIX convention for "do not print the motd".
  touch "$HOME/.hushlogin"
  ok ".hushlogin"

  # byobu: config travels with the autostart block in .zshrc. Skipped
  # when byobu is not installed on this host.
  if command -v byobu >/dev/null 2>&1; then
    _link .config/byobu
  fi

  # Platform-specific.
  case "$PLATFORM" in
    termux)
      _link .termux
      _link .config/mpd
      _link .config/ncmpcpp
      _link .config/starship.toml
      ;;
    debian)
      _link .xinitrc
      _link .config/alacritty
      _link .config/deadd
      _link .config/i3
      _link .config/i3status
      ;;
    macos)
      _link .config/alacritty
      ;;
  esac

  ok "dotfiles installed ($PLATFORM)"
}
