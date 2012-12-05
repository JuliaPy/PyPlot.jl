#!/usr/bin/env julia
# File: 4-control-details.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: example to show how to control details in figure
# Created: November 24, 2012

require("pyplot")
using pyplot

x = linspace(-pi, pi)
y = cos(x)
x = x / 1.0e4

figure()
plot(x, y)
grid()
title("Example to show how to control details in figure")
xloc(0.0002)            # set x axis (major) ticks
xloc_minor(0.0001)      # set x axis minor ticks
ticklabel_format(:scilimits, (2, 2))     # set scientific limit

#savefig("4-control-details.pdf")
