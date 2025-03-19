#!/bin/bash

options="⏾ Suspend\n⏻ Power off\n🗘 Reboot"
chosen_option=$(echo -e "$options" | rofi -dmenu -i | tr "A-Z" "a-z" | tr -d "[:space:]" | grep -oE "[a-z]*")

case "$chosen_option" in
"poweroff" | "reboot") $("$chosen_option") ;;
"suspend") systemctl suspend ;;
*) : ;;
esac

exit 0
