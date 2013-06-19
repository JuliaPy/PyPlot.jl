#!/usr/bin/env python
# File: pyplot.py
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: evalulate plot commands

from IPython.zmq.blockingkernelmanager import BlockingKernelManager
from subprocess import PIPE
import zmq
import sys, signal

# init plot kernel
km = BlockingKernelManager()
km.start_kernel(stdout=PIPE, stderr=PIPE, extra_arguments=['--pylab'])
km.start_channels()

# start ZMQ REP
ctx = zmq.Context()
rep = ctx.socket(zmq.REP)
rep.bind('ipc:///tmp/Pyplot_jl')

# cleanup at exit
def cleanup(signum, fname):
    km.stop_channels()
    km.shutdown_kernel()
    sys.exit()

signal.signal(signal.SIGINT,  cleanup)
signal.signal(signal.SIGQUIT, cleanup)
signal.signal(signal.SIGTERM, cleanup)

# main loop
while True:
    # retrieve request from client
    cmd = rep.recv_string()

    # execution is immediate and async, returning a UUID
    km.shell_channel.execute(cmd)
    # get execute result
    reply = km.shell_channel.get_msg()

    if reply['content']['status'] == 'ok':
        rep.send_unicode('')
    else:
        rep.send_unicode(''.join(reply['content']['traceback']))
