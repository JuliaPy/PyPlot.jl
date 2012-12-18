#!/usr/bin/env julia
# File: aux.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description:
# Created: December 08, 2012

## start pyplot backend
function start_pyplot()
    # start ipython kernel and ZMQ server
    if fork() == 0
        exec(`daemon --name=pyplot_exec $PYPLOT_JL_HOME/exec.py`)
    end
end

function stop_pyplot()
    run(`daemon --name-pyplot_exec --stop`)
end

function restart_pyplot()
    run(`daemon --name-pyplot_exec --restart`)
end

## send matplotlib code
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

## send commands
function mrun(cmd::String)
    ZMQ.send(socket, ZMQMessage(cmd))
    msg = ZMQ.recv(socket)
    Nothing
end
