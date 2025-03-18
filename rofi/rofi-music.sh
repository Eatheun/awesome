#!/bin/bash

list_music() {
    list=""
    if [ "$(pidof mpg123)" -gt 0 ]; then
        list="Stop music\n"
    fi
    for mus_fn in "$HOME"/Music/*.mp3; do
        mus_fn=$(echo "$mus_fn" | grep -oE "[^/]*$" | sed -E "s/\.mp3$//")
        list="$list$mus_fn\n"
    done
    echo -ne "$list" | rofi -i -dmenu
}

stop_music() {
    pkill -f mpg123
}

chosen_option=$(list_music)
case "$chosen_option" in
"Stop music")
    stop_music &
    notify-send "Stopping music"
    ;;
"") : ;; # no input
*)
    stop_music &
    notify-send "Playing: $chosen_option" && mpg123 "$HOME/Music/$chosen_option.mp3"
    ;;
esac

exit 0
