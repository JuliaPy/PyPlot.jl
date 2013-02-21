## What

Graphics solution for [Julia][] based on [matploblib][], mainly the pyplot
module.


## Why

The Julia community seems to be having a discussion over which approach
should be used as the default graphics solution [[1][graphics-wiki]]
[[2][graphics-gg]], and it may take a longer time for a mature solution to
emerge. I just cannot wait that long, so I started my own.

[graphics-wiki]: https://github.com/JuliaLang/julia/wiki/Graphics
[graphics-gg]: https://groups.google.com/forum/?fromgroups=#!searchin/julia-dev/plot$20interface/julia-dev/Mi44lkCusCw/u3B3KZx0BO0J

## Example

```julia
# load module
using pyplot

# generate data
x = linspace(0, pi, 300)
s = sin(x)

# pop new figure window
figure()

# plot
plot(x, s, :label, L"$sin(x)$")
legend("upper left")
title(L"$sin(x)$")
xlabel(L"$x$")
ylabel(L"$y$")

# save the plot
savefig("demo.png")
```

![screenshot](https://github.com/autozimu/pyplot.jl/raw/master/demo/demo.png)


## Features


* perfect 2D plot
* interactive usage
* excellent math symbol support
* multiple backends (PNG, PDF, JPEG, ...)

Since this module is simply a wrapper for matplotlib, all credit goes
to matplotlib developers.

## Prerequirements

* [Julia](https://github.com/JuliaLang/julia): recent versions (>= 0.1) may be required.
* [zmq](http://www.zeromq.org/): version 2.x only due to [ZMQ.jl](https://github.com/aviks/ZMQ.jl)
* [daemon](http://libslack.org/daemon/)
* [ipython](http://ipython.org/) +
[matplotlib](http://matplotlib.org/) +
[pyzmq](https://github.com/zeromq/pyzmq)
* patience :)

## Setup

In julia session, install module dependencies by

```julia
require("Pkg")
Pkg.add("ZMQ")
```

Install this module by

```bash
git clone https://github.com/autozimu/pyplot.jl ~/.julia/pyplot
```

Now in julia session,

```julia
require("pyplot")
pyplot.figure()
```

If matplotlib window opened up, then it should be a successful
installation.

## Usage

Mostly, the function signature is the same as calling pyplot in python /
ipython, except some semantic differences due to the implementation:

* [kwargs][]: use `:color, "red"` for `color="red"`
* escaping characters: use `\\` for `\` to escape characters.
  Alternatively, prefix string with `E`, `I`, or `L` accordingly to
  prevent Julia perform escaping and/or interpolation.
  [[1][Julia_non_standard_string]]

[Demos][demo] should be enough for elementary and medium usage.

[kwargs]: http://rosettacode.org/wiki/Named_parameters
[demo]: https://github.com/autozimu/pyplot.jl/tree/master/demo
[Julia_non_standard_string]: http://docs.julialang.org/en/latest/manual/strings/#non-standard-string-literals

## Limitation

* UTF-8 string is not supported.

## Support and Contact

If any questions or comments, feel free to contact <autozimu@gmail.com>.

[Julia]: http://julialang.org/ "The Julia Language"
[matploblib]: http://matplotlib.org/ "matplotlib"
