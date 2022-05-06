#!/usr/bin/env bash

# files created by tmux-tempus
PID_FILE=/tmp/tmux_tempus_pid
TIME_FILE=/tmp/tmux_tempus
TMUX_FILE=/tmp/tmux_tempus_bar

#######################################
# Starts a stopwatch from the provided time (from zero if not provided).
# GLOBALS:
#   TIME_FILE
# ARGUMENTS:
#   Time to start the count from, in HH:MM:SS format. It can be left blank.
# OUTPUTS:
#   Writes the time to the file at path TIME_FILE in HH:MM:SS format.
#######################################
sw_from() {
  time="$1"
  hours="$(cut -d':' -f1 <<<"$time" | bc)"
  minutes="$(cut -d':' -f2 <<<"$time" | bc)"
  seconds="$(cut -d':' -f3 <<<"$time" | bc)"
  DATE_INPUT=$((hours * 3600 + minutes * 60 + seconds))
  NOW_TS=$(date '+%s')
  START_TIME=$((NOW_TS - DATE_INPUT))
  DATE_INPUT="--date now-${START_TIME}sec"
  DATE_FORMAT="+%H:%M:%S"
  while [ true ]; do
    STOPWATCH=$(TZ=UTC date $DATE_INPUT $DATE_FORMAT)
    echo $STOPWATCH >$TIME_FILE
    sleep 1
  done
}

#######################################
# Starts a count if none is running or ends a running count.
# GLOBALS:
#   PID_FILE, TIME_FILE, TMUX_FILE
# OUTPUTS:
#   Creates the 3 files if no count is running, or deletes them if a count was
#   running. It also ends the running process if a count was running.
#######################################
start_sequence() {
  if test -f "$TIME_FILE"; then  # A count exists
    if test -f "$PID_FILE"; then # The count is running
      # Kill command and delete PID_FILE
      pidstr=$(head -n 1 $PID_FILE)
      kill $pidstr
      rm -f $PID_FILE
    fi
    # Remove other two files
    rm -f $TIME_FILE $TMUX_FILE
  else # No count is running
    # Start a count from the provided time (from zero if no time provided)
    if [ -z "$2" ]; then
      sw_from 00:00:00 &
    else
      sw_from "$2" &
    fi
    echo $! >$PID_FILE
    echo " ~ " >$TMUX_FILE
  fi
}

#######################################
# Pauses a running count, or continues a paused count. Can also start counts if
# none are running.
# GLOBALS:
#   PID_FILE, TIME_FILE, TMUX_FILE
# OUTPUTS:
#   Modifies the 3 files according to the action performed. If a count is paused,
#   the process is killed.
#######################################
pause_sequence() {
  if test -f "$PID_FILE"; then # A count is running
    # Pause the count
    pidstr=$(head -n 1 $PID_FILE)
    kill $pidstr
    rm -f $PID_FILE
    timestr=$(head -n 1 $TIME_FILE)
    echo " $timestr " >$TMUX_FILE
  else # No count is running
    # Continue or start a count
    timestr=$(head -n 1 $TIME_FILE)
    rm -f $TIME_FILE
    sw_from "${timestr// /}" &
    echo $! >$PID_FILE
    echo " ~ " >$TMUX_FILE
  fi
}

if [ "$1" = "start" ]; then
  start_sequence
elif [ "$1" = "pause" ]; then
  pause_sequence
fi
