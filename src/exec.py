#!/usr/bin/env python
# File: eval.py
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: evalulate python commands
# Created: November 20, 2012

import sys
import zmq
import time
from pylab import *
ion()       # turn interactive mode on

DEBUG = True

## start socket
context = zmq.Context()
socket = context.socket(zmq.REP)
socket.bind("tcp://*:1989")

while True:
    #  Wait for next request from client
    msg = socket.recv()
    #  Send reply back to client
    socket.send("Received!")

    if DEBUG:
        print msg

    exec msg
