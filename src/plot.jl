export  mrun,
        mstatus,
        figure,
        fig,
        subplot,
        draw,
        showfig,
        plot,
        plotfile,
        xlim,
        ylim,
        title,
        xlabel,
        ylabel,
        legend,
        clearfig,
        clearax,
        closefig,
        delax,
        hold,
        savefig,
        grid,
        xloc_major,
        xloc_minor,
        xloc,
        yloc_major,
        yloc_minor,
        yloc,
        xformatter_major,
        xfomatter_minor,
        xformatter,
        yformatter_major,
        yformatter_minor,
        yformatter,
        minorticks,
        ticklabel_format,
        tick_params,
        xscale,
        yscale,
        twinx,
        twiny,
        axhline,
        axvline,
        axhspan,
        axvspan

## parse string
function parse(str::String)
    if str == ""
        return ""
    else
        return "\"$str\", "
    end
end

## parse Symbol
function parse(sym::Symbol)
    return "$sym="
end

## parse Array
function parse(arr::Array)
    # return empty string when array is empty
    if arr == []
        return ""
    else
        str = "["
        for a in arr
            str = "$str$a, "
        end
        str = "$str], "
        return str
    end
end

## parse Tuple
function parse(tuple::Tuple)
    # return empty string when tuple is empty
    if tuple == ()
        return ""
    else
        str = "("
        for t in tuple
            if isa(t, String)
                str = "$str\"$t\", "
            else
                str = "$str$t, "
            end
        end
        str = "$str), "
        return str
    end
end

## parse anything else
function parse(args)
    return "$args, "
end

## Toggle debug mode
global DEBUG = false
function debug(state::Bool)
    global DEBUG = state
end
function debug()
    global DEBUG = !DEBUG
end

## run matplotlib commands directly
## TODO: support block parameters
function mrun(cmd::String)
    # using escaped single quoted cmd to
    # avoid confusing system call, ie, shell
    cmd = `$JuliaLab_HOME/eval.py $cmd`
    if DEBUG
        println(cmd)
    end
    run(cmd)
end

## check server status
function mstatus()
    mrun("")
end

## create/activate figure
function figure()
    mrun("figure()")
end
function figure(num::Integer)
    mrun("figure($num)")
end
fig = figure

## subplot
function subplot(num::Integer)
    mrun("subplot($num)")
end
function subplot(numRows::Integer, numCols::Integer, plotNum::Integer)
    mrun("subplot($numRows, $numCols, $plotNum)")
end

## show figure
function showfig()
    mrun("show()")
end
function showfig(num::Integer)
    mrun("show($num)")
end

## clear figure
function clearfig()
    mrun("clf()")
end

## clear axes
function clearax()
    mrun("cla()")
end

## close figure
function closefig()
    mrun("close()")
end
function closefig(num::Integer)
    mrun("close($num)")
end

## delete axes
function delax()
    mrun("delaxes()")
end

## toggle hold state
function hold(state::Bool)
    if state == true
        mrun("hold(True)")
    else
        mrun("hold(False)")
    end
end
function hold()
    mrun("hold()")
end


## redraw figure
function draw()
    mrun("draw()")
end

## save figure
function savefig(file::String)
    mrun("savefig(\"$file\")")
end

## plot two arrays
function plot(x::Array, y::Array, args::Tuple)
    cmd = ""
    cmd = "$cmd$(parse(x))"
    cmd = "$cmd$(parse(y))"
    for i in args
        cmd = "$cmd$(parse(i))"
    end

    mrun("plot($cmd)")
end
plot(x::Array, y::Array, args...) = plot(x, y, args)

## plot single array,  real or complex
function plot(arr::Array, args...)
    if typeof(arr[1]) <: Real
        plot([], arr, args)
    elseif typeof(arr[1]) <: Complex
        asize = size(arr, 1)
        x = Array(Float64, asize)
        y = Array(Float64, asize)
        for i in 1:asize
            x[i] = real(arr[i])
            y[i] = imag(arr[i])
        end
        plot(x, y, args)
    end
end

## plot a function
function plot(f::Function, xmin::Real, xmax::Real, args...)
    _PLOTPOINTS_ = 100
    x = linspace(float(xmin), float(xmax), _PLOTPOINTS_ + 1)
    y = [f(i) for i in x]
    plot(x, y, args)
end

## plotfile
function plotfile(f::String, args...)
    cmd = parse(f)
    for i in args
        cmd = "$cmd$(parse(i))"
    end
    mrun("plotfile($cmd)")
end


## set xlim
function xlim(xmin::Real, xmax::Real)
    mrun("xlim($xmin, $xmax)")
end

## set ylim
function ylim(ymin::Real, ymax::Real)
    mrun("ylim($ymin, $ymax)")
end

## set title
function title(s::String)
    mrun("title(\"$s\")")
end

## set xlabel
function xlabel(s::String)
    mrun("xlabel(\"$s\")")
end

## set ylabel
function ylabel(s::String)
    mrun("ylabel(\"$s\")")
end

## set/show legend
function legend(labels::Tuple, loc::String)
    labels = parse(labels)
    if loc == ""
        loc = ""
    else
        loc = "loc=$(parse(loc))"
    end
    mrun("legend($labels$loc)")
end
legend(loc::String) = legend((), loc)
legend(labels::Tuple) = legend(labels, "")
legend() = legend((), "")

## turn grid on/off
function grid(b::Bool)
    if b == true
        mrun("grid(True)")
    else
        mrun("grid(False)")
    end
end
function grid()
    mrun("grid()")
end

## set axis locator
function xloc_major(loc::Real)
    mrun("gca().xaxis.set_major_locator(MultipleLocator($loc))")
    mrun("draw()")
end
function xloc_minor(loc::Real)
    mrun("gca().xaxis.set_minor_locator(MultipleLocator($loc))")
    mrun("draw()")
end
xloc(loc::Real) = xloc_major(loc)
function yloc_major(loc::Real)
    mrun("gca().yaxis.set_major_locator(MultipleLocator($loc))")
    mrun("draw()")
end
function yloc_minor(loc::Real)
    mrun("gca().yaxis.set_minor_locator(MultipleLocator($loc))")
    mrun("draw()")
end
yloc(loc::Real) = yloc_major(loc)

## set axis formatter
function xformatter_major(formatter::String)
    mrun("gca().xaxis.set_major_formatter(FormatStrFormatter(\"$formatter\"))")
    mrun("draw()")
end
function xformatter_minor(formatter::String)
    mrun("gca().xaxis.set_minor_formatter(FormatStrFormatter(\"$formatter\"))")
    mrun("draw()")
end
xformatter(formatter::String) = xformatter_major(formatter)
function yformatter_major(formatter::String)
    mrun("gca().yaxis.set_major_formatter(FormatStrFormatter(\"$formatter\"))")
    mrun("draw()")
end
function yformatter_minor(formatter::String)
    mrun("gca().yaxis.set_minor_formatter(FormatStrFormatter(\"$formatter\"))")
    mrun("draw()")
end
yformatter(formatter::String) = yformatter_major(formatter)

## True on/off minorticks
function minorticks(state::Bool)
    if state == true
        mrun("minorticks_on()")
    else
        mrun("minorticks_off()")
    end
end

## Change appearance of ticks and tick labels
function tick_params(args...)
    cmd = ""
    for i in args
        cmd = "$cmd$(parse(i))"
    end
    mrun("tick_params($cmd)")
end

## Change label format
function ticklabel_format(args...)
    cmd = ""
    for i in args
        cmd = "$cmd$(parse(i))"
    end
    mrun("ticklabel_format($cmd)")
end

## set axis scale
function xscale(scaletype::String)
    mrun("xscale(\"$scaletype\")")
end
function yscale(scaletype::String)
    mrun("yscale(\"$scaletype\")")
end

## twin x/y
function twinx()
    mrun("twinx()")
end
function twiny()
    mrun("twiny()")
end

## draw horizontal/vertical line/rectangle across axes
function axhline(y::Real, xmin::Real, xmax::Real)
    mrun("axhline(y=$y, xmin=$xmin, xmax=$xmax)")
end
function axvline(x::Real, ymin::Real, xmax::Real)
    mrun("axvline(x=$x, ymin=$ymin, ymax=$ymax")
end
function axhspan(xmin::Real, xmax::Real, ymin::Real, ymax::Real)
    mrun("axhspan(xmin, xmax, ymin=$ymin, ymax=$ymax)")
end
function axvspan(xmin::Real, xmax::Real, ymin::Real, ymax::Real)
    mrun("axvspan(xmin, xmax, ymin=$ymin, ymax=$ymax)")
end

## test
function mtest()
    load("../examples/1-plot.jl")
    load("../examples/2-subplot.jl")
    #load("../examples/3-plotfile.jl")
    load("../4-control-details.jl")
end
