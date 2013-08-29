# Conveniences for working with and displaying matplotlib colormaps,
# integrating with the Julia Colors package

using Color
export ColorMap, get_cmap, register_cmap, get_cmaps

const colorsm = pyimport("matplotlib.colors")
const cm = pyimport("matplotlib.cm")

########################################################################
# Wrapper around colors.Colormap type:

type ColorMap
    o::PyObject
end

PyObject(c::ColorMap) = c.o
convert(::Type{ColorMap}, o::PyObject) = ColorMap(o)
isequal(c::ColorMap, g::ColorMap) = isequal(c.o, g.o)
hash(c::ColorMap) = hash(c.o)

getindex(c::ColorMap, x) = getindex(c.o, x)
setindex!(c::ColorMap, v, x) = setindex!(c.o, v, x)
haskey(c::ColorMap, x) = haskey(c.o, x)
keys(c::ColorMap) = keys(c.o)

pytype_mapping(colorsm["Colormap"], ColorMap)

function show(io::IO, c::ColorMap)
    print(io, "ColorMap \"$(c[:name])\"")
end

########################################################################
# ColorMap constructors via colors.LinearSegmentedColormap

const LinearSegmentedColormap = colorsm["LinearSegmentedColormap"]

# most general constructors using RGB arrays of triples, defined
# as for matplotlib.colors.LinearSegmentedColormap
function ColorMap{T<:Real}(name::String, 
                           r::AbstractVector{(T,T,T)},
                           g::AbstractVector{(T,T,T)},
                           b::AbstractVector{(T,T,T)},
                           n=max(256, length(r), length(g), length(b)),
                           gamma=1.0)
    pycall(LinearSegmentedColormap, ColorMap,
           name, [ "red" => r, "green" => g, "blue" => b ], n, gamma)
end
# as above, but also passing an alpha array
function ColorMap{T<:Real}(name::String, 
                           r::AbstractVector{(T,T,T)},
                           g::AbstractVector{(T,T,T)},
                           b::AbstractVector{(T,T,T)},
                           a::AbstractVector{(T,T,T)},
                           n=max(256, length(r), length(g), length(b)),
                           gamma=1.0)
    pycall(LinearSegmentedColormap, ColorMap,
           name, [ "red" => r, "green" => g, "blue" => b, "alpha" => a ],
           n, gamma)
end


# create from an array c, assuming linear mapping from [0,1] to c
function ColorMap{T<:ColorValue}(name::String, c::AbstractVector{T},
                                 n=max(256, length(c)), gamma=1.0)
    nc = length(c)
    if nc == 0
        throw(ArgumentError("ColorMap requires a non-empty ColorValue array"))
    end
    r = Array((Float64,Float64,Float64), nc)
    g = Array((Float64,Float64,Float64), nc)
    b = Array((Float64,Float64,Float64), nc)
    for i = 1:nc
        rgb = convert(RGB, c[i])
        x = (i-1) / (nc-1)
        r[i] = (x, rgb.r, rgb.r)
        b[i] = (x, rgb.b, rgb.b)
        g[i] = (x, rgb.g, rgb.g)
    end
    ColorMap(name, r,g,b, n, gamma)
end

ColorMap{T<:ColorValue}(c::AbstractVector{T},
                        n=max(256, length(c)), gamma=1.0) =
    ColorMap(string("cm_", hash(c)), c, n, gamma)


########################################################################

const cm_get_cmap = cm["get_cmap"]
const cm_register_cmap = cm["register_cmap"]

get_cmap() = pycall(cm_get_cmap, PyAny)
get_cmap(name::String) = pycall(cm_get_cmap, PyAny, name)
get_cmap(name::String, lut::Integer) = pycall(cm_get_cmap, PyAny, name, lut)
get_cmap(c::ColorMap) = c
ColorMap(name::String) = get_cmap(name)

register_cmap(c::ColorMap) = pycall(cm_register_cmap, PyAny, c)
register_cmap(n::String, c::ColorMap) = pycall(cm_register_cmap, PyAny, n,c)

# convenience function to get array of registered colormaps
get_cmaps() =
    ColorMap[get_cmap(c) for c in
             sort(filter!(c -> !endswith(c, "_r"),
                          String[c for (c,v) in PyDict(PyPlot.cm["datad"])]),
                  by=lowercase)]

########################################################################
# display of ColorMaps as a horizontal color bar in SVG

const ScalarMappable = cm["ScalarMappable"]
const Normalize01 = colorsm[:Normalize](vmin=0,vmax=1)

function writemime(io::IO, ::MIME"image/svg+xml", 
                   cs::AbstractVector{ColorMap})
    n = 256
    nc = length(cs)
    a = linspace(0,1,n)
    namelen = mapreduce(c -> length(c[:name]), max, cs)
    width = 0.5
    height = 5
    pad = 0.5
    write(io,
        """
        <?xml version"1.0" encoding="UTF-8"?>
        <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
         "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
        <svg xmlns="http://www.w3.org/2000/svg" version="1.1"
             width="$(n*width+1+namelen*4)mm" height="$((height+pad)*nc)mm"
             shape-rendering="crispEdges">
        """)
    for j = 1:nc
        c = cs[j]
        y = (j-1) * (height+pad)
        write(io, """<text x="$(n*width+1)mm" y="$(y+3.8)mm" font-size="3mm">$(c[:name])</text>""")
        rgba = pycall(pycall(ScalarMappable, PyObject, cmap=c,
                             norm=Normalize01)["to_rgba"], PyArray, a)
        for i = 1:n
            write(io, """<rect x="$((i-1)*width)mm" y="$(y)mm" width="$(width)mm" height="$(height)mm" fill="#$(hex(RGB(rgba[i,1],rgba[i,2],rgba[i,3])))" stroke="none" />""")
        end
    end
    write(io, "</svg>")
end

writemime(io::IO, m::MIME"image/svg+xml", c::ColorMap) =
    writemime(io, m, [c])

########################################################################
