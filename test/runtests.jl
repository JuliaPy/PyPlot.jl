ENV["MPLBACKEND"]="agg" # no GUI

using PyPlot, PyCall, Test

@info("PyPlot is using Matplotlib $(PyPlot.version) with Python $(PyCall.pyversion)")

plot(1:5, 2:6, "ro-")

line = gca().lines[1]
@test line.get_xdata() == [1:5;]
@test line.get_ydata() == [2:6;]

fig = gcf()
@test isa(fig, PyPlot.Figure)
if PyPlot.version >= v"2"
    @test fig.get_size_inches() ≈ [6.4, 4.8]
else # matplotlib 1.3
    @test fig.get_size_inches() ≈ [8, 6]
end

# with Matplotlib 1.3, I get "UserWarning: bbox_inches option for ps backend is not implemented yet"
if PyPlot.version >= v"2"
    s = sprint(show, "application/postscript", fig);
    # m = match(r"%%BoundingBox: *([0-9]+) +([0-9]+) +([0-9]+) +([0-9]+)", s)
    m = match(r"%%BoundingBox: *([0-9]+\.?[0-9]*) +([0-9]+\.?[0-9]*) +([0-9]+\.?[0-9]*) +([0-9]+\.?[0-9]*)", s)
    @test m !== nothing
    boundingbox = map(s -> parse(Float64, s), m.captures)
    @info("got plot bounding box ", boundingbox)
    @test all([300, 200] .< boundingbox[3:4] - boundingbox[1:2] .< [450,350])
end

c = get_cmap("RdBu")
a = 0.0:0.25:1.0
rgba = pycall(pycall(PyPlot.ScalarMappable, PyObject, cmap=c,
                     norm=PyPlot.Normalize01)."to_rgba", PyArray, a)
@test rgba ≈ [  0.403921568627451   0.0                  0.12156862745098039  1.0
                0.8991926182237601  0.5144175317185697   0.4079200307574009   1.0
                0.9657054978854287  0.9672433679354094   0.9680891964628989   1.0
                0.4085351787773935  0.6687427912341408   0.8145328719723184   1.0
                0.0196078431372549  0.18823529411764706  0.3803921568627451   1.0 ]