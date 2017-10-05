ENV["MPLBACKEND"]="agg" # no GUI

using PyPlot, PyCall

if isdefined(Base, :Test) && !Base.isdeprecated(Base, :Test)
    using Base.Test
else
    using Test
end

plot(1:5, 2:6, "ro-")

line = gca()[:lines][1]
@test line[:get_xdata]() == [1:5;]
@test line[:get_ydata]() == [2:6;]

fig = gcf()
@test isa(fig, PyPlot.Figure)
@test fig[:get_size_inches]() ≈ [6.4, 4.8]

s = stringmime("application/postscript", fig);
m = match(r"%%BoundingBox: *([0-9]+) +([0-9]+) +([0-9]+) +([0-9]+)", s)
@test m !== nothing
boundingbox = map(s -> parse(Int, s), m.captures)
info("got plot bounding box ", boundingbox)
@test all([300, 200] .< boundingbox[3:4] - boundingbox[1:2] .< [450,350])

c = get_cmap("viridis")
a = linspace(0,1,5)
rgba = pycall(pycall(PyPlot.ScalarMappable, PyObject, cmap=c,
                     norm=PyPlot.Normalize01)["to_rgba"], PyArray, a)
@test rgba ≈ [ 0.267004  0.004874  0.329415  1.0
               0.229739  0.322361  0.545706  1.0
               0.127568  0.566949  0.550556  1.0
               0.369214  0.788888  0.382914  1.0
               0.993248  0.906157  0.143936  1.0 ]

