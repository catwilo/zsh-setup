# links.sh — delegate dotfile linking to dotconfig/install.sh
# Requires: core.sh

_find_dotconfig() {
  for candidate in "$HOME/unix-toolkit-tools/dotconfig" "$HOME/unix-toolkit/dotconfig"; do
    [ -f "$candidate/install.sh" ] && { echo "$candidate"; return; }
  done
  die "dotconfig no encontrado — clona el repo primero"
}

link_dotfiles() {
  step "Enlazando dotfiles"
  local dotconfig
  dotconfig="$(_find_dotconfig)"
  run bash "$dotconfig/install.sh"
}
