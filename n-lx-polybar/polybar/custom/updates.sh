#!/bin/bash

# Simple script to indicate updates in polybar
# Uses checkupdates Arch Linux script (pacman-contrib)
# but can be altered to be used with any other
# script outputting nothing when there are no
# available updates

output=$(checkupdates 2>/dev/null)
e_status=$?

if [[ -z $output ]]; then
  echo -e "%{F#666666}"
else
  echo -e "%{F#56D7FF}"
fi

