module PyPlot

using PyCall
import PyCall: PyObject, pygui
import Base: convert, isequal, hash, writemime, getindex, setindex!, haskey, keys, show
export Figure, plt, matplotlib, pygui

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

pymodule_exists(s::String) = try 
    pyimport(s)
    true
catch
    false
end

const backend, gui = begin
    const gui2matplotlib = [ :wx=>"WXAgg", :gtk=>"GTKAgg", :qt=>"Qt4Agg" ]
    try
        local gui::Symbol
        if PyCall.gui == :default
            # try to ensure that GUI both exists and has a matplotlib backend
            for g in (:qt, :wx, :gtk)
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
        ("Agg", gui)
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
isequal(f::Figure, g::Figure) = isequal(f.o, g.o)
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
end

###########################################################################
# Monkey-patch pylab to call redisplay after each drawing command
# (which calls draw_if_interactive) for Julia displays.

const Gcf = pyimport("matplotlib._pylab_helpers")["Gcf"]
const drew_something = [false]
const orig_draw = pltm["draw_if_interactive"]

function draw_if_interactive()
    if isjulia_display[1]
        if pltm[:isinteractive]()
            manager = Gcf[:get_active]()
            if manager != nothing
                fig = Figure(manager["canvas"]["figure"])
                redisplay(fig)
                drew_something[1] = true
            end
        end
    else
        pycall(orig_draw, PyObject)
    end
    nothing
end

for d in (:display, :redisplay)
    s = symbol(string(d, "_figs"))
    @eval function $s()
        if drew_something[1] && isjulia_display[1]
            for manager in Gcf[:get_all_fig_managers]()
                $d(Figure(manager["canvas"]["figure"]))
            end
            $(d == :redisplay ? :(pltm[:close]("all")) : nothing)
            drew_something[1] = false # reset until next drawing command
        end
        nothing
    end
end

function monkeypatch()
    pltm["draw_if_interactive"] = draw_if_interactive
    pltm["show"] = display_figs
end

if isdefined(Main,:IJulia)
    Main.IJulia.push_postexecute_hook(redisplay_figs)
    Main.IJulia.push_posterror_hook(() -> begin
        if drew_something[1] && isjulia_display[1] 
            pltm[:close]("all")
            drew_something[1] = false # reset until next drawing command
        end
    end)
end

if isjulia_display[1] && backend != "Agg"
    pltm[:switch_backend]("Agg")
    monkeypatch()
end

###########################################################################

const plt = pywrap(pltm)

# export documented pyplot API (http://matplotlib.org/api/pyplot_api.html)
export acorr,annotate,arrow,autoscale,autumn,axes,axhline,axhspan,axis,axvline,axvspan,bar,barbs,barh,bone,box,boxplot,broken_barh,cla,clabel,clf,clim,cohere,colorbar,colors,contour,contourf,cool,copper,csd,delaxes,disconnect,draw,errorbar,eventplot,figimage,figlegend,figtext,figure,fill_between,fill_betweenx,findobj,flag,gca,gcf,gci,get_current_fig_manager,get_figlabels,get_fignums,get_plot_commands,ginput,gray,grid,hexbin,hist2d,hlines,hold,hot,hsv,imread,imsave,imshow,ioff,ion,ishold,isinteractive,jet,legend,locator_params,loglog,margins,matshow,minorticks_off,minorticks_on,over,pause,pcolor,pcolormesh,pie,pink,plot,plot_date,plotfile,polar,prism,psd,quiver,quiverkey,rc,rc_context,rcdefaults,rgrids,savefig,sca,scatter,sci,semilogx,semilogy,set_cmap,setp,show,specgram,spectral,spring,spy,stackplot,stem,step,streamplot,subplot,subplot2grid,subplot_tool,subplots,subplots_adjust,summer,suptitle,switch_backend,table,text,thetagrids,tick_params,ticklabel_format,tight_layout,title,tricontour,tricontourf,tripcolor,triplot,twinx,twiny,vlines,waitforbuttonpress,winter,xkcd,xlabel,xlim,xscale,xticks,ylabel,ylim,yscale,yticks

for f in (:acorr,:annotate,:arrow,:autoscale,:autumn,:axes,:axhline,:axhspan,:axis,:axvline,:axvspan,:bar,:barbs,:barh,:bone,:box,:boxplot,:broken_barh,:cla,:clabel,:clf,:clim,:cohere,:colorbar,:colors,:contour,:contourf,:cool,:copper,:csd,:delaxes,:disconnect,:draw,:errorbar,:eventplot,:figimage,:figlegend,:figtext,:figure,:fill_between,:fill_betweenx,:findobj,:flag,:gca,:gcf,:gci,:get_current_fig_manager,:get_figlabels,:get_fignums,:get_plot_commands,:ginput,:gray,:grid,:hexbin,:hist2d,:hlines,:hold,:hot,:hsv,:imread,:imsave,:imshow,:ioff,:ion,:ishold,:isinteractive,:jet,:legend,:locator_params,:loglog,:margins,:matshow,:minorticks_off,:minorticks_on,:over,:pause,:pcolor,:pcolormesh,:pie,:pink,:plot,:plot_date,:plotfile,:polar,:prism,:psd,:quiver,:quiverkey,:rc,:rc_context,:rcdefaults,:rgrids,:savefig,:sca,:scatter,:sci,:semilogx,:semilogy,:set_cmap,:setp,:specgram,:spectral,:spring,:spy,:stackplot,:stem,:step,:streamplot,:subplot,:subplot2grid,:subplot_tool,:subplots,:subplots_adjust,:summer,:suptitle,:switch_backend,:table,:text,:thetagrids,:tick_params,:ticklabel_format,:tight_layout,:title,:tricontour,:tricontourf,:tripcolor,:triplot,:twinx,:twiny,:vlines,:waitforbuttonpress,:winter,:xkcd,:xlabel,:xlim,:xscale,:xticks,:ylabel,:ylim,:yscale,:yticks)
    py_f = symbol(string("py_", f))
    sf = string(f)
    if haskey(pltm, sf)
        @eval begin
            const $py_f = pltm[$sf]
            $f(args...; kws...) = pycall($py_f, PyAny, args...; kws...)
        end
    else # using a different (older?) version of matplotlib
        @eval $f(args...; kws...) = error("matplotlib ", m[:__version__],
                                          " does not have pyplot.$sf")
    end
end

# The following pyplot functions must be handled specially since they
# overlap with standard Julia functions:
#          close, connect, fill, hist, xcorr

import Base: close, connect, fill

show() = display_figs()

const py_close = pltm["close"]
close(f::Union(Figure,String,Integer)) = pycall(py_close, PyAny, f)
close() = pycall(py_close, PyAny)

const py_connect = pltm["connect"]
connect(s::String, f::Function) = pycall(py_connect, PyAny, s, f)

const py_fill = pltm["fill"]
fill(x::AbstractArray,y::AbstractArray, args...; kws...) =
    pycall(py_fill, PyAny, x, y, args...; kws...)

# no way to use method dispatch for hist or xcorr, since their
# argument signatures look too much like Julia's

include("colormaps.jl")

###########################################################################
# Include mplot3d for 3d plotting.

export art3d, Axes3D, surf, mesh, bar3d, contour3D, contourf3D, plot3D, plot_surface, plot_trisurf, plot_wireframe, scatter3D, text2D, text3D

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
end
const bar3D = bar3d # correct for annoying mplot3d inconsistency

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

###########################################################################

include("latex.jl")

###########################################################################

end # module PyPlot
