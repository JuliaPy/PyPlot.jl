#!/usr/bin/env julia
# File: alias.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: more calling signatures
# Created: December 19, 2012

## add plot function
function plot(f::Function, xmin::Real, xmax::Real, args...; kargs...)
    _PLOTPOINTS_ = 100
    x = linspace(float(xmin), float(xmax), _PLOTPOINTS_ + 1)
    y = [f(i) for i in x]
    plot(x, y, args..., kargs...)
end

## fix savefig path problem
function savefig(filename::String, args...; kargs...)
    if filename[1] != '/'
        filename = pwd() + '/' + filename
    end

    args_str = parse_args(args, kargs)

    send("savefig('$filename', $args_str transparent=True)")
end
export savefig

## fix show() namespace conflicting
function showfig(args...; kargs...)
    args_str = parse_args(args, kargs)
    send("show($args_str)")
end
export showfig

## fix close() namespace conflicting
function closefig(args...; kargs...)
    args_str = parse_args(args, kargs)
    send("close($args_str)")
end
export closefig

## fix hist() namespace conflicting
function phist(args...; kargs...)
    args_str = parse_args(args, kargs)
    send("hist($args_str)")
end
export phist

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
