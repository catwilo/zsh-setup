# .zshenv — sourced on every zsh invocation (login, interactive, scripts)
# Keep minimal: only exports needed before .zshrc loads
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
unset DSTASK_DATA  # never inherit from parent process
