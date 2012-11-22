module JuliaLab
using Base

export mrun, status, test, figure, fig, showfig, plot, plotfile,  xlim, ylim, title, xlabel, ylabel, legend, clearfig, closefig, savefig

## TODO: xticks, yticks, formatter, subplot

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
    ## single quote cmd to avoid confusing system call, ie, shell
    cmd = "$server \'$cmd\'"
    #println(cmd)
    system(cmd)
end

## check server status
function status()
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

## close figure
function closefig()
    mrun("close()")
end
function closefig(num::Integer)
    mrun("close($num)")
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

## plot x, y
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

## plot real function
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

## legend
function legend(labels::Tuple, loc::String)
    if length(labels) == 0
        cmd = "legend(\"$loc\")"
    else
        cmd = "("
        for label in labels
            cmd = "$cmd\"$label\", "
        end
        cmd = "$cmd)"
        cmd = "legend($cmd, loc=\"$loc\""
    end
    cmd = "$cmd)"
    mrun(cmd)
end
legend(loc::String) = legend((), loc)
legend() = legend((), "")

## test
function test()
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
