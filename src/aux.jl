#!/usr/bin/env julia
# File: send.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: send python code to ipython
# Created: December 19, 2012

using ZMQ

pidfile = "/tmp/pyplot.pid"

# daemon: ipyton server
function start_daemon()
    spawn(`$PYPLOT_JL_HOME/pyplot.py`)
    start_socket()
end

function stop_daemon()
    try
        pid = readchomp(`cat $pidfile`)
        run(`kill -2 $pid`)
    catch ErrorException
        Nothing
    end
    stop_socket()
end

function restart_daemon()
    stop_daemon()
    start_daemon()
end

## zmq client
function start_socket()
    global ctx = ZMQContext(1)
    global socket = ZMQSocket(ctx, ZMQ_REQ)
    ZMQ.connect(socket, "ipc:///tmp/zmq_pyplot")
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


## eval / send commands
function send(cmd::String)
    ZMQ.send(socket, ZMQMessage(cmd))
    msg = ZMQ.recv(socket)
    if DEBUG
        println(cmd)
    end
end
