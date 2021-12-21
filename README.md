# tmux-tempus

A timer for tmux written in bash.

## Why did I make this?

I wanted a timer to track work time, and I wanted it on my tmux bar. Other things I wanted was that the timer was kept hidden while it is counting, only showing the current count when it is stopped. I though this would be ideal for a timer to count work time.

## Usage

This utility has 3 commands:
 - `start` - starts a count if none is running, or ends a count if there is one running
 - `pause` - pauses and resumes a count
 - `start-from` - starts a count from a user-inputted time (e.g. start counting from 02:20:00)

The tmux bar will show the contents of a file with the current count.

![tmux-tempus_overview](https://user-images.githubusercontent.com/29887885/146976213-92706d32-c1be-4297-a1e1-f7c80d7a5731.gif)

## Installation 

1. Clone this repo or save `tmux_tempus.sh` somewhere (e.g. your tmux config directory)
2. Add the following lines to your tmux config, replacing `<start key>`, `<pause key>` and `<start-from key>`, as well as `<tmux_tempus.sh path>`

    `bind <start key> run-shell 'bash <tmux_tempus.sh path> start > /dev/null'\; refresh-client -S`
    
    `bind <pause key> run-shell 'bash <tmux_tempus.sh path> pause > /dev/null'\; refresh-client -S`

    `bind-key <start-from key> command-prompt -p "Start Timer from:" 'run-shell "bash <tmux_tempus.sh path> start '%1' > /dev/null"'\; refresh-client -S`

    I like to use `S`, `g` and `P` as start, pause and start-from keys. That way I can use `<prefix>+S` to start and stop a count, `<prefix>+g` to pause and resume, and `<prefix>+P>` to start a count from a spedific time.

3. Add the timer file to the status bar. The best way is to add the variable `wg_timer` to your tmux config and putting it in your status bar

    `wg_timer="#[reverse]#(tail /tmp/tmux_tempus_bar)#[noreverse]"`

    An example status bar config, including only tmux-tempus, date and time:

    `set -g status-right "$wg_timer %Y-%m-%d %H:%M#"`