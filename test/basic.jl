#!/usr/bin/env julia
# File: basic.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: test pyplot.jl, basic plot
# Created: Apr 29, 2013

x = linspace(-pi, pi)

figure("basic")
plot(x, sin(x), label = "\$sin(x)\$")
grid()
xlim(-2pi, 2pi)     # set xrange
ylim(-2, 2)         # set yrange
title("\$sin(x)\$")
xlabel("\$x\$")
ylabel("\$y\$")
legend()            # show legend
# source_path() wil probably detect the source path
savefig("basic.pdf")
