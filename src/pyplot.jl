#!/usr/bin/env julia
# File: pyplot.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: module's main file
# Created: November 29, 2012

module pyplot


# get src location
PYPLOT_JL_HOME = Pkg.dir("pyplot", "src")

# relative include
include("send.jl")
include("parse.jl")
include("funcs.jl")
include("wrap.jl")
include("alias.jl")

# start
start_daemon()


end # end module

# release resouces when exit
atexit(pyplot.stop_daemon)
