#!/bin/bash

# Get Waybar window ID (class is "waybar")
WAYBAR_ID=$(hyprctl clients | grep waybar | awk '{print $1}')

if [ -z "$WAYBAR_ID" ]; then
  exit 1
fi

# Get current position
POS=$(hyprctl dispatch getwindowgeometry $WAYBAR_ID | grep "Position:" | awk '{print $2}')

if [ "$POS" == "0,0" ]; then
  # Move it offscreen to hide
  hyprctl dispatch movewindow $WAYBAR_ID 9999 9999
else
  # Move it back to top-left (or your preferred position)
  hyprctl dispatch movewindow $WAYBAR_ID 0 0
fi

