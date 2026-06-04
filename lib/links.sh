# links.sh — run dotfiles/install.sh from internal path
# Requires: core.sh

link_dotfiles() {
  step "Enlazando dotfiles"
  local dotfiles
  dotfiles="${SETUP_DIR}/dotfiles"
  [ -f "$dotfiles/install.sh" ] || die "dotfiles/install.sh no encontrado en $dotfiles"
  run bash "$dotfiles/install.sh"
}
