#!/usr/bin/env bash 

# Create a tmux session with a window splitted into 4 panes,
# each of which to connect to a raspberry pi via ssh.
# Then a given script might run on all 4 r-pies.

echo '---Start Script---'

rpi_list='
          alarm@192.168.0.X00
          alarm@192.168.0.X01
          alarm@192.168.0.X02
          alarm@192.168.0.X04
	  '
rpi_count=$(wc -w <<< $rpi_list)
rpi_array=($rpi_list)
retry_count=5
sleep_seconds=5

echo 'Checking if session already exist ...'
tmux has-session -t connect4rpi

if [ $? != 0 ]
then
    echo 'Creating the session ...'
    # Split window to 4 panes.
    tmux new-session -s connect4rpi -d
    tmux split-window -h -t connect4rpi:0
    tmux split-window -v -t connect4rpi:0.1
    tmux split-window -v -t connect4rpi:0.0

    for i in $(seq 0 $((rpi_count-1)))
    do
        tmux send-keys -t connect4rpi:0.$i 'ssh ' ${rpi_array[i]} C-m
        #tmux send-keys -t connect4rpi:0.$i 'ls ' C-m
    done

    echo 'Synchronize keys to all panes.'
    tmux setw -t connect4rpi:0 synchronize-panes on
fi
echo 'Attaching the session ...'
tmux attach -t connect4rpi

echo '---End Script---'
