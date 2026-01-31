#!/bin/bash

# constants
SNAKE_CHAR_WIDTH=2
START_SIZE=3
START_ROW=0
START_COL=0
GREEN=$(tput setab 2)
RED=$(tput setab 1)
RESET=$(tput sgr0)
POS_TO_REM="0,0"

# get the terminal size
rows=$(tput lines)
cols=$(tput cols)

# game variables
snake=("8,4" "6,4" "4,4")
snake_size=${#snake[@]}
dir_x=1
dir_y=0

cleanup() {
	tput cnorm
}

draw_snake() {
	echo -ne "$GREEN"

	for segment in "${snake[@]}"; do
		IFS=',' read -r col row <<< $segment
		tput cup "$row" "$col"
		printf "%*s" $SNAKE_CHAR_WIDTH " "
	done

	echo -ne "$RESET"

	# save the current terminal coords
	printf '\e7'

	# draw empty two spaces at the last position
	IFS=',' read -r rem_x rem_y <<< "${POS_TO_REM}"
	tput cup "$rem_y" "$rem_x"
	printf "%*s" $SNAKE_CHAR_WIDTH " "

	# restore them
	printf '\e8'
}

move_snake() {
	POS_TO_REM="${snake[${#snake[@]}-1]}"

	# move over the body
	for ((i=${#snake[@]}-1; i>0; i--)); do
		snake[$i]="${snake[$i-1]}"
	done

	# move the head
	IFS=',' read -r head_x head_y <<< "${snake[0]}"
	#dir_x=$1
	#dir_y=$2
	head_x=$((head_x + dir_x * SNAKE_CHAR_WIDTH))
	head_y=$((head_y + dir_y))
	snake[0]="$head_x,$head_y"
}

read_key() {
	IFS= read -rsn1 -t 0.01 key1
	if [[ $key1 == $'\e' ]]; then
		read -rsn2 -t 0.01 key2
		key="$key1$key2"
	else
		key="$key1"
	fi
	echo "$key"
}

# enable cleanup
trap cleanup EXIT

# disable cursor
tput civis

# disable line buffering
stty -echo -icanon time 0 min 0

# clear the terminal
tput clear

# game loop
while true; do
	draw_snake

	key=$(read_key)

	if [[ -n $key ]]; then
		case "$key" in
			$'\e[A') dir_x=0; dir_y=-1 ;;
			$'\e[B') dir_x=0; dir_y=1 ;;
			$'\e[C') dir_x=1; dir_y=0 ;;
			$'\e[D') dir_x=-1; dir_y=0 ;;
		esac
	fi
	# echo "$dir_x$dir_y"
	move_snake
	sleep 0.05
done

stty sane

#echo -e "$GREEN $rows, $cols"
