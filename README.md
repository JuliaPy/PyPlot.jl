# The PyPlot module for Julia

This module provides a Julia interface to the
[Matplotlib](http://matplotlib.org/) plotting library from Python, and
specifically to the `matplotlib.pyplot` module.

PyPlot uses the Julia [PyCall](https://github.com/stevengj/PyCall.jl)
package to call Matplotlib directly from Julia with little or no
overhead (arrays are passed without making a copy).

This package takes advantage of Julia's [multimedia
I/O](http://docs.julialang.org/en/latest/stdlib/base/#multimedia-i-o)
API to display plots in any Julia graphical backend, including as
inline graphics in [IJulia](https://github.com/JuliaLang/IJulia.jl).
Alternatively, you can use a Python-based graphical Matplotlib
backend to support interactive plot zooming etcetera.

(This PyPlot package replaces an earlier package of the same name by
[Junfeng Li](https://github.com/autozimu/), which used PyPlot over a
ZeroMQ socket with IPython.)

## Installation

You will need to have the Python [Matplotlib](http://matplotlib.org/)
library installed on your machine in order to use PyPlot.

Once Matplotlib is installed, then you can just use
`Pkg.add("PyPlot")` in Julia to install PyPlot and its dependencies.

**Note:** Julia version 0.2 (or a recent pre-release version thereof)
is required to use PyPlot.

## Basic usage

Once Matplotlib and PyPlot is installed, and you are using a
graphics-capable Julia environment such as IJulia, you can simply type
`using PyPlot` and begin calling functions in the
[matplotlib.pyplot](http://matplotlib.org/api/pyplot_api.html) API.
For example:

```
using PyPlot
x = linspace(0,2*pi,1000); y = sin(3*x + 4*cos(2*x));
plot(x, y, color="red", linewidth=2.0, linestyle="--")
title("A sinusoidally modulated sinusoid")
```

In general, all of the arguments, including keyword arguments, are
exactly the same as in Python.  (With minor translations, of course,
e.g. Julia uses `true` and `nothing` instead of Python's `True` and
`None`.)

The full `matplotlib.pyplot` API is far too extensive to describe here;
see the [matplotlib.pyplot documentation for more
information](http://matplotlib.org/api/pyplot_api.html)

### Exported functions

Only the currently documented `matplotlib.pyplot` API is exported.  To use
other functions in the module, you can also call `matplotlib.pyplot.foo(...)`
as `plt.foo(...)`.  For example, `plt.plot(x, y)` also works.  (And
the raw `PyObject`s for the `matplotlib` and `pyplot` modules are accessible
as `PyPlot.matplotlib` and `PyPlot.pltm`, respectively.)

You must also use `plt` to access some functions that conflict with
built-in Julia functions.  In particular, `plt.hist` and `plt.xcorr`
must be used to access `matplotlib.pyplot.hist` and
`matplotlib.pyplot.xcorr`, respectively.

If you wish to access *all* of the PyPlot functions exclusively
through `plt.somefunction(...)`, as is conventional in Python, simply
do `import PyPlot.plt` instead of `using PyPlot`.

### Figure objects

You can get the current figure as a `Figure` object (a wrapper
around `matplotlib.pyplot.Figure`) by calling `gcf()`.  

The `Figure` type supports Julia's [multimedia I/O
API](http://docs.julialang.org/en/latest/stdlib/base/#multimedia-i-o),
so you can use `display(fig)` to show a `fig::PyFigure` and
`writemime(io, mime, fig)` to write it to a given `mime` type string
(e.g. `"image/png"` or `"application/pdf"`) that is supported by the
Matplotlib backend.

## Interactive versus Julia graphics

PyPlot can use any Julia graphics backend capable of displaying PNG,
SVG, or PDF images, such as the IJulia environment.  To use a
different backend, simply call `pushdisplay` with the desired
`Display`; see the [Julia multimedia display
API](http://docs.julialang.org/en/latest/stdlib/base/#multimedia-i-o)
for more detail.

On the other hand, you may wish to use one of the Python Matplotlib
backends to open an interactive window for each plot (for interactive
zooming, panning, etcetera).  You can do this at any time by running:
```
pygui(true)
```
to turn on the Python-based GUI (if possible) for subsequent plots,
while `pygui(false)` will return to the Julia backend.  Even when a
Python GUI is running, you can display the current figure with the
Julia backend by running `display(gcf())`.

If no Julia graphics backend is available when PyPlot is imported, then
`pygui(true)` is the default.

### Choosing a Python GUI toolkit

Only the [wxWidgets](http://www.wxwidgets.org/),
[GTK+](http://www.gtk.org/), and [Qt](http://qt-project.org/) (via the
[PyQt4](http://wiki.python.org/moin/PyQt4) or
[PySide](http://qt-project.org/wiki/PySide), Python GUI backends are
supported by PyPlot.  (Obviously, you must have installed one of these
toolkits for Python first.)  By default, PyPlot picks one of these
when it starts up (based on what you have installed), but you can
force a specific toolkit to be chosen by importing the PyCall module
and using its `pygui` function to set a Python backend *before*
importing PyPlot:
```
using PyCall
pygui(gui)
using PyPlot
```
where `gui` can currently be one of `:wx`, `:gtk`, or `:qt`.

## Color maps

The PyPlot module also exports some functions and types based on the
[matplotlib.colors](http://matplotlib.org/api/colors_api.html) and
[matplotlib.cm](http://matplotlib.org/api/cm_api.html) modules to
simplify management of color maps (which are used to assign values to
colors in various plot types).  In particular:

* `ColorMap`: a wrapper around the [matplotlib.colors.Colormap](http://matplotlib.org/api/colors_api.html#matplotlib.colors.Colormap) type.  The following constructors are provided:

  * `ColorMap{T<:ColorValue}(name::String, c::AbstractVector{T}, n=256, gamma=1.0)` constructs an `n`-component colormap by [linearly interpolating](http://matplotlib.org/api/colors_api.html#matplotlib.colors.LinearSegmentedColormap) the colors in the array `c` of `ColorValue`s (from the [Color.jl](https://github.com/JuliaLang/Color.jl) package).  If you want a `name` to be constructed automatically, call `ColorMap(c, n=256, gamma=1.0)` instead.

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
[mplot3d](http://matplotlib.org/dev/mpl_toolkits/mplot3d/) toolkit.
Unlike Matplotlib, however, you can create 3d plots directly without
first creating an
[Axes3d](http://matplotlib.org/dev/mpl_toolkits/mplot3d/api.html#axes3d)
object, simply by calling one of: `bar3D`, `contour3D`, `contourf3D`,
`plot3D`, `plot_surface`, `plot_trisurf`, `plot_wireframe`, or
`scatter3D` (as well as `text2D`, `text3D`), exactly like the
correspondingly named methods of
[Axes3d](http://matplotlib.org/dev/mpl_toolkits/mplot3d/api.html#axes3d).
We also export the Matlab-like synonyms `surf` for `plot_surface` (or
`plot_trisurf` for 1d-array arguments) and `mesh` for
`plot_wireframe`.  For example, you can do:
```
surf(rand(30,40))
```
to plot a random 30×40 surface mesh.

You can also explicitly create a subplot with 3d axes via, for
example, `subplot(111, projection="3d")`, exactly as in Matplotlib.
The `Axes3d` constructor and the
[art3d](http://matplotlib.org/dev/mpl_toolkits/mplot3d/api.html#art3d)
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

To simplify this, PyPlot provides a new `LaTeXString` type which can
be constructed via `L"...."` without escaping backslashes or dollar
signs.  For example, one can simply write `L"$\alpha + \beta$"` for the
abovementioned equation, and thus you can do things like:
```
title(L"Plot of $\Gamma_3(x)$")
```
(As an added benefit, a `LaTeXString` is
automatically displayed as a rendered equation in IJulia.) 

## Author

This module was written by [Steven G. Johnson](http://math.mit.edu/~stevenj/).
