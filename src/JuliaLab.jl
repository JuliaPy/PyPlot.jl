module JuliaLab
using Base

export mrun, mstatus, mtest, figure, fig, subplot, draw, showfig, plot, plotfile,  xlim, ylim, title, xlabel, ylabel, legend, clearfig, clearax, closefig, delax, hold, savefig, grid, xloc_major, xloc_minor, xloc, yloc_major, yloc_minor, yloc, xformatter_major, xfomatter_minor, xformatter, yformatter_major, yformatter_minor, yformatter, minorticks, xscale, yscale, twinx, twiny, axhline, axvline, axhspan, axvspan

include("/Users/ljunf/Documents/Projects/JuliaLab.jl/src/aux.jl")

## TODO:
# * annotate/figtext, hist
# * portable
# * usage explanation and example in README

server = "/Users/ljunf/Documents/Projects/JuliaLab.jl/src/server.py"
_PLOTPOINTS_ = 100

## convert array to real string
function to_str(xa::Array)
    str = "["
    for x in xa
        str = "$str$x, "
    end
    str = "$str]"
    return str
end

## run matplotlib commands, to adjust figure ditail, like ticks
## TODO: support block parameters
function mrun(cmd::String)
    # using escaped single quoted cmd to
    # avoid confusing system call, ie, shell
    cmd = "$server \'$cmd\'"
    #println(cmd)
    system(cmd)
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
function savefig(file::String)
    mrun("savefig($file)")
end

## main plot function
function plot(x::Array, y::Array, args::Tuple)
    # convert to float

    # check array dimension
    if ndims(x) != 1 || ndims(y) != 1
        println("SyntaxError: input arrays should be of one dimension!")
        return
    # check length of arrays
    elseif size(x, 1) != size(y, 1)
        println("SyntaxError: lengths of input arrays should be equal!")
    end
    # check number of arguments
    if rem(length(args), 2) == 1
        println("SyntaxError: Symbols and parameters should in pair!")
        return
    end

    cmd = "plot("
    # translate x, y
    if length(x) != 0
        cmd = "$cmd$(to_str(x)), "
    end
    cmd = "$cmd$(to_str(y)), "

    # translate arguments
    for i = 1:2:length(args)
        if !isa(args[i], Symbol)
            println("SyntaxError: args should use Symbol!")
            return
        end

        if isa(args[i+1], String)
            cmd = "$cmd $(args[i])=\"$(args[i+1])\", "
        else
            cmd = "$cmd $(args[i])=$(args[i+1]), "
        end
    end

    cmd = "$cmd)"
    mrun(cmd)
end

## plot x,y array
## syntax: plot(x, y, :option, parameters)
plot(x::Array, y::Array, args...) = plot(x, y, args)
## plot y, real or complex
function plot(cx::Array, args...)
    if typeof(cx[1]) <: Real
        plot([1:length(cx)], cx, args)
    elseif typeof(cx[1]) <: Complex
        x = Array(Float64, size(cx, 1))
        y = Array(Float64, size(cx, 1))
        for i in 1:length(x)
            x[i] = real(cx[i])
            y[i] = imag(cx[i])
        end
        plot(x, y, args)
    end
end

## plot a function
function plot(f::Function, xmin::Real, xmax::Real, args...)
        x = linspace(float(xmin), float(xmax), _PLOTPOINTS_ + 1)
        y = [f(i) for i in x]
        plot(x, y, args)
end

## plotfile
function plotfile(f::String, args::Tuple)
    # check number of arguments
    if rem(length(args), 2) == 1
        println("SyntaxError: Symbols and parameters should in pair!")
        return
    end

    cmd = "plotfile(\"$f\", "
    # translate arguments
    for i = 1:2:length(args)
        if isa(args[i], Symbol) == false
            println("SyntaxError: args should use Symbol!")
            return
        end

        if isa(args[i+1], String)
            cmd = "$cmd $(args[i])=\"$(args[i+1])\", "
        else
            cmd = "$cmd $(args[i])=$(args[i+1]), "
        end
    end

    cmd = "$cmd)"
    mrun(cmd)
end
plotfile(f::String, args...) = plotfile(f, args)


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
    if length(labels) == 0
        part1 = ""
    else
        part1 = "("
        for label in labels
            part1 = "$part1\"$label\", "
        end
        part1 = "$part1), "
    end

    if loc == ""
        part2 = ""
    else
        part2 = "loc=\"$loc\""
    end
    cmd = "legend($part1 $part2)"
    mrun(cmd)
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

# draw horizontal/vertical line/rectangle across axes
function axhline(y::Real, xmin::Real, xmax::Real)
    mrun("axhline(y=$y, xmin=$xmin, xmax=$xmax)")
end
function axvline(x::Real, ymin::Real, xmax::Real)
    mrun("axvline(x=$x, ymin=$ymin, ymax=$ymax")
end
function axhspan(xmin::Real, xmax::Real, ymin::Real, ymax::Real)
    mrun("axhspan(xmin, xmax, ymin=$ymin, ymax=$ymax)")
end
function axvspan(xmin::Real, xmax::Real, ymin::Real, ymax::Real)
    mrun("axvspan(xmin, xmax, ymin=$ymin, ymax=$ymax)")
end


## test
function mtest()
    x = linspace(-pi, pi)
    y = sin(x)
    plot(x, y)
    xlim(-2pi, 2pi)
    ylim(-2, 2)
    title(E"$sin(x)$")
    xlabel(E"$x$")
    ylabel(E"$y$")
    legend((E"$sin(x)$", ), "upper left")

    plot(x, y, :linestyle, "None", :marker, "o", :color, "r", :linewidth, 2)

    cx = [-2.0 + 1.0im, 0.0 + 0.0im, 2.0 + -1.0im]
    plot(cx)

    #plotfile("test.dat")
    #plotfile("test.dat", :linewidth, 2, :linestyle, "None")
end

end # end module
