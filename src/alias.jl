#!/usr/bin/env julia
# File: alias.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: more calling signatures
# Created: December 19, 2012

## plot function
function plot(f::Function, xmin::Real, xmax::Real, args...)
    _PLOTPOINTS_ = 100
    x = linspace(float(xmin), float(xmax), _PLOTPOINTS_ + 1)
    y = [f(i) for i in x]
    plot(x, y, args...)
end
export plot
