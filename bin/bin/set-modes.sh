xrandr --newmode "2560x2160x60" 362.50 2560 2608 2640 2720  2160 2163 2173 2222 +hsync -vsync
xrandr --addmode DP-1 2560x2160x60
xrandr --addmode DP-2 2560x2160x60
xrandr --output DP-1 --mode 2560x2160x60 --scale 1.0 --output DP-2 --mode 2560x2160x60 --scale 1.0 --left-of DP-1

