module PyPlot

using PyCall
import PyCall: PyObject, pygui
import Base: convert, ==, isequal, hash, writemime, getindex, setindex!, haskey, keys, show, mimewritable
export Figure, plt, matplotlib, pygui, withfig

###########################################################################
# file formats supported by Agg backend, from MIME types
const aggformats = [ "application/eps" => "eps", "image/eps" => "eps",
                     "application/pdf" => "pdf",
                     "image/png" => "png",
                     "application/postscript" => "ps",
                     "image/svg+xml" => "svg" ]

function isdisplayok()
    for mime in keys(aggformats)
        if displayable(mime)
            return true
        end
    end
    false
end

###########################################################################
# We allow the user to turn on or off the Python gui interactively via
# pygui(true/false).  This is done by loading pyplot with a GUI backend
# if possible, then switching to a Julia-display backend (if available),
# hooking into pyplot via a monkey-patched draw_if_interactive.

const isjulia_display = Bool[isdisplayok()]
const matplotlib = pyimport("matplotlib")
const version = try
    convert(VersionNumber, matplotlib[:__version__])
catch
    v"0.0" # fallback
end

pymodule_exists(s::String) = try 
    pyimport(s)
    true
catch
    false
end

const (backend, gui) = begin
    const gui2matplotlib = [ :wx=>"WXAgg", :gtk=>"GTKAgg", :qt=>"Qt4Agg" ]
    try
        # We will get an exception when we import pyplot below
        # (on Unix) if an X server is not available, even though
        # pygui_works and matplotlib.use(backend) succeed, at
        # which point it will be too late to switch backends.  So,
        # throw exception (drop to catch block below) if DISPLAY is not set.
        # [Might be more reliable to test success(`xdpyinfo`), but only
        #  if xdpyinfo is installed.]
        @unix_only (@osx ? nothing : ENV["DISPLAY"])

        local gui::Symbol = :none
        if PyCall.gui == :default
            # try to ensure that GUI both exists and has a matplotlib backend
            for g in (@linux? (:gtk, :qt, :wx) : (:qt, :wx, :gtk))
                if PyCall.pygui_works(g)
                    # must call matplotlib.use *before* loading backends module
                    matplotlib[:use](gui2matplotlib[g])
                    if g == :qt && !PyCall.pyexists("PyQt4")
                        PyDict(matplotlib["rcParams"])["backend.qt4"]="PySide"
                    end
                    if pymodule_exists(string("matplotlib.backends.backend_", 
                                              lowercase(gui2matplotlib[g])))
                        gui = g
                        break
                    end
                end
            end
            if gui == :none
                error("no gui found") # go to catch clause below
            end
        else
            gui = pygui()
            matplotlib[:use](gui2matplotlib[gui])
        end
        if !isjulia_display[1]
            pygui_start(gui)
        end
        matplotlib[:interactive](true)
        (gui2matplotlib[gui], gui)
    catch
        if !isjulia_display[1]
            warn("No working GUI backend found for matplotlib.")
            isjulia_display[1] = true
        end
        pygui(:default)
        matplotlib[:use]("Agg") # GUI not available
        matplotlib[:interactive](isdisplayok())
        ("Agg", :none)
    end
end

const pltm = pyimport("matplotlib.pyplot") # raw Python module

function pygui(b::Bool)
    if !b != isjulia_display[1]
        if backend != "Agg"
            pltm[:switch_backend](b ? backend : "Agg")
            monkeypatch()
            if b
                pygui_start(gui) # make sure event loop is started
            end
        elseif b
            error("No working GUI backend found for matplotlib.")
        end
        isjulia_display[1] = !b
    end
    return b
end

###########################################################################
# Wrapper around matplotlib Figure, supporting graphics I/O and pretty display

type Figure
    o::PyObject
end

PyObject(f::Figure) = f.o
convert(::Type{Figure}, o::PyObject) = Figure(o)
==(f::Figure, g::Figure) = f.o == g.o
isequal(f::Figure, g::Figure) = f.o == g.o # Julia 0.2 compatibility
==(f::Figure, g::PyObject) = f.o == g
==(f::PyObject, g::Figure) = f == g.o
hash(f::Figure) = hash(f.o)

getindex(f::Figure, x) = getindex(f.o, x)
setindex!(f::Figure, v, x) = setindex!(f.o, v, x)
haskey(f::Figure, x) = haskey(f.o, x)
keys(f::Figure) = keys(f.o)

pytype_mapping(pltm["Figure"], Figure)

for (mime,fmt) in aggformats
    @eval function writemime(io::IO, m::MIME{symbol($mime)}, f::Figure)
        if !haskey(pycall(f.o["canvas"]["get_supported_filetypes"], PyDict),
                   $fmt)
            throw(MethodError(writemime, (io, m, f)))
        end
        f.o["canvas"][:print_figure](io, format=$fmt, bbox_inches="tight")
    end
    if fmt != "svg"
        @eval mimewritable(::MIME{symbol($mime)}, f::Figure) = haskey(pycall(f.o["canvas"]["get_supported_filetypes"], PyDict), $fmt)
    end
end

# disable SVG output by default, since displaying large SVGs (large datasets)
# in IJulia is slow, and browser SVG display is buggy.  (Similar to IPython.)
const SVG = [false]
mimewritable(::MIME"image/svg+xml", f::Figure) = SVG[1] && haskey(pycall(f.o["canvas"]["get_supported_filetypes"], PyDict), "svg")
svg() = SVG[1]
svg(b::Bool) = (SVG[1] = b)

###########################################################################
# Monkey-patch pylab to call redisplay after each drawing command
# (which calls draw_if_interactive) for Julia displays.

const Gcf = pyimport("matplotlib._pylab_helpers")["Gcf"]
const drew_something = [false]
const orig_draw = pltm["draw_if_interactive"]

Base.isempty(f::Figure) = isempty(pycall(f["get_axes"], PyVector))

function draw_if_interactive()
    if isjulia_display[1]
        if pltm[:isinteractive]()
            manager = Gcf[:get_active]()
            if manager != nothing
                fig = Figure(manager["canvas"]["figure"])
                if !isempty(fig)
                    redisplay(fig)
                    drew_something[1] = true
                end
            end
        end
    else
        pycall(orig_draw, PyObject)
    end
    nothing
end

# The logic of display/redisplay/close is a bit complicated.  In
# IJulia, we want to automatically display any figures that were
# queued (via redisplay in draw_if_interactive) at the end of the cell
# execution, and then close them.  However, we don't want to
# close/display *all* figures, as there may be some other figures that
# the user is keeping track of in some other way, e.g. for interactive
# widgets.  So, we only want to close figures in the
# IJulia.displayqueue.  Furthermore, if the user explicitly calls
# display() on a figure or does so implicitly by returning a Figure
# object from the cell, we still want to eventually close the figure
# even though display removes it from the displayqueue, so we need to
# keep track of it in a separate closequeue in that case.

# queue of figures that need closing despite being removed from displayqueue
const closequeue = Figure[]
function pushclose(f::Figure)
    if !in(f, closequeue)
        push!(closequeue, f)
    end
    return f
end

function display_figs()
    if drew_something[1] && isjulia_display[1]
        for manager in Gcf[:get_all_fig_managers]()
            display(pushclose(Figure(manager["canvas"]["figure"])))
        end
        drew_something[1] = false # reset until next drawing command
    end
    nothing
end

function close_queued_figs()
    if isjulia_display[1] && (drew_something[1] || !isempty(closequeue))
        for f in Main.IJulia.displayqueue
            if isa(f, Figure)
                pltm[:close](f[:number])
            end
        end
        for f in closequeue
            pltm[:close](f[:number])
        end
        empty!(closequeue)
        drew_something[1] = false # reset until next drawing command 

        # if there are still open figures and the current figure is
        # non-empty, we want the next IJulia cell to draw into a new
        # figure rather than overwriting an existing one.
        manager = Gcf[:get_active]()
        if manager != nothing && !isempty(Figure(manager["canvas"]["figure"]))
            figure()
        end
    end
end

function monkeypatch()
    pltm["draw_if_interactive"] = draw_if_interactive
    pltm["show"] = display_figs
end

if isdefined(Main,:IJulia)
    Main.IJulia.push_postexecute_hook(close_queued_figs)
    Main.IJulia.push_posterror_hook(close_queued_figs)
end

if isjulia_display[1]
    if backend != "Agg"
        pltm[:switch_backend]("Agg")
    end
    monkeypatch()
end

###########################################################################
# Base.Help.FUNCTION_DICT is undocumented, but it is better than nothing
# until Julia gets a documented docstring-like facility.

function addhelp(f::String, o::PyObject)
    try
        Base.Help.init_help()
        if haskey(o, "__doc__")
            if !haskey(Base.Help.FUNCTION_DICT, f)
                Base.Help.FUNCTION_DICT[f] = {}
            end
            push!(Base.Help.FUNCTION_DICT[f], convert(String, o["__doc__"]))
        end
    end
end
addhelp(f::Symbol, o::PyObject) = addhelp(string(f), o)
addhelp(f, o::PyObject, key::String) = haskey(o, key) && addhelp(f, o[key])
    
###########################################################################

const plt = pywrap(pltm)

# export documented pyplot API (http://matplotlib.org/api/pyplot_api.html)
export acorr,annotate,arrow,autoscale,autumn,axes,axhline,axhspan,axis,axvline,axvspan,bar,barbs,barh,bone,box,boxplot,broken_barh,cla,clabel,clf,clim,cohere,colorbar,colors,contour,contourf,cool,copper,csd,delaxes,disconnect,draw,errorbar,eventplot,figimage,figlegend,figtext,figure,fill_between,fill_betweenx,findobj,flag,gca,gcf,gci,get_current_fig_manager,get_figlabels,get_fignums,get_plot_commands,ginput,gray,grid,hexbin,hist2d,hlines,hold,hot,hsv,imread,imsave,imshow,ioff,ion,ishold,jet,legend,locator_params,loglog,margins,matshow,minorticks_off,minorticks_on,over,pause,pcolor,pcolormesh,pie,pink,plot,plot_date,plotfile,polar,prism,psd,quiver,quiverkey,rc,rc_context,rcdefaults,rgrids,savefig,sca,scatter,sci,semilogx,semilogy,set_cmap,setp,show,specgram,spectral,spring,spy,stackplot,stem,step,streamplot,subplot,subplot2grid,subplot_tool,subplots,subplots_adjust,summer,suptitle,switch_backend,table,text,thetagrids,tick_params,ticklabel_format,tight_layout,title,tricontour,tricontourf,tripcolor,triplot,twinx,twiny,vlines,waitforbuttonpress,winter,xkcd,xlabel,xlim,xscale,xticks,ylabel,ylim,yscale,yticks

for f in (:acorr,:annotate,:arrow,:autoscale,:autumn,:axes,:axhline,:axhspan,:axis,:axvline,:axvspan,:bar,:barbs,:barh,:bone,:box,:boxplot,:broken_barh,:cla,:clabel,:clf,:clim,:cohere,:colorbar,:colors,:contour,:contourf,:cool,:copper,:csd,:delaxes,:disconnect,:draw,:errorbar,:eventplot,:figimage,:figlegend,:figtext,:figure,:fill_between,:fill_betweenx,:findobj,:flag,:gca,:gcf,:gci,:get_current_fig_manager,:get_figlabels,:get_fignums,:get_plot_commands,:ginput,:gray,:grid,:hexbin,:hist2d,:hlines,:hold,:hot,:hsv,:imread,:imsave,:imshow,:ioff,:ion,:ishold,:jet,:legend,:locator_params,:loglog,:margins,:matshow,:minorticks_off,:minorticks_on,:over,:pause,:pcolor,:pcolormesh,:pie,:pink,:plot,:plot_date,:plotfile,:polar,:prism,:psd,:quiver,:quiverkey,:rc,:rc_context,:rcdefaults,:rgrids,:savefig,:sca,:scatter,:sci,:semilogx,:semilogy,:set_cmap,:setp,:specgram,:spectral,:spring,:spy,:stackplot,:stem,:streamplot,:subplot,:subplot2grid,:subplot_tool,:subplots,:subplots_adjust,:summer,:suptitle,:switch_backend,:table,:text,:thetagrids,:tick_params,:ticklabel_format,:tight_layout,:title,:tricontour,:tricontourf,:tripcolor,:triplot,:twinx,:twiny,:vlines,:waitforbuttonpress,:winter,:xkcd,:xlabel,:xlim,:xscale,:xticks,:ylabel,:ylim,:yscale,:yticks)
    py_f = symbol(string("py_", f))
    sf = string(f)
    if haskey(pltm, sf)
        @eval begin
            const $py_f = pltm[$sf]
            $f(args...; kws...) = pycall($py_f, PyAny, args...; kws...)
        end
        addhelp(f, pltm[sf])
    else # using a different (older?) version of matplotlib
        @eval $f(args...; kws...) = error("matplotlib ", version,
                                          " does not have pyplot.", $sf)
    end
end

# The following pyplot functions must be handled specially since they
# overlap with standard Julia functions:
#          close, connect, fill, hist, xcorr

import Base: close, connect, fill, step

show() = display_figs()

const py_step = pltm["step"]
step(x, y; kws...) = pycall(py_step, PyAny, x, y; kws...)
addhelp("PyPlot.step", py_step)

const py_close = pltm["close"]
close(f::Union(Figure,String,Symbol,Integer)) = pycall(py_close, PyAny, f)
close() = pycall(py_close, PyAny)
addhelp("PyPlot.close", py_close)

const py_connect = pltm["connect"]
connect(s::Union(String,Symbol), f::Function) = pycall(py_connect, PyAny, s, f)
addhelp("PyPlot.connect", py_connect)

const py_fill = pltm["fill"]
fill(x::AbstractArray,y::AbstractArray, args...; kws...) =
    pycall(py_fill, PyAny, x, y, args...; kws...)
addhelp("PyPlot.fill", py_fill)

# no way to use method dispatch for hist or xcorr, since their
# argument signatures look too much like Julia's

include("colormaps.jl")

###########################################################################
# Support array of string labels in bar chart

function bar{T<:String}(x::AbstractVector{T}, y; kws...)
    xi = 1:length(x)
    if !any(kw -> kw[1] == :align, kws)
        push!(kws, (:align, "center"))
    end
    p = bar(xi, y; kws...)
    ax = any(kw -> kw[1] == :orientation && lowercase(kw[2]) == "horizontal",
             kws) ? gca()["yaxis"] : gca()["xaxis"]
    ax[:set_ticks](xi)
    ax[:set_ticklabels](x)
    return p
end

bar{T<:Symbol}(x::AbstractVector{T}, y; kws...) =
    bar(map(string, x), y; kws...)

###########################################################################
# Include mplot3d for 3d plotting.

export art3d, Axes3D, surf, mesh, bar3d, bar3D, contour3D, contourf3D, plot3D, plot_surface, plot_trisurf, plot_wireframe, scatter3D, text2D, text3D, zlabel, zlim, zscale, zticks

const mplot3d = pyimport("mpl_toolkits.mplot3d")
const axes3d = pyimport("mpl_toolkits.mplot3d.axes3d")

const art3d = pywrap(pyimport("mpl_toolkits.mplot3d.art3d"))
const Axes3D = axes3d[:Axes3D]

for f in (:bar3d, :contour3D, :contourf3D, :plot3D, :plot_surface,
          :plot_trisurf, :plot_wireframe, :scatter3D, :text2D, :text3D)
    fs = string(f)
    @eval function $f(args...; kws...)
        ax = gca(projection="3d")
        pycall(ax[$fs], PyAny, args...; kws...)
    end
    addhelp(fs, axes3d["Axes3D"], fs)
end
const bar3D = bar3d # correct for annoying mplot3d inconsistency
addhelp("bar3D", axes3d["Axes3D"], "bar3d")

# it's annoying to have xlabel etc. but not zlabel
for f in (:zlabel, :zlim, :zscale, :zticks)
    fs = string("set_", f)
    @eval function $f(args...; kws...)
        ax = gca(projection="3d")
        pycall(ax[$fs], PyAny, args...; kws...)
    end
    addhelp(f, axes3d["Axes3D"], fs)
end

# export Matlab-like names

function surf(Z::AbstractMatrix; kws...)
    plot_surface([1:size(Z,1)]*ones(1,size(Z,2)), 
                 ones(size(Z,1))*[1:size(Z,2)]', Z; kws...)
end

function surf(X, Y, Z::AbstractMatrix, args...; kws...)
    plot_surface(X, Y, Z, args...; kws...)
end

function surf(X, Y, Z::AbstractVector, args...; kws...)
    plot_trisurf(X, Y, Z, args...; kws...)
end

mesh(args...; kws...) = plot_wireframe(args...; kws...)

function mesh(Z::AbstractMatrix; kws...)
    plot_wireframe([1:size(Z,1)]*ones(1,size(Z,2)), 
                   ones(size(Z,1))*[1:size(Z,2)]', Z; kws...)
end

addhelp(:surf, axes3d["Axes3D"], "plot_surface")
addhelp(:mesh, axes3d["Axes3D"], "plot_wireframe")

###########################################################################
# Allow plots with 2 independent variables (contour, surf, ...)
# to accept either 2 1d arrays or a row vector and a 1d array,
# to simplify construction of such plots via broadcasting operations.
# (Matplotlib is inconsistent about this.)

for f in (:contour, :contourf)
    @eval function $f(X::AbstractMatrix, Y::AbstractVector, args...; kws...)
        if size(X,1) == 1 || size(X,2) == 1
            $f(reshape(X, length(X)), Y, args...; kws...)
        else
            throw(ArgumentError("if 2nd arg is column vector, 1st arg must be row or column vector"))
        end
    end
end

for f in (:surf,:mesh,:plot_surface,:plot_wireframe,:contour3D,:contourf3D)
    @eval begin
        function $f(X::AbstractVector, Y::AbstractVector, Z::AbstractMatrix, args...; kws...)
            m, n = length(X), length(Y)
            $f(repmat(reshape(X,1,m),n,1), repmat(Y,1,m), Z, args...; kws...)
        end
        function $f(X::AbstractMatrix, Y::AbstractVector, Z::AbstractMatrix, args...; kws...)
            if size(X,1) != 1 && size(X,2) != 1
                throw(ArgumentError("if 2nd arg is column vector, 1st arg must be row or column vector"))
            end
            m, n = length(X), length(Y)
            $f(repmat(reshape(X,1,m),n,1), repmat(Y,1,m), Z, args...; kws...)
        end
    end
end

# Already work: barbs, pcolor, pcolormesh, quiver

# Matplotlib pcolor* functions accept 1d arrays but not ranges
for f in (:pcolor, :pcolormesh)
    @eval begin
        $f(X::Range, Y::Range, args...; kws...) = $f([X...], [Y...], args...; kws...)
        $f(X::Range, Y::AbstractArray, args...; kws...) = $f([X...], Y, args...; kws...)
        $f(X::AbstractArray, Y::Range, args...; kws...) = $f(X, [Y...], args...; kws...)
    end
end

###########################################################################
# a more pure functional style, that returns the figure but does *not*
# have any display side-effects.  Mainly for use with @manipulate (Interact.jl)

function withfig(actions::Function, f::Figure; clear=true)
    ax_save = gca()
    figure(f[:number])
    finalizer(f, close)
    try
        if clear && !isempty(f)
            clf()
        end
        actions()
    catch
        rethrow()
    finally
        try
            sca(ax_save) # may fail if axes were overwritten
        end
        Main.IJulia.undisplay(f)
    end
    return f
end

###########################################################################

include("latex.jl")

###########################################################################

end # module PyPlot
