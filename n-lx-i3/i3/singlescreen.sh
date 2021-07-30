#!/bin/bash

xrandr \
  --output $(cat ~/.config/i3/monitor-tall.txt) --off \
  --output $(cat ~/.config/i3/monitor-primary.txt) --auto --rotate normal --primary \
  --output $(cat ~/.config/i3/monitor-secondary.txt) --off

sleep 0.3

wallschctl change &

sleep 0.3

/home/jazz/.config/polybar/launch.sh & > /dev/null
