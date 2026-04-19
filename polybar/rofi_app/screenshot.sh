#!/usr/bin/env bash

# Import Current Theme
dir="$HOME/.config/polybar/rofi_app/screenshotapp"
theme="$HOME/.config/polybar/rofi_app/script/screenshotapp.rasi"

# Theme Elements
prompt='Screenshot'
mesg="Directory :: $(xdg-user-dir PICTURES)/Screenshot"

# Options
layout=$(grep 'USE_ICON' "$theme" | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
	option_1=" Capture Desktop"
	option_2=" Capture Area"
	option_3=" Capture Window"
	option_4=" Capture in 5s"
	option_5=" Capture in 10s"
else
	option_1=""
	option_2=""
	option_3=""
	option_4=""
	option_5=""
fi

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme "$theme"
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

# Screenshot variables
time=$(date +%Y-%m-%d-%H-%M-%S)
geometry=$(xrandr | grep 'current' | head -n1 | cut -d',' -f2 | tr -d '[:blank:],current')
save_dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}_${geometry}.png"

# Directory check
[[ ! -d "$save_dir" ]] && mkdir -p "$save_dir"

# notify and view screenshot
notify_view() {
	notify_cmd_shot='dunstify -u low -h string:x-dunst-stack-tag:obscreenshot -i /usr/share/archcraft/icons/dunst/picture.png'
	${notify_cmd_shot} "Copied to clipboard."
	paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &>/dev/null &
	viewnior "${save_dir}/${file}"
	if [[ -e "${save_dir}/${file}" ]]; then
		${notify_cmd_shot} "Screenshot Saved."
	else
		${notify_cmd_shot} "Screenshot Deleted."
	fi
}

# Copy screenshot to clipboard
copy_shot () {
	tee "$file" | xclip -selection clipboard -t image/png
}

# Countdown
countdown () {
	for sec in $(seq "$1" -1 1); do
		dunstify -t 1000 -h string:x-dunst-stack-tag:screenshottimer -i /usr/share/archcraft/icons/dunst/timer.png "Taking shot in : $sec"
		sleep 1
	done
}

# Take shots
shotnow () {
	cd "$save_dir" && sleep 0.5 && maim -u -f png | copy_shot
	notify_view
}

shot5 () {
	countdown '5'
	sleep 1 && cd "$save_dir" && maim -u -f png | copy_shot
	notify_view
}

shot10 () {
	countdown '10'
	sleep 1 && cd "$save_dir" && maim -u -f png | copy_shot
	notify_view
}

shotwin () {
	cd "$save_dir" && maim -u -f png -i "$(xdotool getactivewindow)" | copy_shot
	notify_view
}

shotarea () {
	cd "$save_dir" && maim -u -f png -s -b 2 -c 0.608,0.749,0.749,0.25 -l | copy_shot
	notify_view
}

# Execute Command
run_cmd() {
	case "$1" in
		--opt1) shotnow ;;
		--opt2) shotarea ;;
		--opt3) shotwin ;;
		--opt4) shot5 ;;
		--opt5) shot10 ;;
	esac
}

# Actions
chosen="$(run_rofi)"
case "$chosen" in
    "$option_1") run_cmd --opt1 ;;
    "$option_2") run_cmd --opt2 ;;
    "$option_3") run_cmd --opt3 ;;
    "$option_4") run_cmd --opt4 ;;
    "$option_5") run_cmd --opt5 ;;
esac
