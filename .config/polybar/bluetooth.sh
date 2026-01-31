#!/bin/sh

# Check if Bluetooth is powered on
if bluetoothctl show | grep -q "Powered: yes"; then
  # Get device information
  device_info=$(bluetoothctl info)
  
  # Check if any devices are connected
  if echo "$device_info" | grep -q 'Connected: yes'; then
    # Extract device name
    device_name=$(echo "$device_info" | awk '/Name/ {print substr($2, index($0,$3))}')
    echo "%{F#bb9af7} $device_name"
  else
    echo "%{F#bb9af7}"
  fi
else
  echo "%{F#66ffffff}"
fi

