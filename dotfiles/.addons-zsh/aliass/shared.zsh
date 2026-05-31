# shared.zsh — universal aliases (all platforms)

alias nano='nvim'
alias v='nvim'
alias ra='ranger'
alias bb='byobu'
alias ll='ls -h --color=auto --group-directories-first'
alias cls='clear'
alias :q='exit'
alias ff='fastfetch'
alias src='source ~/.zshrc'
alias w='watch -n 1'
alias s.='sudo'
alias s.v='sudo nvim'
alias s.r='sudo ranger'
alias s.ctl='sudo systemctl'
alias gitc='git add . && git commit -m'

# clipboard helper — wraps any binary with clipso (2>&1 included)
clipc() { "$@" 2>&1 | clipso; }
