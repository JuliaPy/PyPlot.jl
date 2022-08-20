# Conveniences for working with and displaying matplotlib colormaps,
# integrating with the Julia Colors package

using Colors
export ColorMap, get_cmap, register_cmap, get_cmaps

########################################################################
# Wrapper around colors.Colormap type:

mutable struct ColorMap
    o::PyObject
end

PyObject(c::ColorMap) = getfield(c, :o)
convert(::Type{ColorMap}, o::PyObject) = ColorMap(o)
==(c::ColorMap, g::ColorMap) = PyObject(c) == PyObject(g)
==(c::PyObject, g::ColorMap) = c == PyObject(g)
==(c::ColorMap, g::PyObject) = PyObject(c) == g
hash(c::ColorMap) = hash(PyObject(c))
pycall(c::ColorMap, args...; kws...) = pycall(PyObject(c), args...; kws...)
(c::ColorMap)(args...; kws...) = pycall(PyObject(c), PyAny, args...; kws...)
Base.Docs.doc(c::ColorMap) = Base.Docs.doc(PyObject(c))

# Note: using `Union{Symbol,String}` produces ambiguity.
Base.getproperty(c::ColorMap, s::Symbol) = getproperty(PyObject(c), s)
Base.getproperty(c::ColorMap, s::AbstractString) = getproperty(PyObject(c), s)
Base.setproperty!(c::ColorMap, s::Symbol, x) = setproperty!(PyObject(c), s, x)
Base.setproperty!(c::ColorMap, s::AbstractString, x) = setproperty!(PyObject(c), s, x)
Base.propertynames(c::ColorMap) = propertynames(PyObject(c))
hasproperty(c::ColorMap, s::Union{Symbol,AbstractString}) = hasproperty(PyObject(c), s)
haskey(c::ColorMap, x) = haskey(PyObject(c), x)

@deprecate getindex(c::ColorMap, x) getproperty(c, x)
@deprecate setindex!(c::ColorMap, s, x) setproperty!(c, s, x)
@deprecate keys(c::ColorMap) propertynames(c)

function show(io::IO, c::ColorMap)
    print(io, "ColorMap \"$(c.name)\"")
end

# all Python dependencies must be initialized at runtime (not when precompiled)
const colorsm = PyNULL()
const cm = PyNULL()
const LinearSegmentedColormap = PyNULL()
const cm_get_cmap = PyNULL()
const cm_register_cmap = PyNULL()
const ScalarMappable = PyNULL()
const Normalize01 = PyNULL()
function init_colormaps()
    copy!(colorsm, pyimport("matplotlib.colors"))
    copy!(cm, pyimport("matplotlib.cm"))

    pytype_mapping(colorsm."Colormap", ColorMap)

    copy!(LinearSegmentedColormap, colorsm."LinearSegmentedColormap")

    copy!(cm_get_cmap, cm."get_cmap")
    copy!(cm_register_cmap, cm."register_cmap")

    copy!(ScalarMappable, cm."ScalarMappable")
    copy!(Normalize01, pycall(colorsm."Normalize",PyAny,vmin=0,vmax=1))
end

########################################################################
# ColorMap constructors via colors.LinearSegmentedColormap

# most general constructors using RGB arrays of triples, defined
# as for matplotlib.colors.LinearSegmentedColormap
ColorMap(name::Union{AbstractString,Symbol},
         r::AbstractVector{Tuple{T,T,T}},
         g::AbstractVector{Tuple{T,T,T}},
         b::AbstractVector{Tuple{T,T,T}},
         n=max(256,length(r),length(g),length(b)), gamma=1.0) where {T<:Real} =
    ColorMap(name, r,g,b, Array{Tuple{T,T,T}}(undef, 0), n, gamma)

# as above, but also passing an alpha array
function ColorMap(name::Union{AbstractString,Symbol},
                  r::AbstractVector{Tuple{T,T,T}},
                  g::AbstractVector{Tuple{T,T,T}},
                  b::AbstractVector{Tuple{T,T,T}},
                  a::AbstractVector{Tuple{T,T,T}},
                  n=max(256,length(r),length(g),length(b),length(a)),
                  gamma=1.0) where T<:Real
    segmentdata = Dict("red" => r, "green" => g, "blue" => b)
    if !isempty(a)
        segmentdata["alpha"] = a
    end
    pycall(LinearSegmentedColormap, ColorMap,
           name, segmentdata, n, gamma)
end

# create from an array c, assuming linear mapping from [0,1] to c
function ColorMap(name::Union{AbstractString,Symbol},
                  c::AbstractVector{T}, n=max(256, length(c)), gamma=1.0) where T<:Colorant
    nc = length(c)
    if nc == 0
        throw(ArgumentError("ColorMap requires a non-empty Colorant array"))
    end
    r = Array{Tuple{Float64,Float64,Float64}}(undef, nc)
    g = similar(r)
    b = similar(r)
    a = T <: TransparentColor ?
        similar(r) : Array{Tuple{Float64,Float64,Float64}}(undef, 0)
    for i = 1:nc
        x = (i-1) / (nc-1)
        if T <: TransparentColor
            rgba = convert(RGBA{Float64}, c[i])
            r[i] = (x, rgba.r, rgba.r)
            b[i] = (x, rgba.b, rgba.b)
            g[i] = (x, rgba.g, rgba.g)
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

ColorMap(c::AbstractVector{T},
         n=max(256, length(c)), gamma=1.0) where {T<:Colorant} =
    ColorMap(string("cm_", hash(c)), c, n, gamma)

function ColorMap(name::Union{AbstractString,Symbol}, c::AbstractMatrix{T},
                  n=max(256, size(c,1)), gamma=1.0) where T<:Real
    if size(c,2) == 3
        return ColorMap(name,
                        [RGB{T}(c[i,1],c[i,2],c[i,3]) for i in 1:size(c,1)],
                        n, gamma)
    elseif size(c,2) == 4
        return ColorMap(name,
                        [RGBA{T}(c[i,1],c[i,2],c[i,3],c[i,4])
                         for i in 1:size(c,1)],
                        n, gamma)
    else
        throw(ArgumentError("color matrix must have 3 or 4 columns"))
    end
end

ColorMap(c::AbstractMatrix{T}, n=max(256, size(c,1)), gamma=1.0) where {T<:Real} =
    ColorMap(string("cm_", hash(c)), c, n, gamma)

########################################################################

@doc LazyHelp(cm_get_cmap) get_cmap() = pycall(cm_get_cmap, PyAny)
get_cmap(name::Union{AbstractString,Symbol}) = pycall(cm_get_cmap, PyAny, name)
get_cmap(name::Union{AbstractString,Symbol}, lut::Integer) = pycall(cm_get_cmap, PyAny, name, lut)
get_cmap(c::ColorMap) = c
ColorMap(name::Union{AbstractString,Symbol}) = get_cmap(name)

@doc LazyHelp(cm_register_cmap) register_cmap(c::ColorMap) = pycall(cm_register_cmap, PyAny, c)
register_cmap(n::Union{AbstractString,Symbol}, c::ColorMap) = pycall(cm_register_cmap, PyAny, n,c)

# convenience function to get array of registered colormaps
get_cmaps() =
    ColorMap[get_cmap(c) for c in
             sort(filter!(c -> !endswith(c, "_r"),
                          AbstractString[c for (c,v) in PyDict(PyPlot.cm."datad")]),
                  by=lowercase)]

########################################################################
# display of ColorMaps as a horizontal color bar in SVG

function show(io::IO, ::MIME"image/svg+xml", cs::AbstractVector{ColorMap})
    n = 256
    nc = length(cs)
    a = range(0; stop=1, length=n)
    namelen = mapreduce(c -> length(c.name), max, cs)
    width = 0.5
    height = 5
    pad = 0.5
    write(io,
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
         "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
        <svg xmlns="http://www.w3.org/2000/svg" version="1.1"
             width="$(n*width+1+namelen*4)mm" height="$((height+pad)*nc)mm"
             shape-rendering="crispEdges">
        """)
    for j = 1:nc
        c = cs[j]
        y = (j-1) * (height+pad)
        write(io, """<text x="$(n*width+1)mm" y="$(y+3.8)mm" font-size="3mm">$(c.name)</text>""")
        rgba = pycall(pycall(ScalarMappable, PyObject, cmap=c,
                             norm=Normalize01)."to_rgba", PyArray, a)
        for i = 1:n
            write(io, """<rect x="$((i-1)*width)mm" y="$(y)mm" width="$(width)mm" height="$(height)mm" fill="#$(hex(RGB(rgba[i,1],rgba[i,2],rgba[i,3])))" stroke="none" />""")
        end
    end
    write(io, "</svg>")
end

function show(io::IO, m::MIME"image/svg+xml", c::ColorMap)
    show(io, m, [c])
end

########################################################################
