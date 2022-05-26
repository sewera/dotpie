#!/bin/sh

arrange_windows() {
  i3-msg '[class="^Microsoft Teams"] move container to workspace 7' 2>&1
  i3-msg '[class="^Spotify$"] move container to workspace 8' 2>&1
  i3-msg '[class="^Signal$"] move container to workspace 9' 2>&1
}

arrange_windows > /dev/null
