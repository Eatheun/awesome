#!/bin/bash

run="Run"
music="Music"
calc="Calculator"
bluetooth="Bluetooth"
network="Network"
win="Window"
files="Files"
options="$run\n$music\n$calc\n$bluetooth\n$network\n$win\n$files"
chosen_option=$(echo -e "$options" | rofi -i -dmenu -matching prefix -config /home/eatheun/.config/awesome/rofi/rofi-all.rasi)

case "$chosen_option" in
"$run") rofi -matching prefix -show drun -modi drun -show-icons ;;
"$music") bash /home/eatheun/.config/awesome/rofi/rofi-music.sh ;;
"$calc") rofi -show calc -modi calc -no-show-match -no-sort -automatic-save-to-history ;;
"$bluetooth") bash /home/eatheun/.config/awesome/rofi/rofi-bluetooth.sh ;;
"$network") bash /home/eatheun/.config/awesome/rofi/rofi-wifi-menu.sh ;;
"$win") rofi -show window -modi window -show-icons ;;
"$files") rofi -show filebrowser -modi filebrowser -show-icons ;;
*) : ;;
esac

exit 0
