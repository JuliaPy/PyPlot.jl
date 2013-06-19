#!/usr/bin/env julia
# File: 3-plotfile.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: plot file

using Pyplot

figure()
plotfile("3-plotfile.txt", delimiter=" ", cols=(0, 1))
title("Plot data from file")

savefig("3-plotfile.png")
