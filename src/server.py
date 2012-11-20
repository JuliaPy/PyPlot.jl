#!/usr/bin/env python
# File: server.py
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: interprete and evalulate plot commands
# Created: November 20, 2012

## ref
# * http://stackoverflow.com/questions/9977446/connecting-to-a-remote-ipython-instance
# * https://github.com/ivanov/vim-ipython
# * https://github.com/ipython/ipython/blob/master/IPython/frontend/terminal/console/interactiveshell.py


import sys

from IPython.lib.kernel import find_connection_file
from IPython.zmq.blockingkernelmanager import BlockingKernelManager

# TODO: find existing kernel, save info to kerner.info
cf = find_connection_file('76368')
km = BlockingKernelManager()
km.connection_file = cf
km.load_connection_file()
km.start_channels()

# evalutate code
def run_cell(code):
    # now we can run code. This is done on the shell channel
    shell = km.shell_channel
    # execution is immediate and async, returning a UUID
    msg_id = shell.execute(code)
    # get_meg can block for a reply
    reply = shell.get_msg()

    if reply['content']['status'] == 'error':
        print 'Failed to create figure!'
        for line in reply['content']['traceback']:
            print line

def _status():
    run_cell('')

def _figure(fignum = ''):
    cmd = 'figure(' + str(fignum) + ')'
    run_cell(cmd)

def _show(fignum = ''):
    cmd = 'show(' + str(fignum) + ')'
    run_cell(cmd)

def _plot(args):
    pass

def _plotfile(args):
    pass

def _test():
    run_cell('from pylab import *')
    _figure()
    run_cell('plot([1, 2, 3])')
    _show()


import argparse
# syntax: server --cmd CMD --args ARGS
parser = argparse.ArgumentParser()
parser.add_argument('-c', '--cmd', default = '')
parser.add_argument('-a', '--args', default = '')
cmd = parser.parse_args().cmd
args = parser.parse_args().args

if cmd == '':
    _status()
elif cmd == 'status':
    _status()
elif cmd == 'figure':
    _figure()
elif cmd == 'show':
    _show()
elif cmd == 'plot':
    _plot(args)
elif cmd == 'plotfile':
    _plotfile(args)
elif cmd == 'test':
    _test()
