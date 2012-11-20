module JuliaLab
using Base

export status, figure, show, plot, plotfile, test

server = "/Users/ljunf/Documents/Projects/JuliaLab/src/server.py"

function status()
    cmd = strcat(server, " --cmd status")
    system(cmd)
end

# TODO: add optional arguemnt, fignum
function figure()
    cmd = strcat(server, " --cmd figure")
    system(cmd)
end

# TODO: add optional argument, fignum
function show()
    cmd = strcat(server, " --cmd show")
    system(cmd)
end

function plot()
end

function plotfile()
end

function test()
    cmd = strcat(server, " --cmd test")
    system(cmd)
end

end # end module
