#!/usr/bin/env julia
# File: setup.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: link JuliaLab
# Created: November 23, 2012

cmd = readchomp(`pwd`)
cmd = "ln -shf $cmd/src/JuliaLab.jl $JULIA_HOME/../share/julia/extras/JuliaLab.jl"
system(cmd)
