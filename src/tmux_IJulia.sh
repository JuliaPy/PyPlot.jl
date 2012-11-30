#!/usr/bin/env bash
# File: tmux_IJulia.sh
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: start tmux session for julia
# Created: November 17, 2012

SESSION_NAME="IJulia"
PYPLOT_JL_HOME=$(dirname $(grealpath $0))

tmux has-session -t $SESSION_NAME 2>/dev/null
if [ "$?" -eq 1 ]; then
    echo "No session found. Creating new one ..."
    tmux new-session -d -s $SESSION_NAME
    tmux send-keys "ipython qtconsole --pylab \
        > $PYPLOT_JL_HOME/kernel.info &" C-m
    tmux send-keys "sleep 5 && clear" C-m
    tmux split-window -v 'julia'
else
    echo "Session found. Attaching ..."
fi

tmux attach -t $SESSION_NAME
