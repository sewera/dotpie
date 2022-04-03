#!/bin/bash

xrandr \
  --output $(cat ~/.config/i3/monitor-left.txt) --auto --rotate normal --pos 0x0 \
  --output $(cat ~/.config/i3/monitor-center.txt) --off \
  --output $(cat ~/.config/i3/monitor-right.txt) --auto --rotate normal --right-of $(cat ~/.config/i3/monitor-left.txt) --primary

sleep 0.3

wallschctl change &

sleep 0.3

/home/jazz/.config/polybar/launch.sh & > /dev/null
