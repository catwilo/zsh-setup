# .zshenv — sourced on every zsh invocation (login, interactive, scripts)
# Keep minimal: only exports needed before .zshrc loads
export DSTASK_DATA="${HOME}/unix-toolkit-tasks"
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
