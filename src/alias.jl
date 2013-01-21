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
    file = pwd() + '/' + file

    args_str = parse(file)
    for arg in args
        args_str += parse(arg)
    end

    send("savefig($args_str transparent=True)")
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

## set locators
function xloc_major(loc::Real)
    send("gca().xaxis.set_major_locator(MultipleLocator($loc))")
    send("draw()")
end

function xloc_minor(loc::Real)
    send("gca().xaxis.set_minor_locator(MultipleLocator($loc))")
    send("draw()")
end

xloc(loc::Real) = xloc_major(loc)

function yloc_major(loc::Real)
    send("gca().yaxis.set_major_locator(MultipleLocator($loc))")
    send("draw()")
end

function yloc_minor(loc::Real)
    send("gca().yaxis.set_minor_locator(MultipleLocator($loc))")
    send("draw()")
end

yloc(loc::Real) = yloc_major(loc)

export xloc_major, xloc_minor, xloc, yloc_major, yloc_minor, yloc

## set formatter
function xformatter_major(formatter::String)
    send("gca().xaxis.set_major_formatter(FormatStrFormatter(\"$formatter\"))")
    send("draw()")
end

function xformatter_minor(formatter::String)
    send("gca().xaxis.set_minor_formatter(FormatStrFormatter(\"$formatter\"))")
    send("draw()")
end

xformatter(formatter::String) = xformatter_major(formatter)

function yformatter_major(formatter::String)
    send("gca().yaxis.set_major_formatter(FormatStrFormatter(\"$formatter\"))")
    send("draw()")
end

function yformatter_minor(formatter::String)
    send("gca().yaxis.set_minor_formatter(FormatStrFormatter(\"$formatter\"))")
    send("draw()")
end

yformatter(formatter::String) = yformatter_major(formatter)

export xformatter_major, xformatter_minor, xformatter, yformatter_major, yformatter_minor, yformatter
