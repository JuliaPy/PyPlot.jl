# PyPlot initialization — the hardest part is finding a working backend.
using VersionParsing

###########################################################################

# global PyObject constants that get initialized at runtime.  We
# initialize them here (rather than via "global foo = ..." in __init__)
# so that their type is known at compile-time.

const matplotlib = PyNULL()
const plt = PyNULL()
const Gcf = PyNULL()
const orig_draw = PyNULL()
const orig_gcf = PyNULL()
const orig_figure = PyNULL()
const orig_show = PyNULL()

###########################################################################
# file formats supported by Agg backend, from MIME types
const aggformats = Dict("application/eps" => "eps",
                        "image/eps" => "eps",
                        "application/pdf" => "pdf",
                        "image/png" => "png",
                        "application/postscript" => "ps",
                        "image/svg+xml" => "svg")

# In 0.6, TextDisplay can show e.g. image/svg+xml as text (#281).
# Any "real" graphical display should support PNG, I hope.
isdisplayok() = displayable(MIME("image/png"))

###########################################################################
# We allow the user to turn on or off the Python gui interactively via
# pygui(true/false).  This is done by loading pyplot with a GUI backend
# if possible, then switching to a Julia-display backend (if available)

# like get(dict, key, default), but treats a value of "nothing" as a missing key
function getnone(dict, key, default)
    ret = get(dict, key, default)
    return ret === nothing ? default : ret
end

# return (backend,gui) tuple
function find_backend(matplotlib::PyObject)
    gui2matplotlib = Dict(:wx=>"WXAgg",:gtk=>"GTKAgg",:gtk3=>"GTK3Agg",
                          :qt_pyqt4=>"Qt4Agg", :qt_pyqt5=>"Qt5Agg",
                          :qt_pyside=>"Qt4Agg", :qt4=>"Qt4Agg",
                          :qt5=>"Qt5Agg", :qt=>"Qt4Agg",:tk=>"TkAgg")
    conda = PyCall.conda || !isempty(PyCall.anaconda_conda())
    if Sys.islinux()
        guis = [:tk, :gtk3, :gtk, :qt5, :qt4, :wx]
    else
        guis = [:tk, :qt5, :qt4, :wx, :gtk, :gtk3]
    end
    options = [(g,gui2matplotlib[g]) for g in guis]

    matplotlib2gui = Dict("wx"=>:wx, "wxagg"=>:wx,
                          "gtkagg"=>:gtk, "gtk"=>:gtk,"gtkcairo"=>:gtk,
                          "gtk3agg"=>:gtk3, "gtk3"=>:gtk3,"gtk3cairo"=>:gtk3,
                          "qt5agg"=>:qt5, "qt4agg"=>:qt4, "tkagg"=>:tk,
                          "agg"=>:none,"ps"=>:none,"pdf"=>:none,
                          "svg"=>:none,"cairo"=>:none,"gdk"=>:none,
                          "module://gr.matplotlib.backend_gr"=>:gr)

    qt2gui = Dict("pyqt5"=>:qt_pyqt5, "pyqt4"=>:qt_pyqt4, "pyside"=>:qt_pyside)

    rcParams = PyDict(matplotlib."rcParams")
    default = lowercase(get(ENV, "MPLBACKEND",
                            getnone(rcParams, "backend", "none")))
    if haskey(matplotlib2gui,default)
        defaultgui = matplotlib2gui[default]

        # if the user explicitly requested a particular GUI,
        # it makes sense to ensure that the relevant Conda
        # package is installed (if we are using Conda).
        if conda
            if defaultgui == :qt || defaultgui == :qt4
                # default to pyqt rather than pyside, as below:
                defaultgui = qt2gui[lowercase(getnone(rcParams,"backend.qt4", "pyqt4"))]
                if defaultgui == :qt_pyside
                    pyimport_conda("PySide", "pyside")
                else
                    try
                        pyimport_conda("PyQt5", "pyqt")
                    catch
                        pyimport("PyQt4")
                    end
                end
            elseif defaultgui == :qt5
                pyimport_conda("PyQt5", "pyqt")
            elseif defaultgui == :wx
                pyimport_conda("wx", "wxpython")
            end
        end

        insert!(options, 1, (defaultgui,default))
    end

    try
        # We will get an exception when we import pyplot below (on
        # Unix) if an X server is not available, even though
        # pygui_works and matplotlib.use(backend) succeed, at
        # which point it will be too late to switch backends.  So,
        # throw exception (drop to catch block below) if DISPLAY
        # is not set.  [Might be more reliable to test
        # success(`xdpyinfo`), but only if xdpyinfo is installed.]
        if options[1][1] != :none && Sys.isunix() && !Sys.isapple()
            ENV["DISPLAY"]
        end

        if PyCall.gui == :default
            # try to ensure that GUI both exists and has a matplotlib backend
            for (g,b) in options
                if g == :none # Matplotlib is configured to be non-interactive
                    pygui(:default)
                    matplotlib."use"(b)
                    matplotlib."interactive"(false)
                    return (b, g)
                elseif g == :gr
                    return (b, g)
                elseif PyCall.pygui_works(g)
                    # must call matplotlib.use *before* loading backends module
                    matplotlib."use"(b)
                    if g == :qt || g == :qt4
                        if haskey(rcParams,"backend.qt4")
                            g = qt2gui[lowercase(rcParams."backend.qt4")]
                        elseif !PyCall.pyexists("PyQt5") && !PyCall.pyexists("PyQt4")
                            # both Matplotlib and PyCall default to PyQt4
                            # if it is available, but we need to tell
                            # Matplotlib to use PySide otherwise.
                            rcParams."backend.qt4" = "PySide"
                        end
                    end
                    if pyexists("matplotlib.backends.backend_" * lowercase(b))
                        isjulia_display[] || pygui_start(g)
                        matplotlib."interactive"(!isjulia_display[] && Base.isinteractive())
                        return (b, g)
                    end
                end
            end
            error("no gui found") # go to catch clause below
        else # the user specified a desired backend via pygui(gui)
            gui = pygui()
            matplotlib."use"(gui2matplotlib[gui])
            if (gui==:qt && !PyCall.pyexists("PyQt5") && !PyCall.pyexists("PyQt4")) || gui==:qt_pyside
                rcParams."backend.qt4" = "PySide"
            end
            isjulia_display[] || pygui_start(gui)
            matplotlib."interactive"(!isjulia_display[] && Base.isinteractive())
            return (gui2matplotlib[gui], gui)
        end
    catch e
        if !isjulia_display[]
            @warn("No working GUI backend found for matplotlib")
            isjulia_display[] = true
        end
        pygui(:default)
        matplotlib."use"("Agg") # GUI not available
        matplotlib."interactive"(false)
        return ("Agg", :none)
    end
end

# declare more globals created in __init__
const isjulia_display = Ref(true)
version = v"0.0.0"
backend = "Agg"
gui = :default

# initialization -- anything that depends on Python has to go here,
# so that it occurs at runtime (while the rest of PyPlot can be precompiled).
function __init__()
    ccall(:jl_generating_output, Cint, ()) == 1 && return nothing
    isjulia_display[] = isdisplayok()
    copy!(matplotlib, pyimport_conda("matplotlib", "matplotlib"))
    mvers = matplotlib.__version__
    global version = try
        vparse(mvers)
    catch
        v"0.0.0" # fallback
    end

    backend_gui = find_backend(matplotlib)
    # workaround JuliaLang/julia#8925
    global backend = backend_gui[1]
    global gui = backend_gui[2]

    copy!(plt, pyimport("matplotlib.pyplot")) # raw Python module

    pytype_mapping(plt."Figure", Figure)

    copy!(Gcf, pyimport("matplotlib._pylab_helpers")."Gcf")
    copy!(orig_gcf, plt."gcf")
    copy!(orig_figure, plt."figure")
    plt."gcf" = gcf
    plt."figure" = figure

    if isdefined(Main, :IJulia) && Main.IJulia.inited
        Main.IJulia.push_preexecute_hook(force_new_fig)
        Main.IJulia.push_postexecute_hook(display_figs)
        Main.IJulia.push_posterror_hook(close_figs)
    end

    if isjulia_display[] && gui != :gr && backend != "Agg"
        plt."switch_backend"("Agg")
        plt."ioff"()
    end

    init_colormaps()
end

function pygui(b::Bool)
    if !b != isjulia_display[]
        if backend != "Agg"
            plt."switch_backend"(b ? backend : "Agg")
            if b
                pygui_start(gui) # make sure event loop is started
                Base.isinteractive() && plt."ion"()
            else
                plt."ioff"()
            end
        elseif b
            error("No working GUI backend found for matplotlib.")
        end
        isjulia_display[] = !b
    end
    return b
end
