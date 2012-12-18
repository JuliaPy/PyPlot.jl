#!/usr/bin/env julia
# File: aux.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description:
# Created: December 08, 2012


# ipython daemon
function start_daemon()
    if fork() == 0
        run(`daemon --name=ipython $PYPLOT_JL_HOME/ipython.py`)
        sleep(5)
        exec(`daemon --name=pyplot $PYPLOT_JL_HOME/eval.py`)
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

## test
function test()
    load("$PYPLOT_JL_HOME/../demo/1-plot.jl")
    load("$PYPLOT_JL_HOME/../demo/2-subplot.jl")
    #load("$PYPLOT_JL_HOME/../demo/3-plotfile.jl")
    load("$PYPLOT_JL_HOME/../demo/4-control-details.jl")
end
