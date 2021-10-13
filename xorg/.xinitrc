#!/bin/sh

# ~/.xsessionrc is executed on Debian (and derivatives such as Ubuntu, Linux Mint, etc.)
# by the X startup scripts on a GUI login, for all session types and (I think) from 
# all display managers. It's also executed from startx if the user doesn't have a .xinitrc, 
# because in that case startx falls back on the same session startup scripts that 
# are used for GUI login. It's executed relatively early, after loading resources 
# but before starting any program such as a key agent, a D-Bus daemon, etc. 
# It typically sets variables that can be used by later startup scripts. 
# It doesn't have any official documentation that I know of, you have to dig into the 
# source to see what works.

# tl;dr: 
# 
#     ~/.xsession is the way to go when using a login manager (like gdm, kdm, xdm).
#     ~/.xinitrc will be used when you use startx

# Enforce correct locales from the beginning:
# LC_ALL is unset since it overwrites everything
# LANG=de_DE.UTF-8 is used, except for:
# LC_MESSAGES=C never translates program output
# LC_TIME=en_DK leads to yyyy-mm-dd hh:mm date/time output
unset LC_ALL
export LANG=de_DE.UTF-8
export LC_MESSAGES=C
export LC_TIME=en_DK.UTF-8
export TZ=Europe/Berlin
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Xresources
xrdb -merge ~/.Xresources

# keyboard setup
xmodmap ~/.Xmodmap

# Font
xset +fp ~/.local/share/fonts/

# Increase key repeat rate
xset r rate 300 50 &

# Turn off system beep
xset b off &
xset b 0 0 0 &

# Make sure cursor is not an X when hovering over root window
xsetroot -cursor_name left_ptr &

# Startup
picom &
unclutter --timeout 1 &
redshift -l 52.50:13.42 &
dunst &

# Send notifications regarding battery usage
battery-notify &

# Enable zapping (C-A-<Bksp> kills X)
setxkbmap -option terminate:ctrl_alt_bksp

# Set background color
xsetroot -solid "#333333"

# Enable core dumps in case something goes wrong
ulimit -c unlimited

# Start window manager
exec /usr/bin/sway > /tmp/sway.log
