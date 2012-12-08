#!/usr/bin/env julia
# File: aux.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description:
# Created: December 08, 2012


# ipython daemon
pidfile_ipython = "/tmp/pyplot-jl-ipython-daemon.pid"
pidfile_eval = "/tmp/pyplot-jl-eval-daemon.pid"
function start_deamon()
    # start ipython kernel
    try
        run(`daemonize -p $pidfile_ipython -l $pidfile_ipython /usr/local/bin/ipython kernel --pylab`)
    catch ex
        Nothing
        #println(ex)
    end
    # start listening server
    try
        run(`daemonize -p $pidfile_eval -l $pidfile_eval $PYPLOT_JL_HOME/eval.py`)
    catch ex
        Nothing
    end
end

function stop_deamon()
    # stop ipython kernel
    try
        pid = 0
        open(pidfile_ipython, "r") do file
            pid = readline(file)
        end
        # remove trailing carriage-return
        pid = pid[1:end-1]
        run(`kill $pid`)
    catch ex
        Nothing
        #println(ex)
    end
    # stop listening server
    try
        pid = 0
        open(pidfile_eval, "r") do file
            pid = readline(file)
        end
        pid = pid[1:end-1]
        run(`kill $pid`)
    catch
        Nothing
    end
end

function restart_deamon()
    stop_daemon()
    start_deamon()
end

## test
function test()
    load("$PYPLOT_JL_HOME/../demo/1-plot.jl")
    load("$PYPLOT_JL_HOME/../demo/2-subplot.jl")
    #load("$PYPLOT_JL_HOME/../demo/3-plotfile.jl")
    load("$PYPLOT_JL_HOME/../demo/4-control-details.jl")
end
