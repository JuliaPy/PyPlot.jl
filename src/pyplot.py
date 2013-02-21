#!/usr/bin/env python
# File: pyplot.py
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: evalulate plot commands
# Created: November 20, 2012

import subprocess
from IPython.lib.kernel import find_connection_file
from IPython.zmq.blockingkernelmanager import BlockingKernelManager
import zmq
import sys, os, time, signal

pid = str(os.getpid())
pidfile = '/tmp/pyplot.pid'

# ensure one instance
if os.path.isfile(pidfile):
    try:
        f = open(pidfile, 'r')
        old_pid = int(f.readlines()[0])
        os.kill(old_pid, 0)
    # old process is not valid
    except IndexError and OSError:
        old_pid = 0
        f.close()
    else:
        sys.exit()

f = open(pidfile, 'w')
f.write(pid)
f.write('\n')
f.close()

# ipython subprocess
ipy = subprocess.Popen(['/usr/bin/env', 'ipython', 'kernel', '--pylab'])

# startup channel
time.sleep(3) # wait for kernel startup
km = BlockingKernelManager()
km.connection_file = find_connection_file(str(ipy.pid))
km.load_connection_file()
km.start_channels()

# start ZMQ server
context = zmq.Context()
socket = context.socket(zmq.REP)
socket.bind("ipc:///tmp/zmq_pyplot")

# cleanup at exit
def cleanup(signum, fname):
    ipy.terminate()
    os.remove(pidfile)
    sys.exit()

signal.signal(signal.SIGINT,  cleanup)
signal.signal(signal.SIGQUIT, cleanup)
signal.signal(signal.SIGTERM, cleanup)

# main loop
while True:
    #  Wait for next request from client
    cmd = socket.recv()

    #  Send reply back to client
    socket.send("Recieve!")

    # execution is immediate and async, returning a UUID
    msg = km.shell_channel.execute(cmd)
    # get_meg can block for a reply
    reply = km.shell_channel.get_msg()

    if reply['content']['status'] == 'error':
        for line in reply['content']['traceback']:
            print >>sys.stderr, line
