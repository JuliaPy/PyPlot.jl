#!/usr/bin/env julia
# File: send.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: send python code to ipython
# Created: December 19, 2012

# daemon: ipyton, zmq server
function start_daemon()
    if fork() == 0
        run(`daemon --name=ipython $PYPLOT_JL_HOME/ipython.py`)
        sleep(5)
        exec(`daemon --name=pyplot $PYPLOT_JL_HOME/pyplot.py`)
    end
end

function stop_daemon()
    run(`daemon --name=ipython --stop`)
    run(`daemon --name=pyplot --stop`)
end

function restart_daemon()
    stop_daemon()
    start_daemon()
end

## zmq client
require("ZMQ")
using ZMQ

global ctx, socket

function start_socket()
    global ctx = ZMQContext(1)
    global socket = ZMQSocket(ctx, ZMQ_REQ)
    ZMQ.connect(socket, "tcp://localhost:1989")
end

function stop_socket()
    ZMQ.close(socket)
    ZMQ.close(ctx)
end

function restart_socket()
    stop_socket()
    start_socket()
end

## Toggle debug
global DEBUG = false
function debug(b::Bool)
    global DEBUG = b
end
function debug()
    global DEBUG = !DEBUG
end


## send commands to zmq server
function send(cmd::String)
    ZMQ.send(socket, ZMQMessage(cmd))
    msg = ZMQ.recv(socket)
    if DEBUG
        println(cmd)
    end
end

psend = send
export psend
