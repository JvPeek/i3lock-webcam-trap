#!/usr/bin/env bash

# Get monitor info: name, width, height, x, y
monitors=()
while read -r line; do
    # Example: HDMI-1 connected primary 1920x1080+0+0 ...
    if [[ $line =~ ^([A-Za-z0-9-]+)\ connected.*\ ([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+) ]]; then
        name="${BASH_REMATCH[1]}"
        w="${BASH_REMATCH[2]}"
        h="${BASH_REMATCH[3]}"
        x="${BASH_REMATCH[4]}"
        y="${BASH_REMATCH[5]}"
        monitors+=("$name:$w:$h:$x:$y")
    fi
done < <(xrandr --query)

# Find total width and height
max_x=0
max_y=0
for m in "${monitors[@]}"; do
    IFS=: read name w h x y <<< "$m"
    (( x2 = x + w ))
    (( y2 = y + h ))
    (( x2 > max_x )) && max_x=$x2
    (( y2 > max_y )) && max_y=$y2
done

# Create base image
output="monitors.png"
convert -size "${max_x}x${max_y}" xc:white "$output"

# List of colors to cycle through
colors=(red green blue yellow orange cyan magenta purple pink gray)

# Draw rectangles
i=0
for m in "${monitors[@]}"; do
    IFS=: read name w h x y <<< "$m"
    color="${colors[$((i % ${#colors[@]}))]}"
    convert "$output" -fill "$color" -draw "rectangle $x,$y $((x+w)),$((y+h))" "$output"
    ((i++))
done

echo "Created $output" 