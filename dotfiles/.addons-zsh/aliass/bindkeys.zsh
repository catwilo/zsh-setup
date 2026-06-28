# bindkeys.zsh — unified key bindings (Termux, SSH, tmux, X11)
# No duplicates; order: Termux native → SSH → tmux → X11 extras

# ── Movement ──────────────────────────────────────────────────────────────────
bindkey '^[[H'  beginning-of-line      # Termux HOME
bindkey '^[OH'  beginning-of-line      # tmux HOME
bindkey '^[[1~' beginning-of-line      # X11 HOME
bindkey '\e[H'  beginning-of-line     # SSH HOME
bindkey '\e[1~' beginning-of-line     # SSH HOME alt

bindkey '^[[F'  end-of-line            # Termux END
bindkey '^[OF'  end-of-line            # tmux END
bindkey '^[[4~' end-of-line            # X11 END
bindkey '\e[F'  end-of-line           # SSH END
bindkey '\e[4~' end-of-line           # SSH END alt

bindkey '^[[3~' delete-char            # DEL (all)
bindkey '\e[3~' delete-char           # SSH DEL

bindkey '^[[5~' beginning-of-history   # PGUP (all)
bindkey '^[[6~' end-of-history         # PGDN (all)
bindkey '\e[5~' beginning-of-history  # SSH PGUP
bindkey '\e[6~' end-of-history        # SSH PGDN

# ── Word navigation ───────────────────────────────────────────────────────────
bindkey '^[[1;5D' backward-word        # CTRL←
bindkey '^[[1;5C' forward-word         # CTRL→
bindkey '\e[1;5D' backward-word       # SSH CTRL←
bindkey '\e[1;5C' forward-word        # SSH CTRL→

# ── Kill ──────────────────────────────────────────────────────────────────────
bindkey '^[[1;3D' backward-kill-line   # ALT←
bindkey '^[[1;3C' kill-line            # ALT→
bindkey '^[[1;7D' backward-kill-word   # CTRL+ALT←
bindkey '^[[1;7C' kill-word            # CTRL+ALT→
bindkey '\e[1;3D' backward-kill-line  # SSH ALT←
bindkey '\e[1;3C' kill-line           # SSH ALT→
bindkey '\e[1;7D' backward-kill-word  # SSH CTRL+ALT←
bindkey '\e[1;7C' kill-word           # SSH CTRL+ALT→

# ── Backspace / undo ──────────────────────────────────────────────────────────
bindkey '^H' backward-delete-char      # BS insert
bindkey '^?' backward-delete-char      # BS normal
bindkey '^[z' undo                     # ALT+Z (Termux/tmux/X11)
bindkey '\ez' undo                    # ALT+Z (SSH)

