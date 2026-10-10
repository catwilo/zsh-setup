# .zshrc — unified config (Termux, Debian, RPi, macOS)

# ── History ───────────────────────────────────────────────────────────────────
mkdir -p ~/.local/state/zsh
export HISTFILE=~/.local/state/zsh/histfile
HIST_MAX=2000
HISTSIZE=$HIST_MAX
SAVEHIST=$HIST_MAX
setopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS
HISTORY_IGNORE="clipso run /*|clipso write *|clipso paste"
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
# drain any pending terminal query responses (e.g. OSC11 background-color
# replies) before starship's precmd hook redraws the prompt, so stray
# escape bytes don't get echoed as literal text.
while read -r -t 0.05 -k 1 _drain 2>/dev/null; do :; done
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
[ -f "$_al/clipso.zsh" ] && source "$_al/clipso.zsh"

case "$_PLATFORM" in
  termux) [ -f "$_al/termux.zsh" ] && source "$_al/termux.zsh" ;;
  debian) [ -f "$_al/debian.zsh" ] && source "$_al/debian.zsh" ;;
  macos)  [ -f "$_al/macos.zsh"  ] && source "$_al/macos.zsh"  ;;
esac

# Desktop X11 (Linux with DISPLAY available)
[ "$_PLATFORM" = "debian" ] && [ -n "${DISPLAY:-}" ] && [ -f "$_al/pc.zsh" ] && source "$_al/pc.zsh"
# >>> noemap >>>
case ":$PATH:" in *":/data/data/com.termux/files/usr/bin:"*) ;; *) export PATH="/data/data/com.termux/files/usr/bin:$PATH";; esac
[ -n "$LC_NCSSH" ] && source "/data/data/com.termux/files/home/unix-toolkit-tools/noemap/lib/capture.zsh"
# <<< noemap <<<
setopt interactivecomments
# >>> clipso >>>
case ":$PATH:" in *":/data/data/com.termux/files/usr/bin:"*) ;; *) export PATH="/data/data/com.termux/files/usr/bin:$PATH";; esac
# <<< clipso <<<
# >>> clipso-keybinding >>>
_wrap_clipso() {
  [[ -z $BUFFER ]] && return
  local _c=$BUFFER
  local _tmp
  _tmp=$(mktemp "${TMPDIR:-/tmp}/clipso-cmd.XXXXXX")
  printf "#!/usr/bin/env bash\n%s\n" "$_c" > "$_tmp"
  print -s "$_c"
  BUFFER="clipso run $_tmp"
  zle accept-line
}
_clipso_zshaddhistory() {
  [[ "$1" == "clipso run /"* ]] && return 1
  return 0
}
autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory _clipso_zshaddhistory
zle -N _wrap_clipso
bindkey "^[g" _wrap_clipso
# <<< clipso-keybinding <<<

# >>> bw >>>
# Bitwarden CLI session persistence. The session token lives in a
# private file (~/.local/state/bw/session, mode 600) written by the
# `bwunlock` helper below. It is never echoed to the terminal or
# written to shell history.
if [ -r "$HOME/.local/state/bw/session" ]; then
  BW_SESSION="$(<"$HOME/.local/state/bw/session")"
  export BW_SESSION
fi
bwunlock() {
  local _dir="$HOME/.local/state/bw"
  local _file="$_dir/session"
  local _tmp
  mkdir -p "$_dir" && chmod 700 "$_dir"
  _tmp="$(mktemp "${TMPDIR:-/tmp}/bw-session.XXXXXX")" || return 1
  chmod 600 "$_tmp"
  if bw unlock --raw > "$_tmp"; then
    chmod 600 "$_tmp"
    mv "$_tmp" "$_file"
    BW_SESSION="$(<"$_file")"
    export BW_SESSION
    print "bw: session saved to $_file"
  else
    rm -f "$_tmp"
    print "bw: unlock failed" >&2
    return 1
  fi
}
# <<< bw <<<

# >>> motd on first shell of a tmux session >>>
# Termux prints the motd (ASCII logo) on login. byobu clears the screen
# when it paints its layout, so that motd is lost. Show it again inside
# the first shell that runs in a fresh tmux session. A per-session
# environment marker records that it has been shown, so subsequent
# shells (Ctrl-b c, split panels) stay silent; when the tmux server
# exits, the marker disappears and the next session shows the motd
# again.
if [ -n "${TMUX:-}" ] && [ -t 1 ]; then
    if ! tmux show-environment _ZSH_MOTD_SHOWN >/dev/null 2>&1; then
        tmux set-environment _ZSH_MOTD_SHOWN 1
        _motd=""
        if [ -r /data/data/com.termux/files/usr/etc/motd ]; then
            _motd=/data/data/com.termux/files/usr/etc/motd
        elif [ -r /etc/motd ]; then
            _motd=/etc/motd
        fi
        [ -n "$_motd" ] && cat "$_motd"
    fi
fi
# <<< motd on first shell of a tmux session <<<

# >>> byobu autostart >>>
# Every interactive zsh enters byobu (tmux backend) with the session name
# "main". Entry is guarded, in this order:
#   - interactive shell ($- contains i)
#   - real TTY on stdout
#   - not already inside tmux/byobu ($TMUX unset)
#   - not captured by a wrapper: clipso exports CLIPSO_ACTIVE and
#     UT_NO_ATTACH to signal "no interactive side-effects"
#   - not explicitly disabled (ZSH_NO_BYOBU=1)
#   - byobu is installed
# `new-session -A -s s1` creates the session named "s1" on first entry
# and attaches to it on every subsequent entry, from any shell or any
# node: the same session is reused instead of piling up new ones.
# Additional sessions, if ever needed, are named by the user with
# Ctrl-a $ inside tmux (the standard tmux rename key).
# Exit is two-step: Ctrl-d leaves byobu, Ctrl-d again leaves the shell.
if [[ $- == *i* ]] \
   && [ -t 1 ] \
   && [ -z "${TMUX:-}" ] \
   && [ -z "${CLIPSO_ACTIVE:-}" ] \
   && [ -z "${UT_NO_ATTACH:-}" ] \
   && [ -z "${ZSH_NO_BYOBU:-}" ] \
   && command -v byobu >/dev/null 2>&1; then
    byobu new-session -A -s s1
fi
# <<< byobu autostart <<<
