#!/usr/bin/env julia
# File: test.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: test files for module pyplot
# Created: Apr 13, 2013


using pyplot

x = linspace(-pi, pi)

figure()
plot(x, sin(x), :label, E"$sin(x)$")
grid()
xlim(-2pi, 2pi)     # set xrange
ylim(-2, 2)         # set yrange
title(E"$sin(x)$")
xlabel(E"$x$")
ylabel(E"$y$")
legend()            # show legend

