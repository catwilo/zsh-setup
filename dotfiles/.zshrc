# .zshrc — unified config (Termux, Debian, RPi, macOS)

# ── History ───────────────────────────────────────────────────────────────────
export HISTFILE=~/.histfile
HIST_MAX=500
HISTSIZE=$HIST_MAX
SAVEHIST=$HIST_MAX
setopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS
unsetopt SHARE_HISTORY INC_APPEND_HISTORY EXTENDED_HISTORY
setopt beep extendedglob nomatch notify

# ── Path ──────────────────────────────────────────────────────────────────────
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH";; esac

# ── Platform detection ────────────────────────────────────────────────────────
if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; then
  _PLATFORM="termux"
elif [ "$(uname)" = "Darwin" ]; then
  _PLATFORM="macos"
elif [ -f "/etc/debian_version" ]; then
  _PLATFORM="debian"
else
  _PLATFORM="unknown"
fi

# ── Prompt ────────────────────────────────────────────────────────────────────
eval "$(starship init zsh)"

# ── Completion + vi mode ──────────────────────────────────────────────────────
autoload -Uz compinit && compinit
bindkey -v

# ── Plugins ───────────────────────────────────────────────────────────────────
_addon="$HOME/.addons-zsh"
[ -f "$_addon/fzf/shell/key-bindings.zsh" ]                    && source "$_addon/fzf/shell/key-bindings.zsh"
[ -f "$_addon/fzf-tab/fzf-tab.plugin.zsh" ]                    && source "$_addon/fzf-tab/fzf-tab.plugin.zsh"
[ -f "$_addon/zsh-autosuggestions/zsh-autosuggestions.zsh" ]   && source "$_addon/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$_addon/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ] \
                                                                && source "$_addon/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

# ── Aliases + bindkeys + functions ───────────────────────────────────────────
_al="$_addon/aliass"
[ -f "$_al/shared.zsh"   ] && source "$_al/shared.zsh"
[ -f "$_al/bindkeys.zsh" ] && source "$_al/bindkeys.zsh"
[ -f "$_al/functions.zsh" ] && source "$_al/functions.zsh"

case "$_PLATFORM" in
  termux) [ -f "$_al/termux.zsh" ] && source "$_al/termux.zsh" ;;
  debian) [ -f "$_al/debian.zsh" ] && source "$_al/debian.zsh" ;;
  macos)  [ -f "$_al/macos.zsh"  ] && source "$_al/macos.zsh"  ;;
esac

# Desktop X11 (Linux with DISPLAY available)
[ "$_PLATFORM" = "debian" ] && [ -n "${DISPLAY:-}" ] && [ -f "$_al/pc.zsh" ] && source "$_al/pc.zsh"
# >>> clipso >>>
case ":$PATH:" in *":/data/data/com.termux/files/usr/bin:"*) ;; *) export PATH="/data/data/com.termux/files/usr/bin:$PATH";; esac
# <<< clipso <<<
# >>> noemap >>>
case ":$PATH:" in *":/data/data/com.termux/files/usr/bin:"*) ;; *) export PATH="/data/data/com.termux/files/usr/bin:$PATH";; esac
[ -n "$LC_NCSSH" ] && source "/data/data/com.termux/files/home/unix-toolkit-tools/noemap/lib/capture.zsh"
# <<< noemap <<<
