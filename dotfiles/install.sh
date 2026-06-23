#!/usr/bin/env bash
# dotconfig install.sh — COPY dotfiles to $HOME (independent of repo) based on platform
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

G='[32m'; R='[31m'; C='[36m'; Z='[0m'
ok()   { printf "${G}  ✔  %s${Z}\n" "$1"; }
info() { printf "${C}  →  %s${Z}\n" "$1"; }
err()  { printf "${R}  ✗  %s${Z}\n" "$1" >&2; }

link() {
  # Atomic copy: stage into a temp path next to dst, then mv over the old
  # one. Never rm dst before the new copy exists -- a process kill mid-rm
  # (e.g. Android OOM-killing Termux) must never leave dst missing.
  local src="$HERE/$1" dst="$HOME/$1"
  local dstdir tmp
  dstdir="$(dirname "$dst")"
  mkdir -p "$dstdir"
  tmp="$(mktemp -d "$dstdir/.link-tmp.XXXXXX")/$1"
  mkdir -p "$(dirname "$tmp")"
  if cp -RfL "$src" "$tmp"; then
    rm -rf "$dst"
    mv -f "$tmp" "$dst" && ok "$1" || err "failed: $1"
  else
    err "failed: $1"
  fi
  rm -rf "$(dirname "$tmp")" 2>/dev/null || true
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
link .addons-zsh/aliass

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
