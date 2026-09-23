# functions.zsh — shell functions (all platforms)

# py: activate venv, run .py
py(){
  emulate -L zsh
  . ~/.env/bin/activate
  python "$1"
  deactivate
}

# wpy: activate venv, run .py in watch loop
wpy(){
  emulate -L zsh
  . ~/.env/bin/activate
  watch -n1 "python \"$1\""
  deactivate
}

# pvi: activate venv, edit .py
pvi(){
  emulate -L zsh
  . ~/.env/bin/activate
  nvim "$1"
  deactivate
}

# alia: add/overwrite alias in shared.zsh
alia(){
  emulate -L zsh
  (( $#<2 )) && echo "uso: alia NAME CMD" && return
  local NAME=$1; shift
  local f=~/.addons-zsh/aliass/shared.zsh
  grep -q "^alias $NAME=" "$f" 2>/dev/null && {
    read "r?Sobreescribir? [y/N] "; [[ $r = [Yy] ]] || { echo Cancelado; return; }
  }
  local CMD=$(printf '%q ' "$@")
  CMD="${CMD#"${CMD%%[![:space:]]*}"}"
  CMD="${CMD%"${CMD##*[![:space:]]}"}"
  cp "$f" "$f.bak" 2>/dev/null
  grep -v "^alias $NAME=" "$f" 2>/dev/null | grep -v '^[[:space:]]*$' > "$f.tmp"
  { echo "alias $NAME='$CMD'"; cat "$f.tmp"; } > "$f"
  rm -f "$f.tmp"
  echo Saved
  source ~/.zshrc
}

# hist_rotate: roll histfile when full
hist_rotate(){
  local hist_file=$HISTFILE
  local hist_lines
  hist_lines=$(wc -l < "$hist_file")
  (( hist_lines >= HIST_MAX - 10 )) && echo "historial casi lleno"
  (( hist_lines < HIST_MAX )) && return
  local ts archive_dir
  ts=$(date +%y%m%d_%H%M)
  archive_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history-archive"
  mkdir -p "$archive_dir"
  mv "$hist_file" "$archive_dir/${ts}.bak"
  : > "$hist_file"
}

preexec(){
  # HISTORY_IGNORE-compatible filter. zsh's native HISTORY_IGNORE does not
  # fire here because this hook writes to the histfile directly. Mirror the
  # patterns that would otherwise be dropped, so wrapper calls never reach
  # the histfile.
  [[ "$1" == "clipso run /"*   ]] && { hist_rotate; return; }
  [[ "$1" == "clipso write "*  ]] && { hist_rotate; return; }
  [[ "$1" == "clipso paste"    ]] && { hist_rotate; return; }
  grep -qxF -- "$1" "$HISTFILE" || echo "$1" >> "$HISTFILE"
  hist_rotate
}
