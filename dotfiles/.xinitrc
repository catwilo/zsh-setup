#!/bin/sh
# Xorg init for zsh-setup (Debian).
# Optional: uncomment wacom and xrandr lines if the hardware is present.
# exec "$HOME/.local/bin/wacom" &
# xrdb -load ~/.Xresources
# picom -b &
# xrandr --output HDMI-1 --mode 1360x768 &
[ -x "$HOME/.fehbg" ] && "$HOME/.fehbg" &
# alacritty -e byobu &
exec i3
