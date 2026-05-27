# termux.zsh — Termux-only aliases and variables

export sd0='/storage/emulated/0'
# export SD='/storage/...'  # set to your SD card path if present

alias sd='cd /storage/emulated/0'
alias vT='nvim $HOME/.termux/termux.properties'
alias vZ='nvim $HOME/.addons-zsh/aliass/shared.zsh'
alias vz='nvim $HOME/.zshrc'
alias arch='proot-distro login archlinux --user u --termux-home'

# clipboard
alias clipso='~/unix-toolkit-tools/clipso/clipso.sh'
clipc() { if [ "${1:-}" = -- ]; then shift; printf %s "$*" | clipso; else clipso; fi; }
