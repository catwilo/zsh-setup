#!/bin/sh
exec /home/ni/scripts/wacom & 
#xrdb -load ~/.Xresources
#picom -b &
xrandr --output HDMI-1 --mode 1360x768 &
~/.fehbg &
alacritty -e byobu &
exec i3
