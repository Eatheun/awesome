#!/bin/bash

options="Suspend\nPower off\nReboot"
chosen_option=$(echo -e "$options" | rofi -dmenu -i | tr "A-Z" "a-z" | tr -d "[:space:]")

case "$chosen_option" in
"poweroff" | "reboot") $("$chosen_option") ;;
"suspend") systemctl suspend ;;
*) : ;;
esac

exit 0
