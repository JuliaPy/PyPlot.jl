module PyPlot

using PyCall
import PyCall: PyObject
import Base: convert, isequal, hash, writemime
export PyPlotFigure, plt, matplotlib

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
# Display backend: use built-in Julia display mechanism if images
# are displayable and PyCall.gui == :default, or pygui otherwise.

const isjulia_display = PyCall.gui == :default && isdisplayok()
const matplotlib = pyimport("matplotlib")

if isjulia_display
    matplotlib[:use]("Agg") # make sure no GUI windows pop up
    matplotlib[:interactive](true)
else
    const gui2matplotlib = [ :wx=>"WXAgg", :gtk=>"GTKAgg", :qt=>"Qt4Agg" ]
    try
        gui = pygui()
        pygui_start(gui)
        matplotlib[:use](gui2matplotlib[gui])
        matplotlib[:interactive](true)
    catch
        pygui(:default)
        matplotlib[:use]("Agg") # GUI not available
        matplotlib[:interactive](false)
    end
end

const pltm = pyimport("matplotlib.pyplot") # raw Python module

###########################################################################
# Wrapper around matplotlib Figure, supporting graphics I/O and pretty display

type PyPlotFigure
    o::PyObject
end

PyObject(f::PyPlotFigure) = f.o
convert(::Type{PyPlotFigure}, o::PyObject) = PyPlotFigure(o)
isequal(f::PyPlotFigure, g::PyPlotFigure) = isequal(f.o, g.o)
hash(f::PyPlotFigure) = hash(f.o)

pytype_mapping(pltm["Figure"], PyPlotFigure)

for (mime,fmt) in aggformats
    @eval writemime(io::IO, ::@MIME($mime), f::PyPlotFigure) =
        f.o["canvas"][:print_figure](io, format=$fmt, bbox_inches="tight")
end

###########################################################################
# For Julia displays, monkey-patch pylab to call redisplay after each
# drawing command (which calls draw_if_interactive)

if isjulia_display
    const Gcf = pyimport("matplotlib._pylab_helpers")["Gcf"]
    const drew_something = [false]

    function draw_if_interactive()
        if pltm[:isinteractive]()
            manager = Gcf[:get_active]()
            if manager != nothing
                fig = PyPlotFigure(manager["canvas"]["figure"])
                redisplay(fig)
                drew_something[1] = true
            end
        end
        nothing
    end
    
    for d in (:display, :redisplay)
        s = symbol(string(d, "_figs"))
        @eval function $s()
            if drew_something[1]
                for manager in Gcf[:get_all_fig_managers]()
                    $d(PyPlotFigure(manager["canvas"]["figure"]))
                end
                $(d == :redisplay ? :(pltm[:close]("all")) : nothing)
                drew_something[1] = false # reset until next drawing command
            end
            nothing
        end
    end
    
    pltm["draw_if_interactive"] = draw_if_interactive
    pltm["show"] = display_figs
    
    if isdefined(Main,:IJulia)
        Main.IJulia.push_postexecute_hook(redisplay_figs)
    end
elseif PyCall.gui != :default # pygui display
    # We monkey-patch pylab.show to ensure that it is non-blocking, as
    # matplotlib does not reliably detect that our event-loop is running.
    # (Note that some versions of show accept a "block" keyword or directly
    # as a boolean argument, so we must accept the same arguments.)
    function show_noop(b=false; block=false)
        nothing # no-op
    end
    pltm[:show] = show_noop
end

###########################################################################

const plt = pywrap(pltm)

# export documented pyplot API (http://matplotlib.org/api/pyplot_api.html)
export acorr,annotate,arrow,autoscale,autumn,axes,axhline,axhspan,axis,axvline,axvspan,bar,barbs,barh,bone,box,boxplot,broken_barh,cla,clabel,clf,clim,close,cohere,colorbar,colors,connect,contour,contourf,cool,copper,csd,delaxes,disconnect,draw,errorbar,eventplot,figimage,figlegend,figtext,figure,fill,fill_between,fill_betweenx,findobj,flag,gca,gcf,gci,get_current_fig_manager,get_figlabels,get_fignums,get_plot_commands,ginput,gray,grid,hexbin,hist,hist2d,hlines,hold,hot,hsv,imread,imsave,imshow,ioff,ion,ishold,isinteractive,jet,legend,locator_params,loglog,margins,matshow,minorticks_off,minorticks_on,over,pause,pcolor,pcolormesh,pie,pink,plot,plot_date,plotfile,polar,prism,psd,quiver,quiverkey,rc,rc_context,rcdefaults,rgrids,savefig,sca,scatter,sci,semilogx,semilogy,set_cmap,setp,show,specgram,spectral,spring,spy,stackplot,stem,step,streamplot,subplot,subplot2grid,subplot_tool,subplots,subplots_adjust,summer,suptitle,switch_backend,table,text,thetagrids,tick_params,ticklabel_format,tight_layout,title,tricontour,tricontourf,tripcolor,triplot,twinx,twiny,vlines,waitforbuttonpress,winter,xcorr,xkcd,xlabel,xlim,xscale,xticks,ylabel,ylim,yscale,yticks

for f in (:acorr,:annotate,:arrow,:autoscale,:autumn,:axes,:axhline,:axhspan,:axis,:axvline,:axvspan,:bar,:barbs,:barh,:bone,:box,:boxplot,:broken_barh,:cla,:clabel,:clf,:clim,:close,:cohere,:colorbar,:colors,:connect,:contour,:contourf,:cool,:copper,:csd,:delaxes,:disconnect,:draw,:errorbar,:eventplot,:figimage,:figlegend,:figtext,:figure,:fill,:fill_between,:fill_betweenx,:findobj,:flag,:gca,:gcf,:gci,:get_current_fig_manager,:get_figlabels,:get_fignums,:get_plot_commands,:ginput,:gray,:grid,:hexbin,:hist,:hist2d,:hlines,:hold,:hot,:hsv,:imread,:imsave,:imshow,:ioff,:ion,:ishold,:isinteractive,:jet,:legend,:locator_params,:loglog,:margins,:matshow,:minorticks_off,:minorticks_on,:over,:pause,:pcolor,:pcolormesh,:pie,:pink,:plot,:plot_date,:plotfile,:polar,:prism,:psd,:quiver,:quiverkey,:rc,:rc_context,:rcdefaults,:rgrids,:savefig,:sca,:scatter,:sci,:semilogx,:semilogy,:set_cmap,:setp,:show,:specgram,:spectral,:spring,:spy,:stackplot,:stem,:step,:streamplot,:subplot,:subplot2grid,:subplot_tool,:subplots,:subplots_adjust,:summer,:suptitle,:switch_backend,:table,:text,:thetagrids,:tick_params,:ticklabel_format,:tight_layout,:title,:tricontour,:tricontourf,:tripcolor,:triplot,:twinx,:twiny,:vlines,:waitforbuttonpress,:winter,:xcorr,:xkcd,:xlabel,:xlim,:xscale,:xticks,:ylabel,:ylim,:yscale,:yticks)
    py_f = symbol(string("py_", f))
    sf = string(f)
    if haskey(pltm, sf)
        @eval begin
            const $py_f = pltm[$sf]
            $f(args...) = pycall($py_f, PyAny, args...)
        end
    else # using a different (older?) version of matplotlib
        @eval $f(args...) = error("matplotlib ", m[:__version__],
                                  " does not have pyplot.$sf")
    end
end

end # module PyPlot
