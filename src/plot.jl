#!/usr/bin/env julia
# File: plot.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: real wrapper
# Created: November 29, 2012

export
    # util
    mrun, mstatus,
    # manipulate figure/axes
    figure, fig, subplot, draw, showfig, clearfig, clearax, closefig, delax, hold, savefig,
    # plot data
    plot, plotfile,
    # minipulate details
    xlim, ylim, title, xlabel, ylabel, legend, grid, xloc_major, xloc_minor, xloc, yloc_major, yloc_minor, yloc, xformatter_major, xfomatter_minor, xformatter, yformatter_major, yformatter_minor, yformatter, minorticks, ticklabel_format, tick_params,
    # axes
    xscale, yscale, twinx, twiny,
    # other
    axhline, axvline, axhspan, axvspan

import Base.+
## concatenate strings
function +(a::String, b::Any)
    return strcat(a, string(b))
end

## parse string
function parse(str::String)
    if str == ""
        return ""
    else
        return "\"$str\", "
    end
end

## parse Symbol
function parse(sym::Symbol)
    return string(sym) + "="
end

## parse everything else
function parse(i::Any)
    return string(i) + ", "
end

## parse Array
function parse(arr::Array)
    # return empty string when array is empty
    if arr == []
        return ""
    else
        # generate warning when plot complex arrays
        if eltype(arr) <: Complex
            println("ComplexWarning: Casting complex values to real discards the imaginary part!")
        end

        str = "["
        for a in arr
            str += parse(real(a))
        end
        return str + "], "
    end
end

## parse Tuple
function parse(tuple::Tuple)
    # return empty string when tuple is empty
    if tuple == ()
        return ""
    else
        str = "("
        for t in tuple
            str += parse(t)
        end
        return str + "), "
    end
end

## Toggle debug mode
global DEBUG = false
function debug(state::Bool)
    global DEBUG = state
end
function debug()
    global DEBUG = !DEBUG
end

## send matplotlib code
require("ZMQ")
using ZMQ

global ctx, socket
function start_socket()
    global ctx = ZMQContext(1)
    global socket = ZMQSocket(ctx, ZMQ_REQ)
    ZMQ.connect(socket, "tcp://localhost:1989")
end
function stop_socket()
    ZMQ.close(socket)
    ZMQ.close(ctx)
end
function restart_socket()
    stop_socket()
    start_socket()
end

function mrun(cmd::String)
    ZMQ.send(socket, ZMQMessage(cmd))
    msg = ZMQ.recv(socket)
    if DEBUG
        println("Running code:", cmd)
        out = convert(IOStream, msg)
        println(takebuf_string(out))
    end
end


## check server status
function mstatus()
    mrun("")
end

## create/activate figure
function figure()
    mrun("figure()")
end
function figure(num::Integer)
    mrun("figure($num)")
end
fig = figure

## subplot
function subplot(num::Integer)
    mrun("subplot($num)")
end
function subplot(numRows::Integer, numCols::Integer, plotNum::Integer)
    mrun("subplot($numRows, $numCols, $plotNum)")
end

## show figure
function showfig()
    mrun("show()")
end
function showfig(num::Integer)
    mrun("show($num)")
end

## clear figure
function clearfig()
    mrun("clf()")
end

## clear axes
function clearax()
    mrun("cla()")
end

## close figure
function closefig()
    mrun("close()")
end
function closefig(num::Integer)
    mrun("close($num)")
end

## delete axes
function delax()
    mrun("delaxes()")
end

## toggle hold state
function hold(state::Bool)
    if state == true
        mrun("hold(True)")
    else
        mrun("hold(False)")
    end
end
function hold()
    mrun("hold()")
end


## redraw figure
function draw()
    mrun("draw()")
end

## save figure
function savefig(file::String, args...)
    args_str = ""
    for arg in args
        args_str += parse(arg)
    end
    mrun("savefig(\"$(cwd())/$file\", $args_str)")
end

## plot arrays
function plot(A::Array, args...)
    cmd = parse(A)
    for arg in args
        cmd += parse(arg)
    end
    mrun("plot($cmd)")
end

## plot a function
function plot(f::Function, xmin::Real, xmax::Real, args...)
    _PLOTPOINTS_ = 100
    x = linspace(float(xmin), float(xmax), _PLOTPOINTS_ + 1)
    y = [f(i) for i in x]
    plot(x, y, args)
end

## plotfile
function plotfile(args...)
    cmd = ""
    for arg in args
        cmd += parse(arg)
    end
    mrun("plotfile($cmd)")
end


## set xlim
function xlim(xmin::Real, xmax::Real)
    mrun("xlim($xmin, $xmax)")
end

## set ylim
function ylim(ymin::Real, ymax::Real)
    mrun("ylim($ymin, $ymax)")
end

## set title
function title(s::String)
    mrun("title(\"$s\")")
end

## set xlabel
function xlabel(s::String)
    mrun("xlabel(\"$s\")")
end

## set ylabel
function ylabel(s::String)
    mrun("ylabel(\"$s\")")
end

## set/show legend
function legend(labels::Tuple, loc::String)
    labels = parse(labels)
    if loc == ""
        loc = ""
    else
        loc = "loc=$(parse(loc))"
    end
    mrun("legend($labels$loc)")
end
legend(loc::String) = legend((), loc)
legend(labels::Tuple) = legend(labels, "")
legend() = legend((), "")

## turn grid on/off
function grid(b::Bool)
    if b == true
        mrun("grid(True)")
    else
        mrun("grid(False)")
    end
end
function grid()
    mrun("grid()")
end

## set axis locator
function xloc_major(loc::Real)
    mrun("gca().xaxis.set_major_locator(MultipleLocator($loc))")
    mrun("draw()")
end
function xloc_minor(loc::Real)
    mrun("gca().xaxis.set_minor_locator(MultipleLocator($loc))")
    mrun("draw()")
end
xloc(loc::Real) = xloc_major(loc)
function yloc_major(loc::Real)
    mrun("gca().yaxis.set_major_locator(MultipleLocator($loc))")
    mrun("draw()")
end
function yloc_minor(loc::Real)
    mrun("gca().yaxis.set_minor_locator(MultipleLocator($loc))")
    mrun("draw()")
end
yloc(loc::Real) = yloc_major(loc)

## set axis formatter
function xformatter_major(formatter::String)
    mrun("gca().xaxis.set_major_formatter(FormatStrFormatter(\"$formatter\"))")
    mrun("draw()")
end
function xformatter_minor(formatter::String)
    mrun("gca().xaxis.set_minor_formatter(FormatStrFormatter(\"$formatter\"))")
    mrun("draw()")
end
xformatter(formatter::String) = xformatter_major(formatter)
function yformatter_major(formatter::String)
    mrun("gca().yaxis.set_major_formatter(FormatStrFormatter(\"$formatter\"))")
    mrun("draw()")
end
function yformatter_minor(formatter::String)
    mrun("gca().yaxis.set_minor_formatter(FormatStrFormatter(\"$formatter\"))")
    mrun("draw()")
end
yformatter(formatter::String) = yformatter_major(formatter)

## True on/off minorticks
function minorticks(state::Bool)
    if state == true
        mrun("minorticks_on()")
    else
        mrun("minorticks_off()")
    end
end

## Change appearance of ticks and tick labels
function tick_params(args...)
    cmd = ""
    for i in args
        cmd = "$cmd$(parse(i))"
    end
    mrun("tick_params($cmd)")
end

## Change label format
function ticklabel_format(args...)
    cmd = ""
    for i in args
        cmd += parse(i)
    end
    mrun("ticklabel_format($cmd)")
end

## set axis scale
function xscale(scaletype::String)
    mrun("xscale(\"$scaletype\")")
end
function yscale(scaletype::String)
    mrun("yscale(\"$scaletype\")")
end

## twin x/y
function twinx()
    mrun("twinx()")
end
function twiny()
    mrun("twiny()")
end

## draw horizontal/vertical line/rectangle across axes
function axhline(y::Real, xmin::Real, xmax::Real, args::Tuple)
    opt = ""
    for arg in args
        opt += parse(arg)
    end
    mrun("axhline($y, xmin=$xmin, xmax=$xmax, $opt)")
end
axhline(y::Real, xmin::Real, xmax::Real, args...) = axhline(y, xmin, xmax, args)
axhline(y::Real, args...) = axhline(y, 0.0, 1.0, args)

function axvline(x::Real, ymin::Real, ymax::Real, args::Tuple)
    opt = ""
    for arg in args
        opt += parse(arg)
    end
    mrun("axvline($x, ymin=$ymin, ymax=$ymax, $opt)")
end
axvline(x::Real, ymin::Real, ymax::Real, args...) = axvline(x, ymin, ymax, args)
axvline(x::Real, args...) = axvline(x, 0.0, 1.0, args)

function axhspan(ymin::Real, ymax::Real, xmin::Real, xmax::Real, args::Tuple)
    opt = ""
    for arg in args
        opt += parse(arg)
    end
    mrun("axhspan($ymin, $ymax, xmin=$xmin, xmax=$xmax, $opt)")
end
axhspan(ymin::Real, ymax::Real, xmin::Real, xmax::Real, args...) = axhspan(ymin, ymax, xmin, xmax, args)
axhspan(ymin::Real, ymax::Real, args...) = axhspan(ymin, ymax, 0.0, 1.0, args)

function axvspan(xmin::Real, xmax::Real, ymin::Real, ymax::Real, args::Tuple)
    opt = ""
    for arg in args
        opt += parse(arg)
    end
    mrun("axvspan($xmin, $xmax, ymin=$ymin, ymax=$ymax, $opt)")
end
axvspan(xmin::Real, xmax::Real, ymin::Real, ymax::Real, args...) = axvspan(xmin, xmax, ymin, ymax, args)
axvspan(xmin::Real, xmax::Real, args...) = axvspan(xmin, xmax, 0.0, 1.0, args)
