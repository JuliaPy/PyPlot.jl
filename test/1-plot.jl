#!/usr/bin/env julia
# File: 1-plot.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: simple plot

using PyPlot

x = linspace(-pi, pi)

figure()
plot(x, sin(x), label="\$sin(x)\$")
grid()
xlim(-2pi, 2pi)     # set xrange
ylim(-2, 2)         # set yrange
title("\$sin(x)\$")
xlabel("\$x\$")
ylabel("\$y\$")
legend()            # show legend

savefig("1-plot.png")
