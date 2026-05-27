# links.sh — run dotfiles/install.sh from internal path
# Requires: core.sh

link_dotfiles() {
  step "Enlazando dotfiles"
  local dotfiles
  dotfiles="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/dotfiles"
  [ -f "$dotfiles/install.sh" ] || die "dotfiles/install.sh no encontrado en $dotfiles"
  run bash "$dotfiles/install.sh"
}
