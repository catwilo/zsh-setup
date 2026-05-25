# links.sh — symlink dotfiles from repo to $HOME
# Requires: core.sh, detect.sh (init_platform called before link_dotfiles)

# ── Resolve source repo ──────────────────────────────────────────────────────
_find_toolkit() {
  for candidate in "$HOME/unix-toolkit" "$HOME/unix-toolkit-tools"; do
    [ -d "$candidate/dotconfig" ] && { echo "$candidate"; return; }
  done
  die "No se encontro unix-toolkit en $HOME"
}

_dotfiles_src() {
  local base
  base="$(_find_toolkit)"
  case "${PLATFORM:-$(detect_platform)}" in
    termux) echo "$base/dotconfigtermux" ;;
    *)      echo "$base/dotconfig"       ;;
  esac
}

# ── Single symlink ───────────────────────────────────────────────────────────
link_file() {
  local rel="$1"
  local src
  src="$(_dotfiles_src)/$rel"
  local dst="$HOME/$rel"
  [ -e "$src" ] || { warn "no existe en repo: $rel"; return 0; }
  run mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    run rm "$dst"
  elif [ -e "$dst" ]; then
    run mv "$dst" "${dst}.bak"
    warn "backup: ${dst}.bak"
  fi
  run ln -s "$src" "$dst"
  ok "$dst -> $src"
}

# ── All dotfiles ─────────────────────────────────────────────────────────────
link_dotfiles() {
  step "Enlazando dotfiles"
  link_file ".zshrc"
  link_file ".zprofile"
  link_file ".addons-zsh/aliass"
  link_file ".config/starship.toml"
  link_file ".config/byobu"
  link_file ".config/nvim"
  link_file ".config/ranger"
  link_file ".config/mpd"
  link_file ".config/ncmpcpp"
  link_file ".termux/colors.properties"
  link_file ".termux/font.ttf"
  link_file ".termux/termux.properties"
}
