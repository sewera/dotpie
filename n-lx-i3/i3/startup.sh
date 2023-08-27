#!/bin/bash

xrandr \
  --output $(cat ~/.config/i3/monitor-center.txt) --auto --rotate normal --primary \
  --output $(cat ~/.config/i3/monitor-left.txt) --auto --rotate normal --left-of $(cat ~/.config/i3/monitor-center.txt) \
  --output $(cat ~/.config/i3/monitor-right.txt) --auto --rotate normal --right-of $(cat ~/.config/i3/monitor-center.txt)

nitrogen --set-zoom-fill /home/jazz/Pictures/Wallpapers/ultra_multihead/desktop/night/night_wh_minecraft_city_lights_shaders.jpg

lockscreen -n /home/jazz/Pictures/Wallpapers/ultra_multihead/desktop/night/night_wh_earth_full.jpg &

sleep 1
/home/jazz/.config/polybar/launch.sh &

