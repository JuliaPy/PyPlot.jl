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

## check server status
function status()
    cmd = strcat(server, " --cmd status")
    system(cmd)
end

# TODO: add optional arguemnt, fignum
## create/activate figure
function figure()
    cmd = strcat(server, " --cmd figure")
    system(cmd)
end

# TODO: add optional argument, fignum
## show figure
function show()
    cmd = strcat(server, " --cmd show")
    system(cmd)
end

## plot x, y
function plot(x::Array, y::Array, plottype::String)
    cmd = strcat(server, " --cmd plot", " --args " , "\"", to_str(x), ", ", to_str(y), ", ", plottype, "\"")
    system(cmd)
end
plot(x::Array, y::Array) = plot(x, y, "")

## plot y
function plot(y::Array, plottype::String)
    cmd = strcat(server, " --cmd plot", " --args " , "\"", to_str(y), ", ", plottype, "\"")
    system(cmd)
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
function plotfile(f::String, plotstyle::String)
    cmd = strcat(server, " --cmd plotfile", " --args ", f, ", ", plottype)
    system(cmd)
end
plotfile(f::String) = plot(f, "")

## TODO: allow block as parameters
## run matplotlib commands, to adjust such as title, formatter, tics
function mrun(cmd::String)
    if cmd == ""
        return
    else
        cmd = strcat(server, " --cmd mrun", " --args ", "\"", cmd, "\"")
        system(cmd)
    end
end

## test
function test()
    cmd = strcat(server, " --cmd test")
    system(cmd)
end

end # end module
