#!/bin/bash

play_random() {
    # get a random 2-byte unsigned integer
    randint=$(head -c4 /dev/random | od -d | tr '\n' ' ' | sed -E "s/ +/ /g" | cut -d ' ' -f2,3 | tr -d ' ')

    # get num musics and get random'th music
    musics=$(find ~/Music/ | sed -nE "/\.mp3$/p")
    n_mus=$(echo -n "$musics" | wc -l)
    if [ "$n_mus" != 0 ]; then
        ran_mus=$(echo "$musics" | sed -n "$((randint % n_mus + 1))p")

        # play and notify song name
        song_name=$(echo "$ran_mus" | grep -oE "[^/]*$")
        notify-send "Playing: $song_name"
        mpg123 "$ran_mus"
    else
        notify-send "No music to play in ~/Music/ folder!"
        exit 1
    fi
}

stop_option="⏸ Stop music"
random_option="☸ Play random"
divider="__________________________________"
run_rofi_with_options() {
    list="$random_option\n"
    if [ $(($(pidof mpg123))) -gt 0 ]; then
        list="$list$stop_option\n"
    fi
    list="$list$divider\n"
    for mus_fn in "$HOME"/Music/*.mp3; do
        mus_fn=$(echo "$mus_fn" | grep -oE "[^/]*$" | sed -E "s/\.mp3$//")
        list="$list$mus_fn\n"
    done
    echo -ne "$list" | rofi -i -dmenu
}

stop_music() {
    pkill -f mpg123
}

# run rofi and process options
chosen_option=$(run_rofi_with_options)
case "$chosen_option" in
"$stop_option")
    stop_music &
    notify-send "Stopping music"
    ;;
"$random_option")
    stop_music &
    play_random
    ;;
"" | "$divider") : ;; # no input
*)
    stop_music &
    notify-send "Playing: $chosen_option" && mpg123 "$HOME/Music/$chosen_option.mp3"
    ;;
esac

exit 0
