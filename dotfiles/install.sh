#!/usr/bin/env bash
# dotconfig install.sh — symlink dotfiles to $HOME based on platform
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

G='[32m'; R='[31m'; C='[36m'; Z='[0m'
ok()   { printf "${G}  ✔  %s${Z}\n" "$1"; }
info() { printf "${C}  →  %s${Z}\n" "$1"; }
err()  { printf "${R}  ✗  %s${Z}\n" "$1" >&2; }

link() {
  local src="$HERE/$1" dst="$HOME/$1"
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst" && ok "$1" || err "failed: $1"
}

# ── platform detection ────────────────────────────────────────────────────────
if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; then
  PLATFORM="termux"
elif [ "$(uname)" = "Darwin" ]; then
  PLATFORM="macos"
elif [ -f "/etc/debian_version" ]; then
  PLATFORM="debian"
else
  PLATFORM="unknown"
fi
info "platform: $PLATFORM"

# ── shared ────────────────────────────────────────────────────────────────────
link .zshenv
link .zshrc
link .zprofile
link .gitconfig
link .vimrc
link .prettierrc
mkdir -p "$HOME/.addons-zsh"
ln -sf "$HERE/.addons-zsh/aliass" "$HOME/.addons-zsh/aliass" && ok ".addons-zsh/aliass"

# ── config subdirs ────────────────────────────────────────────────────────────
for d in ranger; do
  link ".config/$d"
done

# ── platform-specific ─────────────────────────────────────────────────────────
case "$PLATFORM" in
  termux)
    link .termux
    link .config/byobu
    link .config/mpd
    link .config/ncmpcpp
    link .config/starship.toml
    ;;
  debian)
    link .xinitrc
    link .config/alacritty
    link .config/deadd
    link .config/i3
    link .config/i3status
    ;;
  macos)
    link .config/alacritty
    ;;
esac

ok "dotconfig installed ($PLATFORM)"
