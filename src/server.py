#!/usr/bin/env python
# File: server.py
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: ipython plot server
# Created: November 20, 2012

## ref
# * http://stackoverflow.com/questions/9977446/connecting-to-a-remote-ipython-instance
# * https://github.com/ivanov/vim-ipython
# * https://github.com/ipython/ipython/blob/master/IPython/frontend/terminal/console/interactiveshell.py

from IPython.lib.kernel import find_connection_file
from IPython.zmq.blockingkernelmanager import BlockingKernelManager

#kernel-74127.json
cf = find_connection_file('74691')
km = BlockingKernelManager()
km.connection_file = cf
km.load_connection_file()
km.start_channels()


def run_cell(km, code):
    # now we can run code. This is done on the shell channel
    shell = km.shell_channel

    # execution is immediate and async, returning a UUID
    msg_id = shell.execute(code)
    # get_meg can block for a reply
    reply = shell.get_msg()

    status = reply['content']['status']
    print reply
    if status == 'ok':
        print 'succeeded!'
    elif status == 'error':
        print 'failed!'
        for line in reply['content']['traceback']:
            print line

run_cell(km, 'a=5')
run_cell(km, 'b=0')
run_cell(km, 'c=a/b')

if __name__ = '__main__':
    # init
    # readinto commands
