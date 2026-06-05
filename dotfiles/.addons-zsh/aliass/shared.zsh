alias ccc='clear'
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

# clipso --to drain: runs after every command, outside any pipeline (no blocking)
_clipso_to_drain() {
    local _cache="${XDG_CACHE_HOME:-$HOME/.cache}/clipso"
    local _pending="$_cache/to-pending"
    local _payload="$_cache/to-payload"
    [[ -f "$_pending" && -f "$_payload" ]] || return 0
    local _aliases; _aliases="$(cat "$_pending")"
    rm -f "$_pending"
    local _nclip="${NOEMAP_BASE:-$HOME/unix-toolkit-tools/noemap}/bin/nclip-send"
    [[ -x "$_nclip" ]] || return 0
    local _a
    for _a in ${(s:,:)_aliases}; do
        [[ -n "$_a" ]] || continue
        setsid "$_nclip" "$_a" < "$_payload" </dev/null >/dev/null 2>&1 &
    done
    rm -f "$_payload"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _clipso_to_drain
