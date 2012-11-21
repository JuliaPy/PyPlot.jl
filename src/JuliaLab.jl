module JuliaLab
using Base

export status, test, figure, mshow, plot, plotfile, mrun, xlim, ylim, title, xlabel, ylabel, close, savefig

server = "/Users/ljunf/Documents/Projects/JuliaLab.jl/src/server.py"
_PLOTPOINTS_ = 100

## convert array to real string
function to_str(xa::Array)
    str = "["
    for x in xa
        str = strcat(str, string(x), ", ")
    end
    str = strcat(str, "]")
    return str
end

## run matplotlib commands, to adjust figure ditail, like ticks
## TODO: support block parameters
function mrun(cmd::String)
    cmd = strcat(server, " \'", cmd, "\'")
    println(cmd)
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
    cmd = strcat("figure(", num, ")")
    mrun(cmd)
end

## show figure
function mshow()
    mrun("show()")
end
function mshow(num::Integer)
    cmd = strcat("show(", num, ")")
    mrun(cmd)
end

## close figure
function close()
    mrun("close()")
end
function close(num::Integer)
    cmd = strcat("close(", num, ")")
    mrun(cmd)
end

## save figure
function savefig(s::String)
    cmd = strcat("savefig(\"", s, "\")")
    mrun(cmd)
end

## plot x, y
## TODO: using option parameters to provide more direct control options,
## like linestyle, marker, linewidth ...
function plot(x::Array, y::Array, plottype::String)
    cmd = strcat("plot(", to_str(x), ", ", to_str(y), ", ", plottype, ")")
    mrun(cmd)
end
plot(x::Array, y::Array) = plot(x, y, "")

## plot y
function plot(y::Array, plottype::String)
    cmd = strcat("plot(", to_str(y), ", ", plottype, ")")
    mrun(cmd)
end
plot(y::Array) = plot(y, "")

## plot complex y
function plot(cx::Array{Complex128}, plottype::String)
    x = real(cx)
    y = imag(cx)
    plot(x, y, plottype)
end
plot(cx::Array{Complex128}) = plot(cx, "")


## plot function
function plot(f::Function, xmin::Number, xmax::Number, plottype::String)
        x = linspace(xmin, xmax, _PLOTPOINTS_ + 1)
        y = [f(i) for i in x]
        plot(x, y, plottype)
end
plot(f::Function, xmin::Number, xmax::Number) = plot(f, xmin, xmax, "")


## plot file
function plotfile(f::String, plottype::String)
    cmd = strcat("plotfile(\"", f, "\"", ", ", plottype, ")")
    mrun(cmd)
end
plotfile(f::String) = plotfile(f, "")


## set xlim
function xlim(xmin::Number, xmax::Number)
    cmd = strcat("xlim(", xmin, ", ", xmax, ")")
    mrun(cmd)
end

## set ylim
function ylim(ymin::Number, ymax::Number)
    cmd = strcat("ylim(", ymin, ", ", ymax, ")")
    mrun(cmd)
end

## set title
function title(s::String)
    cmd = strcat("title(\"", s, "\")")
    mrun(cmd)
end

## set xlabel
function xlabel(s::String)
    cmd = strcat("xlabel(\"", s, "\")")
    mrun(cmd)
end

## set ylabel
function ylabel(s::String)
    cmd = strcat("ylabel(\"", s, "\")")
    mrun(cmd)
end

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

    plot(x, y, "linestyle = \"None\", marker = \"o\"")

    cx = [1.0 + 1.0im, 2.0 + 2.0im, 3.0 + 3.0im]
    plot(cx)

    plotfile("test.dat")
end

end # end module
