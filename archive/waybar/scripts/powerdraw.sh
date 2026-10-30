#!/bin/bash

BAT_PATH="/sys/class/power_supply/BAT0"

read -r voltage < "$BAT_PATH/voltage_now"
read -r current < "$BAT_PATH/current_now"

# Calculate (µV × µA) / 1e9 to get watts with one decimal
power_w=$(awk "BEGIN { printf \"%.1f\", ($voltage * $current) / 1000000000000 }")
powerDraw="${power_w}w"

cat << EOF
{ "text":"$powerDraw", "tooltip":"Power Draw: $powerDraw" }
EOF
