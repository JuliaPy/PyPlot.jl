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

## Demo

Video version on [YouTube]
(https://www.youtube.com/watch?v=zrPr46xTqbU).


```julia
# load module
using pyplot

# generate data
x = linspace(0, pi, 300)
y = sin(x)

# pop new figure window
figure()

# plot
plot(x, y, label = "\$sin(x)\$")
legend(loc="upper left")
title("\$sin(x)\$")
xlabel("\$x\$")
ylabel("\$y\$")

# save the plot
savefig("test/demo.png")
```

![screenshot](https://github.com/autozimu/pyplot.jl/raw/master/test/demo.png)



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

Most function signatures are same to the corresponding functions in
pyplot. [Tests][test] should be enough for elementary and medium usage.

[test]: https://github.com/autozimu/pyplot.jl/tree/master/test

## Support and Contact

If any questions or comments, feel free to contact <autozimu@gmail.com>.

[Julia]: http://julialang.org/ "The Julia Language"
[matploblib]: http://matplotlib.org/ "matplotlib"
