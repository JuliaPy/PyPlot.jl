#!/usr/bin/env julia
# File: pyplot.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: module's main file
# Created: November 29, 2012

module pyplot

# get src location
PYPLOT_JL_HOME = "$(Pkg.dir())/pyplot/src"

include("send.jl")
include("parse.jl")
include("funcs.jl")
include("wrap.jl")
include("alias.jl")

# start ipython and zmq server
start_daemon()
# start zmq client
start_socket()
end # end module
