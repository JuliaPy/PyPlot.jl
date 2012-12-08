#!/usr/bin/env julia
# File: pyplot.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: module's main file
# Created: November 29, 2012

module pyplot

# get src location
PYPLOT_JL_HOME = dirname(find_in_path("pyplot.jl"))

# load matploblib.pyplot wrapper
load("$PYPLOT_JL_HOME/plot.jl")

# start ipython daemon
try
    run(`daemonize -p /tmp/pyplot-jl-ipython-daemon.pid -l /tmp/pyplot-jl-ipython-daemon.pid /usr/local/bin/ipython kernel --pylab`)
# catch multiple instances exception
catch ex
    #println(ex)
end

end # end module
