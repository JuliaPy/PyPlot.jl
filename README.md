[![CI](https://github.com/JuliaPy/PyPlot.jl/workflows/CI/badge.svg)](https://github.com/JuliaPy/PyPlot.jl/actions?query=workflow%3ACI)

# The PyPlot module for Julia

This module provides a Julia interface to the
[Matplotlib](http://matplotlib.org/) plotting library from Python, and
specifically to the `matplotlib.pyplot` module.

PyPlot uses the Julia [PyCall](https://github.com/stevengj/PyCall.jl)
package to call Matplotlib directly from Julia with little or no
overhead (arrays are passed without making a copy).  (See also [PythonPlot.jl](https://github.com/stevengj/PythonPlot.jl) for a version of PyPlot.jl using the alternative [PythonCall.jl](https://github.com/cjdoris/PythonCall.jl) package.)

This package takes advantage of Julia's [multimedia
I/O](https://docs.julialang.org/en/latest/base/io-network/#Multimedia-I/O-1)
API to display plots in any Julia graphical backend, including as
inline graphics in [IJulia](https://github.com/JuliaLang/IJulia.jl).
Alternatively, you can use a Python-based graphical Matplotlib
backend to support interactive plot zooming etcetera.

(This PyPlot package replaces an earlier package of the same name by
[Junfeng Li](https://github.com/autozimu/), which used PyPlot over a
ZeroMQ socket with IPython.)

## Installation

You will need to have the Python [Matplotlib](http://matplotlib.org/)
library installed on your machine in order to use PyPlot.  You can either
do inline plotting with [IJulia](https://github.com/JuliaLang/IJulia.jl),
which doesn't require a GUI backend, or use the Qt, wx, or GTK+ backends
of Matplotlib as described below.

Once Matplotlib is installed, then you can just use
`Pkg.add("PyPlot")` in Julia to install PyPlot and its dependencies.

### Automated Matplotlib installation

If you set up PyCall to use the
[Conda.jl](https://github.com/Luthaf/Conda.jl) package to install a
private (not in the system `PATH`) Julia Python distribution (via
Miniconda), then PyPlot will automatically install Matplotlib as needed.

If you are installing PyCall and PyPlot for the first time, just do `ENV["PYTHON"]=""` before running `Pkg.add("PyPlot")`.  Otherwise, you can reconfigure PyCall to use Conda via:
```julia
ENV["PYTHON"]=""
Pkg.build("PyCall")
```
The next time you import `PyPlot`, it will tell Conda to install Matplotlib.

### OS X

On MacOS, you should either install
[XQuartz](http://xquartz.macosforge.org/landing/) for MacOS 10.9 or
later or install the [Anaconda](http://continuum.io/downloads) Python
distribution in order to get a fully functional PyPlot.

MacOS 10.9 comes with Python and Matplotlib, but this version of
Matplotlib defaults to with the Cocoa GUI backend, which is [not
supported by PyPlot](https://github.com/stevengj/PyPlot.jl/issues/11).
It also has a Tk backend, which is supported, but the Tk backend does
not work unless you install XQuartz.

Alternatively, you can install the
[Anaconda](http://continuum.io/downloads) Python distribution
(which also includes `ipython` and other IJulia dependencies).

Otherwise, you can use the [Homebrew](http://brew.sh/) package manager:
```sh
brew install python gcc freetype pyqt
brew link --force freetype
export PATH="/usr/local/bin:$PATH"
export PYTHONPATH="/usr/local/lib/python2.7:$PYTHONPATH"
pip install numpy scipy matplotlib
```
(You may want to add the two `export` commands to your `~/.profile` file so that they
are automatically executed whenever you start a shell.)

## Basic usage

Once Matplotlib and PyPlot are installed, and you are using a
graphics-capable Julia environment such as IJulia, you can simply type
`using PyPlot` and begin calling functions in the
[matplotlib.pyplot](http://matplotlib.org/api/pyplot_api.html) API.
For example:

```julia
using PyPlot
# use x = linspace(0,2*pi,1000) in Julia 0.6
x = range(0; stop=2*pi, length=1000); y = sin.(3 * x + 4 * cos.(2 * x));
plot(x, y, color="red", linewidth=2.0, linestyle="--")
title("A sinusoidally modulated sinusoid")
```

In general, all of the arguments, including keyword arguments, are
exactly the same as in Python.  (With minor translations, of course,
e.g. Julia uses `true` and `nothing` instead of Python's `True` and
`None`.)

The full `matplotlib.pyplot` API is far too extensive to describe here;
see the [matplotlib.pyplot documentation for more
information](http://matplotlib.org/api/pyplot_api.html).  The Matplotlib
version number is returned by `PyPlot.version`.

### Exported functions

Only the currently documented `matplotlib.pyplot` API is exported.  To use
other functions in the module, you can also call `matplotlib.pyplot.foo(...)`
as `plt.foo(...)`.  For example, `plt.plot(x, y)` also works.  (And
the raw `PyObject` for the `matplotlib` modules is also accessible
as `PyPlot.matplotlib`.)

Matplotlib is somewhat inconsistent about capitalization: it has
`contour3D` but `bar3d`, etcetera.  PyPlot renames all such functions
to use a capital *D* (e.g. it has `hist2D`, `bar3D`, and so on).

You must also explicitly qualify some functions
built-in Julia functions.  In particular, `PyPlot.xcorr`,
`PyPlot.axes`, and `PyPlot.isinteractive`
must be used to access `matplotlib.pyplot.xcorr`
etcetera.

If you wish to access *all* of the PyPlot functions exclusively
through `plt.somefunction(...)`, as is conventional in Python, you can
do `import PyPlot; const plt = PyPlot` instead of `using PyPlot`.

### Figure objects

You can get the current figure as a `Figure` object (a wrapper
around `matplotlib.pyplot.Figure`) by calling `gcf()`.

The `Figure` type supports Julia's [multimedia I/O
API](https://docs.julialang.org/en/latest/base/io-network/#Multimedia-I/O-1),
so you can use `display(fig)` to show a `fig::PyFigure` and
`show(io, mime, fig)` (or `writemime` in Julia 0.4) to write it to a given `mime` type string
(e.g. `"image/png"` or `"application/pdf"`) that is supported by the
Matplotlib backend.

## Non-interactive plotting

If you use PyPlot from an interactive Julia prompt, such as the Julia
[command-line prompt](http://docs.julialang.org/en/latest/manual/interacting-with-julia/)
or an IJulia notebook, then plots appear immediately after a plotting
function (`plot` etc.) is evaluated.

However, if you use PyPlot from a Julia script that is run non-interactively
(e.g. `julia myscript.jl`), then Matplotlib is executed in
[non-interactive mode](http://matplotlib.org/faq/usage_faq.html#what-is-interactive-mode):
a plot window is not opened until you run `show()` (equivalent to `plt.show()`
in the Python examples).

## Interactive versus Julia graphics

PyPlot can use any Julia graphics backend capable of displaying PNG,
SVG, or PDF images, such as the IJulia environment.  To use a
different backend, simply call `pushdisplay` with the desired
`Display`; see the [Julia multimedia display
API](https://docs.julialang.org/en/latest/base/io-network/#Multimedia-I/O-1)
for more detail.

On the other hand, you may wish to use one of the Python Matplotlib
backends to open an interactive window for each plot (for interactive
zooming, panning, etcetera).  You can do this at any time by running:
```julia
pygui(true)
```
to turn on the Python-based GUI (if possible) for subsequent plots,
while `pygui(false)` will return to the Julia backend.  Even when a
Python GUI is running, you can display the current figure with the
Julia backend by running `display(gcf())`.

If no Julia graphics backend is available when PyPlot is imported, then
`pygui(true)` is the default.

### Choosing a Python GUI toolkit

Only the [Tk](http://www.tcl.tk/), [wxWidgets](http://www.wxwidgets.org/),
[GTK+](http://www.gtk.org/) (version 2 or 3), and [Qt](http://qt-project.org/) (version 4 or 5; via the PyQt5,
[PyQt4](http://wiki.python.org/moin/PyQt4) or
[PySide](http://qt-project.org/wiki/PySide)), Python GUI backends are
supported by PyPlot.  (Obviously, you must have installed one of these
toolkits for Python first.)  By default, PyPlot picks one of these
when it starts up (based on what you have installed), but you can
force a specific toolkit to be chosen by importing the PyCall module
and using its `pygui` function to set a Python backend *before*
importing PyPlot:
```julia
using PyCall
pygui(gui)
using PyPlot
```
where `gui` can currently be one of `:tk`, `:gtk3`, `:gtk`, `:qt5`, `:qt4`, `:qt`, or `:wx`. You can
also set a default via the Matplotlib `rcParams['backend']` parameter in your
[matplotlibrc](http://matplotlib.org/users/customizing.html) file.

## Color maps

The PyPlot module also exports some functions and types based on the
[matplotlib.colors](http://matplotlib.org/api/colors_api.html) and
[matplotlib.cm](http://matplotlib.org/api/cm_api.html) modules to
simplify management of color maps (which are used to assign values to
colors in various plot types).  In particular:

* `ColorMap`: a wrapper around the [matplotlib.colors.Colormap](http://matplotlib.org/api/colors_api.html#matplotlib.colors.Colormap) type.  The following constructors are provided:

  * `ColorMap{T<:Colorant}(name::String, c::AbstractVector{T}, n=256, gamma=1.0)` constructs an `n`-component colormap by [linearly interpolating](http://matplotlib.org/api/colors_api.html#matplotlib.colors.LinearSegmentedColormap) the colors in the array `c` of `Colorant`s (from the [ColorTypes.jl](https://github.com/JuliaGraphics/ColorTypes.jl) package).  If you want a `name` to be constructed automatically, call `ColorMap(c, n=256, gamma=1.0)` instead.  Alternatively, instead of passing an array of colors, you can pass a 3- or 4-column matrix of RGB or RGBA components, respectively (similar to [ListedColorMap](http://matplotlib.org/api/colors_api.html#matplotlib.colors.ListedColormap) in Matplotlib).

  * Even more general color maps may be defined by passing arrays of (x,y0,y1) tuples for the red, green, blue, and (optionally) alpha components, as defined by the [matplotlib.colors.LinearSegmentedColormap](http://matplotlib.org/api/colors_api.html#matplotlib.colors.LinearSegmentedColormap) constructor, via: `ColorMap{T<:Real}(name::String, r::AbstractVector{(T,T,T)}, g::AbstractVector{(T,T,T)}, b::AbstractVector{(T,T,T)}, n=256, gamma=1.0)` or `ColorMap{T<:Real}(name::String, r::AbstractVector{(T,T,T)}, g::AbstractVector{(T,T,T)}, b::AbstractVector{(T,T,T)}, alpha::AbstractVector{(T,T,T)}, n=256, gamma=1.0)`

  * `ColorMap(name::String)` returns an existing (registered) colormap, equivalent to [matplotlib.cm.get_cmap](http://matplotlib.org/api/cm_api.html#matplotlib.cm.get_cmap)(`name`).

  * `matplotlib.colors.Colormap` objects returned by Python functions are automatically converted to the `ColorMap` type.

* `get_cmap(name::String)` or `get_cmap(name::String, lut::Integer)` call the [matplotlib.cm.get_cmap](http://matplotlib.org/api/cm_api.html#matplotlib.cm.get_cmap) function.

* `register_cmap(c::ColorMap)` or `register_cmap(name::String, c::ColorMap)` call the [matplotlib.cm.register_cmap](http://matplotlib.org/api/cm_api.html#matplotlib.cm.register_cmap) function.

* `get_cmaps()` returns a `Vector{ColorMap}` of the currently
  registered colormaps.

Note that, given an SVG-supporting display environment like IJulia,
`ColorMap` and `Vector{ColorMap}` objects are displayed graphically;
try `get_cmaps()`!

## 3d Plotting

The PyPlot package also imports functions from Matplotlib's
[mplot3d](http://matplotlib.org/mpl_toolkits/mplot3d/) toolkit.
Unlike Matplotlib, however, you can create 3d plots directly without
first creating an
[Axes3d](http://matplotlib.org/mpl_toolkits/mplot3d/api.html#axes3d)
object, simply by calling one of: `bar3D`, `contour3D`, `contourf3D`,
`plot3D`, `plot_surface`, `plot_trisurf`, `plot_wireframe`, or
`scatter3D` (as well as `text2D`, `text3D`), exactly like the
correspondingly named methods of
[Axes3d](http://matplotlib.org/mpl_toolkits/mplot3d/api.html#axes3d).
We also export the Matlab-like synonyms `surf` for `plot_surface` (or
`plot_trisurf` for 1d-array arguments) and `mesh` for
`plot_wireframe`.  For example, you can do:
```julia
surf(rand(30,40))
```
to plot a random 30×40 surface mesh.

You can also explicitly create a subplot with 3d axes via, for
example, `subplot(111, projection="3d")`, exactly as in Matplotlib,
but you must first call the `using3D()` function to ensure that
mplot3d is loaded (this happens automatically for `plot3D` etc.).
The `Axes3D` constructor and the
[art3D](http://matplotlib.org/mpl_toolkits/mplot3d/api.html#art3d)
module are also exported.

## LaTeX plot labels

Matplotlib allows you to [use LaTeX equations in plot
labels](http://matplotlib.org/users/mathtext.html), titles, and so on
simply by enclosing the equations in dollar signs (`$ ... $`) within
the string.  However, typing LaTeX equations in Julia string literals
is awkward because escaping is necessary to prevent Julia from
interpreting the dollar signs and backslashes itself; for example, the
LaTeX equation `$\alpha + \beta$` would be the literal string
`"\$\\alpha + \\beta\$"` in Julia.

To simplify this, PyPlot uses the [LaTeXStrings package](https://github.com/stevengj/LaTeXStrings.jl) to provide a new `LaTeXString` type that
be constructed via `L"...."` without escaping backslashes or dollar
signs.  For example, one can simply write `L"$\alpha + \beta$"` for the
abovementioned equation, and thus you can do things like:
```jl
title(L"Plot of $\Gamma_3(x)$")
```
If your string contains *only* equations, you can omit the dollar
signs, e.g. `L"\alpha + \beta"`, and they will be added automatically.
As an added benefit, a `LaTeXString` is automatically displayed as a
rendered equation in IJulia.  See the LaTeXStrings package for more
information.

## SVG output in IJulia

By default, plots in IJulia are sent to the notebook as PNG images.
Optionally, you can tell PyPlot to display plots in the browser as
[SVG](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics) images,
which have the advantage of being resolution-independent (so that they
display without pixellation at high-resolutions, for example if you
convert an IJulia notebook to PDF), by running:
```julia
PyPlot.svg(true)
```
This is not the default because SVG plots in the browser are much
slower to display (especially for complex plots) and may display
inaccurately in some browsers with buggy SVG support.  The `PyPlot.svg()`
method returns whether SVG display is currently enabled.

Note that this is entirely separate from manually exporting plots to SVG
or any other format.  Regardless of whether PyPlot uses SVG for
browser display, you can export a plot to SVG at any time by using the
Matplotlib
[savefig](http://matplotlib.org/api/pyplot_api.html#matplotlib.pyplot.savefig)
command, e.g. `savefig("plot.svg")`.

## Modifying matplotlib.rcParams
You can mutate the `rcParams` dictionary that Matplotlib uses for global parameters following this example:
```julia
rcParams = PyPlot.PyDict(PyPlot.matplotlib."rcParams")
rcParams["font.size"] = 15
```
(If you instead used `PyPlot.matplotlib.rcParams`, PyCall would make a copy of the dictionary
so that the Python `rcParams` wouldn't be modified.)

## Author

This module was written by [Steven G. Johnson](http://math.mit.edu/~stevenj/).
