#!/bin/bash

xrandr \
  --output $(cat ~/.config/i3/monitor-primary.txt) --auto --rotate normal --primary \
  --output $(cat ~/.config/i3/monitor-tall.txt) --auto --rotate normal --left-of $(cat ~/.config/i3/monitor-primary.txt) \
  --output $(cat ~/.config/i3/monitor-secondary.txt) --auto --rotate normal --right-of $(cat ~/.config/i3/monitor-primary.txt)

wallschctl change

lockscreen -n /home/jazz/Pictures/Wallpapers/ultra_multihead/desktop/night/night_wh_earth_full.jpg &

sleep 1
/home/jazz/.config/polybar/launch.sh &

