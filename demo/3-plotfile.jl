#!/usr/bin/env julia
# File: 3-plotfile.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: plot file
# Created: November 24, 2012

require("pyplot")
using pyplot

figure()
plotfile("3-plotfile.txt", :delimiter, " ", :cols, (0, 1), :marker, "^")
title("Plot data from file")

#savefig("3-plotfile.pdf")
