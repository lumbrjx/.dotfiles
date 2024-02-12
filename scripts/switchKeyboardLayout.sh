#!/bin/bash

# Get the current keyboard layout
current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')

# Define the layouts in an array
layouts=("us" "fr")

# Find the index of the current layout in the array
index=0
for i in "${!layouts[@]}"; do
    if [ "${layouts[$i]}" = "$current_layout" ]; then
        index=$i
        break
    fi
done

# Calculate the index of the next layout
next_index=$(( ($index + 1) % ${#layouts[@]} ))

# Get the next layout from the array
new_layout=${layouts[$next_index]}

# Apply the new layout
setxkbmap -layout "$new_layout"

