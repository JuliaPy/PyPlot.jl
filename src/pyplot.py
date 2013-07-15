#!/usr/bin/env python
# File: pyplot.py
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: evalulate plot commands

import zmq

# 1.0 introduced KernelManager
try:
    from IPython.kernel import KernelManager
except ImportError:
    # Backwards compatability for versions < 1.0
    from IPython.zmq.blockingkernelmanager import BlockingKernelManager as KernelManager

from subprocess import PIPE
import sys, signal

# init plot kernel
km = KernelManager()
km.start_kernel(stdout=PIPE, stderr=PIPE, extra_arguments=['--pylab'])
try:
    kc = km.client()
except AttributeError:
    # Backwards compatability for versions < 1.0
    kc = km
kc.start_channels()

# start ZMQ REP
ctx = zmq.Context()
rep = ctx.socket(zmq.REP)
rep.bind('ipc:///tmp/PyPlot_jl')

# cleanup at exit
def cleanup(signum, fname):
    kc.stop_channels()
    km.shutdown_kernel()
    sys.exit()

signal.signal(signal.SIGINT,  cleanup)
signal.signal(signal.SIGQUIT, cleanup)
signal.signal(signal.SIGTERM, cleanup)

# main loop
while True:
    # retrieve request from client
    cmd = rep.recv_unicode()

    # execution is immediate and async, returning a UUID
    kc.shell_channel.execute(cmd)
    # get execute result
    reply = kc.shell_channel.get_msg()

    if reply['content']['status'] == 'ok':
        rep.send_unicode('')
    else:
        rep.send_unicode(''.join(reply['content']['traceback']))
