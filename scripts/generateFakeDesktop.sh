#!/usr/bin/env bash

# Configurable parameters
BAR_HEIGHT_PIXELS=64      # Height of the blurred/darkened area in pixels
DARKEN_PERCENT=60         # Percentage to darken the area (0-100)

blur_and_darken_bar() {
    local img="$1"
    local w="$2"
    local h="$3"
    local bar_height="$4"
    local darken_percent="$5"
    local bar_y=$(( h - bar_height ))
    local tmp_blur="tmp_blur.png"

    # Blur the lower bar_height pixels
    magick "$img" \
      \( -clone 0 -crop "${w}x${bar_height}+0+${bar_y}" +repage -blur 0x8 \) \
      -geometry +0+${bar_y} -composite "$img"

    # Darken the blurred area
    local alpha=$(awk "BEGIN { printf \"%.2f\", $darken_percent/100 }")
    magick "$img" -fill "rgba(0,0,0,$alpha)" -draw "rectangle 0,$bar_y $w,$h" "$img"
}

get_wallpaper() {
    # Try feh
    if [ -f ~/.fehbg ]; then
        grep -oE '/[^ ]+\.(jpg|png|jpeg|bmp)' ~/.fehbg | head -n1 && return
    fi
    # Try GNOME
    if command -v gsettings >/dev/null 2>&1; then
        gsettings get org.gnome.desktop.background picture-uri 2>/dev/null | \
            sed -e "s/^'file:\/\///" -e "s/'$//" | grep -E '\.(jpg|png|jpeg|bmp)$' && return
    fi
    # Try XFCE
    if command -v xfconf-query >/dev/null 2>&1; then
        xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path 2>/dev/null | \
            grep -E '\.(jpg|png|jpeg|bmp)$' && return
    fi
    # Try KDE (Plasma 5, may need tweaking)
    if command -v qdbus >/dev/null 2>&1; then
        qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
            "print(desktops()[0].wallpaperPlugin); print(desktops()[0].currentConfigGroup); print(desktops()[0].wallpaper);" 2>/dev/null | \
            grep -m1 '^file:' | sed 's|file://||' | grep -E '\.(jpg|png|jpeg|bmp)$' && return
    fi
    echo ""
}

# Get monitor info: name, width, height, x, y
monitors=()
while read -r line; do
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

# Detect wallpaper
wallpaper=$(get_wallpaper)
echo "Detected wallpaper: $wallpaper"

output="monitors.png"
tmpbg="tmpbg.png"
# Create a truecolor RGB base image
magick -size 1x1 canvas:white -resize "${max_x}x${max_y}!" -colorspace sRGB "PNG24:$output"

# --- ICON BAR GENERATION ---
create_center_icon_bar() {
    local icon_dir="icons/center"
    local out_png="icons/center.png"
    local icon_size=40
    local icons=()
    local i=0
    # Collect all PNGs, sorted
    while IFS= read -r f; do
        icons+=("$f")
    done < <(find "$icon_dir" -maxdepth 1 -type f -iname '*.png' | sort)
    local num_icons=${#icons[@]}
    local width=$((icon_size * num_icons))
    if (( num_icons == 0 )); then
        echo "No icons found in $icon_dir, skipping center bar generation."
        return
    fi
    # Build the magick command
    local cmd=(magick convert -background none -extent "${width}x${icon_size}")
    for icon in "${icons[@]}"; do
        cmd+=( "(" "$icon" -resize ${icon_size}x${icon_size}^ -gravity center -extent ${icon_size}x${icon_size} ")" -geometry "+$((i*icon_size))+0" -gravity NorthWest -composite )
        ((i++))
    done
    cmd+=("$out_png")
    # Run the command
    "${cmd[@]}"
    echo "Created $out_png with $num_icons icons."
}

# Call the icon bar generation before main logic
create_center_icon_bar

# Get icon bar dimensions
ICON_BAR="icons/center.png"
ICON_BAR_W=0
ICON_BAR_H=0
if [ -f "$ICON_BAR" ]; then
    read ICON_BAR_W ICON_BAR_H < <(magick identify -format '%w %h' "$ICON_BAR")
fi

for m in "${monitors[@]}"; do
    IFS=: read name w h x y <<< "$m"
    if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
        # Create a temp image for this monitor
        magick "$wallpaper" -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" -colorspace sRGB "$tmpbg"
        # Blur and darken the lower bar
        blur_and_darken_bar "$tmpbg" "$w" "$h" "$BAR_HEIGHT_PIXELS" "$DARKEN_PERCENT"
        # Composite icon bar at the center of the bottom bar ON TMPBG
        if [ "$ICON_BAR_W" -gt 0 ] && [ "$ICON_BAR_H" -gt 0 ]; then
            ICON_X=$(( (w - ICON_BAR_W) / 2 ))
            ICON_Y=$(( h - BAR_HEIGHT_PIXELS/2 - ICON_BAR_H/2 ))
            magick "$tmpbg" "$ICON_BAR" -geometry "+${ICON_X}+${ICON_Y}" -composite "$tmpbg"
        fi
        # Composite it onto the canvas at the correct position
        magick "$output" "$tmpbg" -geometry "+${x}+${y}" -composite "PNG24:$output"
    else
        # Fallback: fill with a color if no wallpaper found
        color="#$(openssl rand -hex 3)"
        magick "$output" -fill "$color" -draw "rectangle $x,$y $((x+w)),$((y+h))" "PNG24:$output"
    fi

done

rm -f "$tmpbg"
echo "Created $output" 