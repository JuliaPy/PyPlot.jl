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
==(c::ColorMap, g::ColorMap) = c.o == g.o
isequal(c::ColorMap, g::ColorMap) = c.o == g.o # Julia 0.2 compatibility
==(c::PyObject, g::ColorMap) = c == g.o
==(c::ColorMap, g::PyObject) = c.o == g
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
ColorMap{T<:Real}(name::Union(String,Symbol), 
                  r::AbstractVector{(T,T,T)},
                  g::AbstractVector{(T,T,T)},
                  b::AbstractVector{(T,T,T)},
                  n=max(256,length(r),length(g),length(b)), gamma=1.0) =
    ColorMap(name, r,g,b, Array((T,T,T),0), n, gamma)

# as above, but also passing an alpha array
function ColorMap{T<:Real}(name::Union(String,Symbol), 
                           r::AbstractVector{(T,T,T)},
                           g::AbstractVector{(T,T,T)},
                           b::AbstractVector{(T,T,T)},
                           a::AbstractVector{(T,T,T)},
                           n=max(256,length(r),length(g),length(b),length(a)),
                           gamma=1.0)
    segmentdata = [ "red" => r, "green" => g, "blue" => b ]
    if !isempty(a)
        segmentdata["alpha"] = a
    end  
    pycall(LinearSegmentedColormap, ColorMap,
           name, segmentdata, n, gamma)
end

typealias AColorValue Union(ColorValue,AbstractAlphaColorValue)

# create from an array c, assuming linear mapping from [0,1] to c
function ColorMap{T<:AColorValue}(name::Union(String,Symbol),
                                  c::AbstractVector{T},
                                  n=max(256, length(c)), gamma=1.0)
    nc = length(c)
    if nc == 0
        throw(ArgumentError("ColorMap requires a non-empty ColorValue array"))
    end
    r = Array((Float64,Float64,Float64), nc)
    g = similar(r)
    b = similar(r)
    a = T <: AbstractAlphaColorValue ? 
        similar(r) : Array((Float64,Float64,Float64), 0)
    for i = 1:nc
        x = (i-1) / (nc-1)
        if T <: AbstractAlphaColorValue
            rgba = convert(AlphaColorValue{RGB{Float64},Float64}, c[i])
            r[i] = (x, rgba.c.r, rgba.c.r)
            b[i] = (x, rgba.c.b, rgba.c.b)
            g[i] = (x, rgba.c.g, rgba.c.g)
            a[i] = (x, rgba.alpha, rgba.alpha)
        else
            rgb = convert(RGB{Float64}, c[i])
            r[i] = (x, rgb.r, rgb.r)
            b[i] = (x, rgb.b, rgb.b)
            g[i] = (x, rgb.g, rgb.g)
        end
    end
    ColorMap(name, r,g,b,a, n, gamma)
end

ColorMap{T<:AColorValue}(c::AbstractVector{T},
                         n=max(256, length(c)), gamma=1.0) =
    ColorMap(string("cm_", hash(c)), c, n, gamma)

function ColorMap{T<:Real}(name::Union(String,Symbol), c::AbstractMatrix{T},
                           n=max(256, size(c,1)), gamma=1.0)
    if size(c,2) == 3
        return ColorMap(name,
                        [RGB{T}(c[i,1],c[i,2],c[i,3]) for i in 1:size(c,1)],
                        n, gamma)
    elseif size(c,2) == 4
        return ColorMap(name,
                        [AlphaColorValue(RGB{T}(c[i,1],c[i,2],c[i,3]), c[i,4])
                         for i in 1:size(c,1)],
                        n, gamma)
    else
        throw(ArgumentError("color matrix must have 3 or 4 columns"))
    end
end

ColorMap{T<:Real}(c::AbstractMatrix{T}, n=max(256, size(c,1)), gamma=1.0) =
    ColorMap(string("cm_", hash(c)), c, n, gamma)

########################################################################

const cm_get_cmap = cm["get_cmap"]
const cm_register_cmap = cm["register_cmap"]

get_cmap() = pycall(cm_get_cmap, PyAny)
get_cmap(name::Union(String,Symbol)) = pycall(cm_get_cmap, PyAny, name)
get_cmap(name::Union(String,Symbol), lut::Integer) = pycall(cm_get_cmap, PyAny, name, lut)
get_cmap(c::ColorMap) = c
ColorMap(name::Union(String,Symbol)) = get_cmap(name)

register_cmap(c::ColorMap) = pycall(cm_register_cmap, PyAny, c)
register_cmap(n::Union(String,Symbol), c::ColorMap) = pycall(cm_register_cmap, PyAny, n,c)

# convenience function to get array of registered colormaps
get_cmaps() =
    ColorMap[get_cmap(c) for c in
             sort(filter!(c -> !endswith(c, "_r"),
                          String[c for (c,v) in PyDict(PyPlot.cm["datad"])]),
                  by=lowercase)]

########################################################################
# display of ColorMaps as a horizontal color bar in SVG

const ScalarMappable = cm["ScalarMappable"]
const Normalize01 = pycall(colorsm["Normalize"],PyAny,vmin=0,vmax=1)

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
