#!/usr/bin/env julia
# File: Pyplot.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: module's main file

module Pyplot


# get src location
PYPLOT_JL_HOME = Pkg.dir("pyplot", "src")

# relative include
include("aux.jl")
include("parse.jl")
include("funcs.jl")
include("wrap.jl")
include("alias.jl")

# start
start_daemon()
start_socket()

# release resouces when exit
atexit(Pyplot.stop_daemon)
atexit(Pyplot.stop_socket)

end # end module
