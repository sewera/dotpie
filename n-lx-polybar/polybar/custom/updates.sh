#!/bin/bash

# Simple script to indicate updates in polybar
# Uses checkupdates Arch Linux script (pacman-contrib)
# but can be altered to be used with any other
# script outputting nothing when there are no
# available updates

output=$(echo $(/usr/lib/update-notifier/apt-check 2>&1))
e_status=$?

if [[ "$output" == "0;0" ]]; then
  echo -e "%{F#494949}"
else
  echo -e "%{F#56D7FF}"
fi

