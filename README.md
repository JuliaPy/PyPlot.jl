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
y = sin(x)

# pop new figure window
figure()

# plot
plot(x, y, :label, L"$sin(x)$")
legend("upper left")
title("\$sin(x)\$")
xlabel("\$x\$")
ylabel("\$y\$")

# save the plot
savefig("demo.png")
```

![screenshot](https://github.com/autozimu/pyplot.jl/raw/master/demo/demo.png)


## Features

* Dynamic usage from Julia terminal
* Excellent math/TeX symbol support
* Multiple export formats (EPS, PDF, PNG, JPEG, ...)

Since this module is simply a wrapper around matplotlib, all credit goes
to matplotlib developers.

## Dependencies

- [Julia](https://github.com/JuliaLang/julia): recent versions (>= 0.1)
  may be required
- [ipython](http://ipython.org/)
- [matplotlib](http://matplotlib.org/)
- [zmq](http://www.zeromq.org/)
- [pyzmq](http://www.zeromq.org/bindings:python)
- [ZMQ.jl](https://github.com/aviks/ZMQ.jl)
- patience :)

## Setup

Install this module by

```bash
git clone https://github.com/autozimu/pyplot.jl ~/.julia/pyplot
```

Now in a Julia session, type

```julia
using pyplot
figure()
```

If a matplotlib window opened up, it should be a successful installation.

## Usage

Most function signatures are same to corresponding functions in pyplot,
except some semantic differences due to the implementation:

* [kwargs][]: use `:color, "red"` for `color="red"`
* escaping characters: use `\\` for `\` to escape characters.
  Alternatively, prefix string with `E`, `I`, or `L` accordingly to
  prevent Julia perform escaping and/or interpolation.
  [[1][Julia_non_standard_string]]

[Demos][demo] should be enough for elementary and medium usage.

[kwargs]: http://rosettacode.org/wiki/Named_parameters
[demo]: https://github.com/autozimu/pyplot.jl/tree/master/demo
[Julia_non_standard_string]: http://docs.julialang.org/en/latest/manual/strings/#non-standard-string-literals

NOTE: the keyword syntax will be changed shortly in the future, with the
introduce of keyword argument in Julia itself. And The string prefix
`E`, `I` and `L` may not work with latest Julia, while the double slash
`\\` will always work.

## Support and Contact

If any questions or comments, feel free to contact <autozimu@gmail.com>.

[Julia]: http://julialang.org/ "The Julia Language"
[matploblib]: http://matplotlib.org/ "matplotlib"
