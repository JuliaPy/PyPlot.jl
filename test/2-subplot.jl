#!/usr/bin/env julia
# File: 2-subplot.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: subplot

using PyPlot

x = linspace(-pi, pi, 20)
y = sin(x)
cx = [-1 + 0im, 0 + 1im, 1 + 0im]

figure()

subplot(221)
title("Plot without lines")
plot(x, y, 'o')    # don't draw lines

subplot(222)
title("Plot one array")
plot(y)             # plot one array

subplot(223)
title("Plot complex array")
plot(cx)            # plot complex array

subplot(224)
title("Plot function")
plot(cos, -pi, pi)  # plot a function

savefig("2-subplot.png")
