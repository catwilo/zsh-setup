# shellcheck shell=sh
# plugins.sh — install zsh plugins from dotconfig bundle or upstream fallback
# Requires: core.sh, detect.sh (PLATFORM set via init_platform)
#
# Strategy (in order):
#   1. Copy from zsh-setup/dotfiles/.addons-zsh/<name>  (curated bundle, no network)
#   2. git clone upstream                       (fallback if bundle missing)
#
# aliass/ is a dotfile — linked by dotfiles/install.sh, NOT handled here.

PLUGINS_DIR="$HOME/.addons-zsh"
PLUGINS_LIST="fzf fzf-tab zsh-autosuggestions fast-syntax-highlighting"

_plugin_upstream() {
  case "$1" in
    fzf)                      echo "https://github.com/junegunn/fzf" ;;
    fzf-tab)                  echo "https://github.com/Aloxaf/fzf-tab" ;;
    zsh-autosuggestions)      echo "https://github.com/zsh-users/zsh-autosuggestions" ;;
    fast-syntax-highlighting) echo "https://github.com/zdharma-continuum/fast-syntax-highlighting" ;;
    *) echo "" ;;
  esac
}

_find_bundle() {
  local b="$HOME/unix-toolkit-tools/zsh-setup/dotfiles"
  [ -d "$b/.addons-zsh" ] && { echo "$b"; return; }
  echo ""
}

_install_plugin() {
  local name="$1" dotconfig="$2"
  local dest="$PLUGINS_DIR/$name"
  if [ -d "$dest" ]; then
    ok "ya existe: $name"
    return 0
  fi
  if [ -n "$dotconfig" ] && [ -d "$dotconfig/.addons-zsh/$name" ]; then
    info "copiando desde bundle: $name"
    run cp -r "$dotconfig/.addons-zsh/$name" "$dest" && ok "instalado: $name" && return 0
    err "falló copia: $name"
  fi
  local url
  url="$(_plugin_upstream "$name")"
  [ -z "$url" ] && { err "sin upstream para: $name"; return 1; }
  info "clonando upstream: $name"
  run git clone --depth 1 "$url" "$dest" && ok "instalado: $name" && return 0
  err "falló clone: $name"
  return 1
}

install_plugins() {
  step "Instalando plugins zsh"
  mkdir -p "$PLUGINS_DIR"
  local dotconfig failed=0
  dotconfig="$(_find_bundle)"
  [ -n "$dotconfig" ] && info "bundle: $dotconfig/.addons-zsh" || warn "bundle no encontrado — usando upstream"
  for name in $PLUGINS_LIST; do
    _install_plugin "$name" "$dotconfig" || failed=$((failed+1))
  done
  [ "$failed" -gt 0 ] && die "$failed plugin(s) fallaron"
  ok "Todos los plugins listos en $PLUGINS_DIR"
}

verify_plugins() {
  step "Verificando plugins"
  local missing=0
  for name in $PLUGINS_LIST; do
    if [ -d "$PLUGINS_DIR/$name" ]; then
      ok "plugin: $name"
    else
      err "faltante: $name"
      missing=$((missing+1))
    fi
  done
  [ "$missing" -gt 0 ] && die "$missing plugin(s) faltantes en $PLUGINS_DIR"
  return 0
}
