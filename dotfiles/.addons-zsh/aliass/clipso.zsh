# clipso.zsh — Alt+G wraps the current zsh buffer in `clipso run`.
#
# Owned by the zsh-setup repo (this directory is fully replaced by
# dotfiles/install.sh on every deploy; anything not versioned here is
# lost). Sourced from the versioned .zshrc via:
#     [ -f "$_al/clipso.zsh" ] && source "$_al/clipso.zsh"
# Requires the `clipso` binary in PATH; harmless when absent because
# `clipso` is only invoked at keypress time, not at source time.

# _wrap_clipso: take current buffer, write it to a temp script, and
# re-enter the line as `clipso run <script>`. Keeps the user's command
# in history (print -s) so the wrapper is transparent.
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

# _clipso_zshaddhistory: skip the `clipso run /tmp/...` line from history
# so repeated Alt+G presses don't pollute the histfile with temp paths.
_clipso_zshaddhistory() {
  [[ "$1" == "clipso run /"* ]] && return 1
  return 0
}

autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory _clipso_zshaddhistory
zle -N _wrap_clipso
bindkey "^[g" _wrap_clipso
