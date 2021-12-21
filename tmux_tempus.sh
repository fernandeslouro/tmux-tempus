#!/usr/bin/env bash

PID_FILE=/tmp/tmux_tempus_pid
TIME_FILE=/tmp/tmux_tempus
TMUX_FILE=/tmp/tmux_tempus_bar


# starts a stopwatch from the provided times (from zero if not provided)
sw_f () {
  time="$1"
  hours="$(cut -d':' -f1 <<<"$time"|bc)"
  minutes="$(cut -d':' -f2 <<<"$time"|bc)"
  seconds="$(cut -d':' -f3 <<<"$time"|bc)"
  DATE_INPUT=$((hours*3600+minutes*60+seconds))
  NOW_TS=$(date '+%s')
  START_TIME=$((NOW_TS-DATE_INPUT))

  DATE_INPUT="--date now-${START_TIME}sec"
  DATE_FORMAT="+%H:%M:%S"
  while [ true ]; do
      STOPWATCH=$(TZ=UTC date $DATE_INPUT $DATE_FORMAT)
      echo $STOPWATCH > $TIME_FILE
      sleep 1
  done
}

if [ "$1" = "start" ]; then
  # starts or ends a count
  if test -f "$TIME_FILE"; then
    if test -f "$PID_FILE"; then
      # running (timer and pid file), we want to kill command and delete files
      pidstr=$(head -n 1 $PID_FILE)
      kill $pidstr
      rm -f $PID_FILE 
    fi
    # if paused (timer and no pid file), we only want to delete these 2 files
    rm -f $TIME_FILE $TMUX_FILE
  else
    # not running (no timer and no pid file), we want to start
    if [ -z "$2" ];then
      sw_f 00:00:00 &
    else
      sw_f "$2" &
    fi
    echo $! > $PID_FILE
    echo " ~ " > $TMUX_FILE
  fi
elif [ "$1" = "pause" ]; then
  # pauses and continues a paused count, can also start counts
  if test -f "$PID_FILE"; then
    # running,we want to pause
    pidstr=$(head -n 1 $PID_FILE)
    kill $pidstr
    rm -f $PID_FILE 
    timestr=$(head -n 1 $TIME_FILE)
    echo " $timestr " > $TMUX_FILE
  else
    # not running, we want to continue or start a count
    timestr=$(head -n 1 $TIME_FILE)
    rm -f $TIME_FILE 
    sw_f "${timestr// /}" &
    echo $! > $PID_FILE
    echo " ~ " > $TMUX_FILE
  fi
fi
