#!/usr/bin/env bash

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

for m in "${monitors[@]}"; do
    IFS=: read name w h x y <<< "$m"
    if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
        # Create a temp image for this monitor
        magick "$wallpaper" -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" -colorspace sRGB "$tmpbg"
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