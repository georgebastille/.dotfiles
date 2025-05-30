#!/bin/bash

BAT_PATH="/sys/class/power_supply/BAT0"

if [ -f "$BAT_PATH/power_now" ]; then
  powerDraw=" $(echo "scale=1; $(cat "$BAT_PATH/power_now") / 1000000" | bc)w"
elif [ -f "$BAT_PATH/voltage_now" ] && [ -f "$BAT_PATH/current_now" ]; then
  voltage=$(cat "$BAT_PATH/voltage_now")
  current=$(cat "$BAT_PATH/current_now")
  # Calculate watts with one decimal place: (µV * µA) / 1_000_000_000
  power=$(echo "scale=1; ($voltage * $current) / 1000000000000" | bc)
  powerDraw=" ${power}w"
else
  powerDraw="Power data unavailable"
fi

cat << EOF
{ "text":"$powerDraw", "tooltip":"Power Draw: $powerDraw" }
EOF
