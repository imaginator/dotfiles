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
#
# Disable DPMS turning off the screen
#xset -dpms
#xset s off

# Disable bell
xset -b

# Enable zapping (C-A-<Bksp> kills X)
setxkbmap -option terminate:ctrl_alt_bksp

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

# Use XToolkit in java applications
export AWT_TOOLKIT=XToolkit

# Set background color
xsetroot -solid "#333333"

# Enable core dumps in case something goes wrong
ulimit -c unlimited

# Start i3 and log to ~/.i3/logfile
#echo "Starting at $(date)" >> ~/.i3/logfile
#exec /usr/bin/i3 -V -d all >> ~/.i3/logfile
