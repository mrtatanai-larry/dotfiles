#!/usr/bin/env bash

# Import Current Theme
dir="$HOME/.config/polybar/rofi_app/powermenu"
theme="$HOME/.config/polybar/rofi_app/script/powermenuapp.rasi"

# Theme Elements
prompt='Powermenu'
mesg="Uptime : `uptime -p | sed -e 's/up //g'`"

# Options
layout=`cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
	option_1=" Lock"
	option_2=" Logout"
	option_3=" Suspend"
	option_4=" Hibernate"
	option_5=" Reboot"
	option_6=" Shutdown"
else
	option_1=""
	option_2=""
	option_3=""
	option_4=""
	option_5=""
	option_6=""
fi

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Confirmation CMD
confirm_cmd() {
	rofi -dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-selected-row 1 \
		-no-click-to-exit \
		-theme ${theme}
}

# Execute Command
run_cmd() {
	case "$1" in
		--opt1) betterlockscreen --lock ;;
		--opt2) kill -9 -1 ;;
		--opt3) mpc -q pause; pulsemixer --mute; betterlockscreen --suspend ;;
		--opt4) systemctl hibernate ;;
		--opt5) systemctl reboot ;;
		--opt6) systemctl poweroff ;;
	esac
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
    $option_4)
		run_cmd --opt4
        ;;
    $option_5)
		run_cmd --opt5
        ;;
    $option_6)
		run_cmd --opt6
        ;;
esac
