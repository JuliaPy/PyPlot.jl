#!/usr/bin/env julia
# File: alias.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: more calling signatures
# Created: December 19, 2012

## add plot function
function plot(f::Function, xmin::Real, xmax::Real, args...)
    _PLOTPOINTS_ = 100
    x = linspace(float(xmin), float(xmax), _PLOTPOINTS_ + 1)
    y = [f(i) for i in x]
    plot(x, y, args...)
end

## legend: take string argument as location, not label
legend(loc::String, args...) = legend(:loc, loc, args...)

## fix savefig path problem
function savefig(file::String, args...)
    file = cwd() + '/' + file

    args_str = parse(file)
    for arg in args
        args_str += parse(arg)
    end

    send("savefig($args_str)")
end
export savefig

## fix show() namespace conflicting
function showfig(args...)
    args_str = ""
    for arg in args
        args_str += parse(arg)
    end
    send("show($args_str)")
end
export showfig
