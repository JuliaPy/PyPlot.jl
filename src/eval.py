#!/usr/bin/env python
# File: eval.py
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: evalulate plot commands
# Created: November 20, 2012

## FIXME
# The most suitable solution for this scenario may be starting this script
# as a subprocess and send plot command directly to its STDIN. But I
# cannot find enouth information about open and communicate with a
# persistant subprocess in Julia, and I cann't implement it in Python,
# either. :(

## ref
# * http://stackoverflow.com/questions/9977446/connecting-to-a-remote-ipython-instance
# * https://github.com/ivanov/vim-ipython
# * https://github.com/ipython/ipython/blob/master/IPython/frontend/terminal/console/interactiveshell.py

from sys import argv
from IPython.lib.kernel import find_connection_file
from IPython.zmq.blockingkernelmanager import BlockingKernelManager

# startup channel
pidfile = '/tmp/pyplot-jl-ipython-daemon.pid'
with open(pidfile, 'r') as f:
    cf = f.readline()
# remove trailing carriage-return
cf = cf[:-1]
cf = find_connection_file(cf)
km = BlockingKernelManager()
km.connection_file = cf
km.load_connection_file()
km.start_channels()

# parse commands
code = argv[1]

# execution is immediate and async, returning a UUID
msg_id = km.shell_channel.execute(code)
# get_meg can block for a reply
reply = km.shell_channel.get_msg()

if reply['content']['status'] == 'error':
    for line in reply['content']['traceback']:
        print line
