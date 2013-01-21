#!/usr/bin/env python
# File: pyplot.py
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: evalulate plot commands
# Created: November 20, 2012

import zmq
from IPython.lib.kernel import find_connection_file
from IPython.zmq.blockingkernelmanager import BlockingKernelManager


# startup channel
pidfile = '/tmp/ipython.pid'
with open(pidfile, 'r') as f:
    cf = f.readline()
# remove trailing carriage-return
cf = cf[:-1]
try:
    # get real pid of ipython kernel
    cf = str(int(cf) + 1)
    cf = find_connection_file(cf)
except IOError:
    cf = str(int(cf) + 1)
    cf = find_connection_file(cf)
km = BlockingKernelManager()
km.connection_file = cf
km.load_connection_file()
km.start_channels()

def run_code(code):
    # execution is immediate and async, returning a UUID
    msg_id = km.shell_channel.execute(code)
    # get_meg can block for a reply
    reply = km.shell_channel.get_msg()

    if reply['content']['status'] == 'error':
        for line in reply['content']['traceback']:
            print line

# ZMQ server
context = zmq.Context()
socket = context.socket(zmq.REP)
socket.bind("ipc:///tmp/zmq_pyplot")

while True:
    #  Wait for next request from client
    msg = socket.recv()

    #  Send reply back to client
    socket.send("Received!")
    run_code(msg)
