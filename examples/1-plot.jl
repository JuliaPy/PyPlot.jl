#!/usr/bin/env julia
# File: 1-plot.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: simple plot
# Created: November 24, 2012

require("pyplot")
using pyplot

x = linspace(-pi, pi)

figure()
plot(x, sin(x), :label, E"$sin(x)$")
xlim(-2pi, 2pi)     # set xrange
ylim(-2, 2)         # set yrange
title(E"$sin(x)$")
xlabel(E"$x$")
ylabel(E"$y$")
legend()            # show legend
grid(true)              # show grid

#savefig("1-plot.pdf")
