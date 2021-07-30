#!/bin/bash

xrandr \
  --output $(cat ~/.config/i3/monitor-tall.txt) --auto --rotate normal --pos 0x0 \
  --output $(cat ~/.config/i3/monitor-primary.txt) --auto --rotate normal --right-of $(cat ~/.config/i3/monitor-tall.txt) --primary \
  --output $(cat ~/.config/i3/monitor-secondary.txt) --off

sleep 0.3

wallschctl change &

sleep 0.3

/home/jazz/.config/polybar/launch.sh & > /dev/null
