#!/bin/bash

wallschd &

xrandr \
  --output $(cat ~/.config/i3/monitor-center.txt) --auto --rotate normal --primary \
  --output $(cat ~/.config/i3/monitor-left.txt) --auto --rotate normal --left-of $(cat ~/.config/i3/monitor-center.txt) \
  --output $(cat ~/.config/i3/monitor-right.txt) --auto --rotate normal --right-of $(cat ~/.config/i3/monitor-center.txt)

sleep 1

wallschctl change

sleep 1
/home/jazz/.config/polybar/launch.sh &

