alias nano='nvim'
alias vT='nvim /data/data/com.termux/files/home/.termux/termux.properties'
alias w='watch -n 1'
alias vZ='nvim /data/data/com.termux/files/home/.addons-zsh/aliass/main.zsh'
alias vz='nvim /data/data/com.termux/files/home/.zshrc'
alias ra='ranger'
alias bb='byobu'
alias ll='ls -h --color=auto --group-directories-first'
alias cls='clear'
alias :q='exit'
alias v='nvim'
alias ff='fastfetch'
alias src='source ~/.zshrc'
## variables con export globales
## key behavior
# Termux
bindkey '^[[H' beginning-of-line       # HOME
bindkey '^[[F' end-of-line             # END
bindkey '^[[3~' delete-char            # DEL
bindkey '^[[5~' beginning-of-history   # PGUP
bindkey '^[[6~' end-of-history         # PGDN
bindkey '^[[1;5D' backward-word        # CTRL←
bindkey '^[[1;5C' forward-word         # CTRL→
bindkey '^[[1;3D' backward-kill-line   # ALT← borra hasta inicio línea
bindkey '^[[1;3C' kill-line            # ALT→ borra hasta fin línea
bindkey '^[[1;7D' backward-kill-word   # CTRL+ALT← borra palabra atrás
bindkey '^[[1;7C' kill-word            # CTRL+ALT→ borra palabra adelante
bindkey '^H' backward-delete-char      # BS modo insert
bindkey '^?' backward-delete-char      # BS modo normal
# SSH
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line
bindkey '\e[3~' delete-char
bindkey '\e[5~' beginning-of-history
bindkey '\e[6~' end-of-history
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word
bindkey '\e[1;3D' backward-kill-line
bindkey '\e[1;3C' kill-line
bindkey '\e[1;7D' backward-kill-word
bindkey '\e[1;7C' kill-word
# tmux
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[5~' beginning-of-history
bindkey '^[[6~' end-of-history
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;3D' backward-kill-line
bindkey '^[[1;3C' kill-line
bindkey '^[[1;7D' backward-kill-word
bindkey '^[[1;7C' kill-word
# X11
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[5~' beginning-of-history
bindkey '^[[6~' end-of-history
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;3D' backward-kill-line
bindkey '^[[1;3C' kill-line
bindkey '^[[1;7D' backward-kill-word
bindkey '^[[1;7C' kill-word
# Termux/tmux/X11 
bindkey '^H' backward-delete-char
bindkey '^?' backward-delete-char
bindkey '^[z' undo                         # ALT+Z deshacer
# SSH  
bindkey '\ez' undo                         # ALT+Z deshacer
## funciones
# py: act env, run .py  
py(){
  emulate -L zsh
  . ~/.env/bin/activate
  python "$1"
  deactivate
}
# wpy: act env, run .py loop  
wpy(){
  emulate -L zsh
  . ~/.env/bin/activate
  watch -n1 "python \"$1\""
  deactivate
}
# pvi: act env, edit .py  
pvi(){
  emulate -L zsh
  . ~/.env/bin/activate
  nvim "$1"
  deactivate
}
# alia: agregra alias a .zshrc from main.zsh
alia(){
 emulate -L zsh                             # zsh modo aislado
 (( $#<2 ))&&echo uso: alia NAME CMD&&return
 local NAME=$1;shift
 local f=~/.addons-zsh/aliass/main.zsh
 grep -q "^alias $NAME=" "$f" 2>/dev/null&&{
  read "r?Sobreescribir? [y/N] ";[[ $r = [Yy] ]]||{ 
   echo Cancelado;return 
  }
 }
 local CMD=$(printf '%q ' "$@")
 CMD="${CMD#"${CMD%%[![:space:]]*}"}"
 CMD="${CMD%"${CMD##*[![:space:]]}"}"
 cp "$f" "$f.tenshi" 2>/dev/null
 grep -v "^alias $NAME=" "$f" 2>/dev/null|grep -v '^[[:space:]]*$'>"$f.tmp"
 { echo "alias $NAME='$CMD'";cat "$f.tmp"; }>"$f"
 rm -f "$f.tmp"
 echo Saved
 source ~/.zshrc
}
hist_rotate() {
  local hist_file=$HISTFILE
  local hist_lines=$(wc -l < "$hist_file")
  (( hist_lines >= HIST_MAX - 10 )) && echo "archivo historial casi lleno"
  (( hist_lines < HIST_MAX )) && return
  echo "Maid-tan ROLLING HISTFILE"
  local current_date=$(date +%y%m%d_%H%M); mv "$hist_file" "$(dirname "$hist_file")/$current_date.tenshi"
  : > "$hist_file"
}
preexec() {
  grep -qxF -- "$1" "$HISTFILE" || echo "$1" >> "$HISTFILE"
  hist_rotate
}
