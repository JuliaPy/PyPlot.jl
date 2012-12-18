#!/usr/bin/env julia
# File: pyplot.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: module's main file
# Created: November 29, 2012

module pyplot

DEBUG = false

# get src location
PYPLOT_JL_HOME = dirname(find_in_path("pyplot.jl"))

# comminication between wrapper and pyplot backend
load("$PYPLOT_JL_HOME/aux.jl")
# matploblib.pyplot wrapper
load("$PYPLOT_JL_HOME/wrapper.jl")

# start ipython and pyplot daemon
start_daemon()
# satart socket client
start_socket()

end # end module
