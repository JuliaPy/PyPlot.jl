#!/usr/bin/env julia
# File: aux.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description:
# Created: December 08, 2012

export mrun

# daemon
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
    run(`daemon --name=ipython --restart`)
    run(`daemon --name=pyplot --restart`)
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
    if DEBUG
        println(cmd)
    end
end
