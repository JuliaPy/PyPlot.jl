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

## main plot function
function plot(x::Array, y::Array, args::Tuple)
    # check number of arguments
    if rem(length(args), 2) == 1
        println("SyntaxError: Symbols and parameters not pair")
        return
    end

    # translate x, y
    if length(x) == 0
        cmdea = ""
    else
        cmdea = strcat(to_str(x), ", ")
    end
    if length(y) == 0
        cmdeb = ""
    else
        cmdeb = strcat(to_str(y), ", ")
    end
    cmd = strcat("plot(", cmdea, cmdeb)

    # translate arguments
    for i = 1:2:length(args)
        if isa(args[i], Symbol) == false
            println("SyntaxError: Failed to retrive Symbol")
            return
        end

        if isa(args[i+1], String)
            cmde = strcat(args[i], "=\"", args[i+1], "\"")
        else
            cmde = strcat(args[i], "=", args[i+1])
        end
        cmd = strcat(cmd, cmde, ", ")
    end

    cmd = strcat(cmd, ")")
    mrun(cmd)
end

## plot x, y
## syntax: plot(x, y, :option, parameters)
plot(x::Array, y::Array, args...) = plot(x, y, args)
## plot y
plot(y::Array, args...) = plot([], y, args)
## plot complex x
plot(cx::Array{Complex128}, args...) = plot(real(cx), imag(cx), args)
## plot real function
function plot(f::Function, xmin::Number, xmax::Number, args...)
        x = linspace(xmin, xmax, _PLOTPOINTS_ + 1)
        y = [f(i) for i in x]
        plot(x, y, args)
end

## plot file
function plotfile(f::String, args::Tuple)
    # check number of arguments
    if rem(length(args), 2) == 1
        println("SyntaxError: Symbols and parameters not pair")
        return
    end

    cmd = strcat("plotfile(\"", f, "\"", ", ")

    # translate arguments
    for i = 1:2:length(args)
        if isa(args[i], Symbol) == false
            println("SyntaxError: Failed to retrive Symbol")
            return
        end

        if isa(args[i+1], String)
            cmde = strcat(args[i], "=\"", args[i+1], "\"")
        else
            cmde = strcat(args[i], "=", args[i+1])
        end
        cmd = strcat(cmd, cmde, ", ")
    end

    cmd = strcat(cmd, ")")
    mrun(cmd)
end
plotfile(f::String, args...) = plotfile(f, args)


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

    plot(x, y, :linestyle, "None", :marker, "o", :color, "r")

    cx = [-2.0 + 0.0im, 0.0 + 0.0im, 2.0 + 0.0im]
    plot(cx)

    plotfile("test.dat")
end

end # end module
