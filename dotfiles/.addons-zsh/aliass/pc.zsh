# pc.zsh — Linux desktop (X11) aliases and variables

export DISPLAY=:0
export XCURSOR_SIZE=64

alias mkt='mkdir -p mnt nmap content shared exploits scripts'
alias bon='sudo bluetoothctl power on'
alias boff='sudo bluetoothctl power off'
alias jbl='sudo bluetoothctl connect 28:FA:19:9A:1F:BF'  # edit MAC as needed
alias .bbar='tmux set-option status'                       # on | off
