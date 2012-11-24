export mrun, mstatus, figure, fig, subplot, draw, showfig, plot, plotfile,  xlim, ylim, title, xlabel, ylabel, legend, clearfig, clearax, closefig, delax, hold, savefig, grid, xloc_major, xloc_minor, xloc, yloc_major, yloc_minor, yloc, xformatter_major, xfomatter_minor, xformatter, yformatter_major, yformatter_minor, yformatter, minorticks, ticklabel_format, tick_params, xscale, yscale, twinx, twiny, axhline, axvline, axhspan, axvspan


## translate array
function trans_arr(arr::Array)
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

## translate tuple
function trans_tuple(tuple::Tuple)
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


## translate args syntax
## `:linewidth, 2` will be translated to `linewidth=2, `
## `:label, "sin(x)"` will be translated to `label=\"sin(x)\"`
## return 1 when come up with errors!
function trans_args(args::Tuple)
    # check number of arguments
    if rem(length(args), 2) == 1
        println("Syntax Error: symbols and parameters should in pair!")
        return 1
    end

    cmd = ""
    for i = 1:2:length(args)
        if !isa(args[i], Symbol)
            println("Syntax Error: args should use Symbol!")
            return 1
        end

        if isa(args[i+1], String)
            cmd = "$cmd$(args[i])=\"$(args[i+1])\", "
        elseif isa(args[i+1], Tuple)
            cmd = "$cmd$(args[i])=$(trans_tuple(args[i+1]))"
        else
            cmd = "$cmd$(args[i])=$(args[i+1]), "
        end
    end

    return cmd
end

global DEBUG = false
function debug(state::Bool)
    global DEBUG = state
end
function debug()
    global DEBUG = !DEBUG
end

## run matplotlib commands, to adjust figure ditail, like ticks
## TODO: support block parameters
function mrun(cmd::String)
    # using escaped single quoted cmd to
    # avoid confusing system call, ie, shell
    cmd = "$JuliaLab_HOME/eval.py \'$cmd\'"
    if DEBUG
        println(cmd)
    end
    system(cmd)
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

## main plot function
function plot(x::Array, y::Array, args::Tuple)
    # convert to float

    # check array dimension
    if ndims(x) != 1 || ndims(y) != 1
        println("SyntaxError: input arrays should be of one dimension!")
        return
    end

    cmd = "plot("
    # translate x, y
    cmd = "$cmd$(trans_arr(x))"
    cmd = "$cmd$(trans_arr(y))"

    # translate args
    if (args = trans_args(args)) != 1
        cmd = "$cmd$args"
    else
        return
    end

    cmd = "$cmd)"
    mrun(cmd)
end
## plot two array
## syntax: plot(x, y, :option, parameters)
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
_PLOTPOINTS_ = 100
function plot(f::Function, xmin::Real, xmax::Real, args...)
        x = linspace(float(xmin), float(xmax), _PLOTPOINTS_ + 1)
        y = [f(i) for i in x]
        plot(x, y, args)
end

## plotfile
function plotfile(f::String, args::Tuple)
    cmd = "plotfile(\"$f\", "

    # translate arguments
    if (args = trans_args(args)) != 1
        cmd = "$cmd$args"
    else
        return
    end

    cmd = "$cmd)"
    mrun(cmd)
end
plotfile(f::String, args...) = plotfile(f, args)


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
    labels = trans_tuple(labels)

    if loc == ""
        loc = ""
    else
        loc = "loc=\"$loc\""
    end

    cmd = "legend($labels$loc)"
    mrun(cmd)
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
    if loc <= 0
        println("ValueError: loc should be greater than 0")
    end
    mrun("gca().xaxis.set_major_locator(MultipleLocator($loc))")
    mrun("draw()")
end
function xloc_minor(loc::Real)
    if loc <= 0
        println("ValueError: loc should be greater than 0")
    end
    mrun("gca().xaxis.set_minor_locator(MultipleLocator($loc))")
    mrun("draw()")
end
xloc(loc::Real) = xloc_major(loc)
function yloc_major(loc::Real)
    if loc <= 0
        println("ValueError: loc should be greater than 0")
    end
    mrun("gca().yaxis.set_major_locator(MultipleLocator($loc))")
    mrun("draw()")
end
function yloc_minor(loc::Real)
    if loc <= 0
        println("ValueError: loc should be greater than 0")
    end
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
function tick_params(args::Tuple)
    args = trans_args(args)
    cmd = "tick_params($args)"
    mrun(cmd)
end
tick_params(args...) = tick_params(args)

## Change label format
function ticklabel_format(args::Tuple)
    args = trans_args(args)
    cmd = "ticklabel_format($args)"
    mrun(cmd)
end
ticklabel_format(args...) = ticklabel_format(args)

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

# draw horizontal/vertical line/rectangle across axes
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
