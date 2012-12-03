#!/usr/bin/env julia
# File: pyplot.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: module's main file
# Created: November 29, 2012

module pyplot
using Base

# detect pyplot.jl location
PYPLOT_JL_HOME = ""
for dir in LOAD_PATH
    if isfile(file_path(dir, "pyplot/src/pyplot.jl"))
        PYPLOT_JL_HOME = "$dir/pyplot/src"
        break
    end
end

if PYPLOT_JL_HOME == ""
    println("Failed to detect location of pyplot.jl!")
else
    ## matploblib.pyplot wrapper
    include("$PYPLOT_JL_HOME/plot.jl")
    ## other useful functions
    include("$PYPLOT_JL_HOME/utils.jl")
end

end # end module
