module JuliaLab
using Base

export status, figure, show, plot, plotfile, mrun, test

server = "/Users/ljunf/Documents/Projects/JuliaLab/src/server.py"

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

## run matplotlib commands, to adjust such as title, formatter, tics
## TODO: support block parameters
## TODO: support for multiline
function mrun(cmd::String)
    cmd = strcat(server, " ", "\"", cmd, "\"")
    system(cmd)
end

## check server status
function status()
    mrun("")
end

# TODO: add optional arguemnt, fignum
## create/activate figure
function figure()
    mrun("figure()")
end

# TODO: add optional argument, fignum
## show figure
function show()
    mrun("show()")
end

## plot x, y
function plot(x::Array, y::Array, plottype::String)
    cmd = strcat("plot(", to_str(x), ", ", to_str(y), ", ", plottype, ")")
    mrun(cmd)
end
plot(x::Array, y::Array) = plot(x, y, "")

## plot y
function plot(y::Array, plottype::String)
    cmd = strcat("plot(", to_str(y), ", ", plottype, ")")
    run(cmd)
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
    cmd = strcat("plotfile(", "'", f, "'", ", ", plottype, ")")
    mrun(cmd)
end
plotfile(f::String) = plotfile(f, "")

## test
function test()
    x = linspace(-pi, pi)
    y = sin(x)
    figure()
    plot(x, y)
    show()
    figure()
    plot(x, y, "linestyle = 'None', marker = 'o'")
    show()

    cx = [1.0 + 1.0im, 2.0 + 2.0im, 3.0 + 3.0im]
    figure()
    plot(cx)
    show()

    open("tmp.dat", "w") do file
        for i = 1:10
            println(file, i, "\t", i)
        end
    end
    figure()
    plotfile("tmp.dat")
    show()
end

end # end module
