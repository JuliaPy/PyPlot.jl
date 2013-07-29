#!/usr/bin/env julia
# File: send.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: send python code to ipython

using ZMQ

global daemon
global ctx
global socket

global DEBUG = false

# daemon: ipyton server
function start_daemon()
    global daemon = spawn(`$PYPLOT_JL_HOME/pyplot.py` .> STDERR)
end

function stop_daemon()
    kill(daemon)
end

function restart_daemon()
    stop_daemon()
    start_daemon()
end

## zmq client
function start_socket()
    global ctx = Context(1)
    global socket = Socket(ctx, REQ)
    ZMQ.connect(socket, "ipc:///tmp/PyPlot_jl")
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
function debug(b::Bool)
    global DEBUG = b
end
function debug()
    global DEBUG = !DEBUG
end


## eval / send commands
function send(cmd::String)
    # print cmd that is to be send
    if DEBUG
        println(cmd)
    end

    ZMQ.send(socket, ZMQ.Message(cmd))
    msg = ZMQ.recv(socket)

    # print traceback info
    if msg != ""
        print(msg)
    end
end
