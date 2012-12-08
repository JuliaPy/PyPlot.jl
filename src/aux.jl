#!/usr/bin/env julia
# File: aux.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description:
# Created: December 08, 2012


# ipython daemon
pidfile = "/tmp/pyplot-jl-ipython-daemon.pid"
function start_ipython_kernel()
    try
        run(`daemonize -p $pidfile -l $pidfile /usr/local/bin/ipython kernel --pylab`)
    catch ex
        #println(ex)
    end
end

function stop_ipython_kernel()
    try
        pid = 0
        open(pidfile, "r") do file
            pid = readline(file)
        end
        # remove trailing carriage-return
        pid = pid[1:end-1]
        run(`kill $pid`)
    catch ex
        #println(ex)
    end
end

function restart_ipython_kernel()
    stop_ipython_kernel()
    start_ipython_kernel()
end

## test
function test()
    load("$PYPLOT_JL_HOME/../demo/1-plot.jl")
    load("$PYPLOT_JL_HOME/../demo/2-subplot.jl")
    #load("$PYPLOT_JL_HOME/../demo/3-plotfile.jl")
    load("$PYPLOT_JL_HOME/../demo/4-control-details.jl")
end
