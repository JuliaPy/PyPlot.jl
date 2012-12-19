## Example

    require("pyplot")
    using pyplot

    x = linspace(-pi, pi)
    y = sin(x)

    plot(x, y)
    title(E"$sin(x)$")
    savefig("sin.png")
    # savefig("sin.pdf")

![screenshot](https://github.com/autozimu/pyplot.jl/raw/screenshot/sin.png)


## What

Graphical solution for [Julia][] based on [matploblib][], mainly the pyplot
module.


## Why

The Julia team seems to prefer graphics solutions that started from
ground up, and the standard solution has not been decided yet. I just
cannot wait that long, so I started my own.


[Julia]: http://julialang.org/ "The Julia Language"
[matploblib]: http://matplotlib.org/ "matplotlib"
