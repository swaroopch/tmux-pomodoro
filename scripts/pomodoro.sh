#!/usr/bin/env bash

# ----- Configuration -----

POMODORO_DURATION_MINUTES=25
POMODORO_BREAK_MINUTES=5

POMODORO_DIR="/tmp"
POMODORO_FILE="$POMODORO_DIR/pomodoro.txt"

# ----- Do not edit below this -----

# ----- Functionality -----

get_seconds () {
    date +%s
}

write_pomodoro_start_time () {
    mkdir -p $POMODORO_DIR
    echo $(get_seconds) > $POMODORO_FILE
}

read_pomodoro_start_time () {
    if [ -f $POMODORO_FILE ]
    then
        cat $POMODORO_FILE
    else
        echo -1
    fi
}

remove_pomodoro_start_time () {
    if [ -f $POMODORO_FILE ]
    then
        rm $POMODORO_FILE
    fi
}

if_inside_tmux () {
    test -n "${TMUX}"
}

pomodoro_start () {
    write_pomodoro_start_time
    if_inside_tmux && tmux refresh-client -S
    return 0
}

pomodoro_cancel () {
    remove_pomodoro_start_time
    if_inside_tmux && tmux refresh-client -S
    return 0
}

pomodoro_status () {
    local pomodoro_start_time=$(read_pomodoro_start_time)
    local current_time=$(get_seconds)
    local difference=$(( ($current_time - $pomodoro_start_time)))

    local remaining= $(( POMODORO_DURATION_MINUTES*60 - $difference ))

    if [ $pomodoro_start_time -eq -1 ]
    then
        echo ""
    elif [ $difference -ge $(( $POMODORO_DURATION_MINUTES*60 + $POMODORO_BREAK_MINUTES*60 )) ]
    then
        pomodoro_start_time=-1
        echo ""
    elif [ $difference -ge $POMODORO_DURATION_MINUTES*60 ]
    then
        echo "[P:✅] "
    else
        printf "Pomodoro Completed: %02d:%02d " $(( difference / 60 )) $(( difference % 60 ))
    fi
}

main () {
    cmd=$1
    shift

    if [ "$cmd" = "start" ]
    then
        pomodoro_start
    elif [ "$cmd" = "cancel" ]
    then
        pomodoro_cancel
    elif [ "$cmd" = "status" ]
    then
        pomodoro_status
    else
        echo "❓ |$cmd|"
    fi
}

main $@
