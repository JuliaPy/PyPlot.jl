#!/usr/bin/env julia
# File: 2-subplot.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: subplot
# Created: November 24, 2012

require("pyplot")
using pyplot

x = linspace(-pi, pi, 20)
y = sin(x)
cx = [-1 + 0im, 0 + 1im, 1 + 0im]

figure()

subplot(221)
title("Plot without lines")
grid(true)
plot(x, y, :linestyle, "None", :marker, "o")    # don't draw lines

subplot(222)
title("Plot one array")
grid(true)
plot(y)             # plot one array

subplot(223)
title("Plot complex array")
grid(true)
plot(cx)            # plot complex array

subplot(224)
title("Plot function")
grid(true)
plot(cos, -pi, pi)  # plot a function

#savefig("2-subplot.pdf")
