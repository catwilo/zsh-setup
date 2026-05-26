# plugins.sh — clone zsh plugins from upstream GitHub
# Requires: core.sh
# Plugins are NOT committed — install only via this script

PLUGINS_DIR="$HOME/.addons-zsh"

# ── Clone single plugin (idempotent) ─────────────────────────────────────────
_clone_plugin() {
  local name="$1" url="$2"
  local dest="$PLUGINS_DIR/$name"
  if [ -d "$dest" ]; then
    ok "ya existe: $name"
    return 0
  fi
  info "clonando: $name"
  if run git clone --depth 1 "$url" "$dest"; then
    ok "instalado: $name"
  else
    err "falló: $name"
    return 1
  fi
}

# ── Install all plugins ──────────────────────────────────────────────────────
install_plugins() {
  step "Instalando plugins zsh"
  require_cmd git
  mkdir -p "$PLUGINS_DIR"
  local failed=0
  _clone_plugin fzf                      "https://github.com/junegunn/fzf"                               || failed=$((failed+1))
  _clone_plugin fzf-tab                  "https://github.com/Aloxaf/fzf-tab"                             || failed=$((failed+1))
  _clone_plugin zsh-autosuggestions      "https://github.com/zsh-users/zsh-autosuggestions"              || failed=$((failed+1))
  _clone_plugin fast-syntax-highlighting "https://github.com/zdharma-continuum/fast-syntax-highlighting" || failed=$((failed+1))
  [ "$failed" -gt 0 ] && die "$failed plugin(s) fallaron al instalar"
  ok "Todos los plugins listos en $PLUGINS_DIR"
}

# ── Verify plugins exist ─────────────────────────────────────────────────────
verify_plugins() {
  step "Verificando plugins"
  local missing=0
  for name in fzf fzf-tab zsh-autosuggestions fast-syntax-highlighting; do
    if [ -d "$PLUGINS_DIR/$name" ]; then
      ok "plugin: $name"
    else
      err "plugin faltante: $name"
      missing=$((missing+1))
    fi
  done
  [ "$missing" -gt 0 ] && die "$missing plugin(s) faltantes en $PLUGINS_DIR"
}
