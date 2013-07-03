## What

Graphics solution for [Julia][] based on [matploblib][], mainly the pyplot
module.

[Julia]: http://julialang.org/ "The Julia Language"
[matploblib]: http://matplotlib.org/ "matplotlib"

## Demo

<a href="http://youtu.be/XCQeqiHixQ0"><img
src="https://raw.github.com/autozimu/PyPlot.jl/gh-pages/youtube-screenshot.png"/></a>


## Features

- Interactive usage from Julia REPL
- Excellent math/TeX symbols support
- Multiple export formats (EPS, PDF, PNG, JPEG, ...)

Since this module is simply a wrapper around matplotlib, all credit goes
to matplotlib developers.

## Dependencies

- [zmq](http://www.zeromq.org/)
- [pyzmq](https://github.com/zeromq/pyzmq)
- [matplotlib](http://matplotlib.org/)
- [ipython](http://ipython.org/)
- patience :)

## Install

Typing following lines in a Julia session,

```julia
Pkg.add("PyPlot")
```

Now, typing

```julia
using PyPlot
figure()
```

If a matplotlib window opened up, it should be a successful installation.

## Usage

Most function signatures are same to the corresponding functions in
pyplot. [Tests][] should be enough for elementary and medium usage.

[Tests]: https://github.com/autozimu/PyPlot.jl/tree/master/test

## Support and Contact

If any questions or comments, feel free to contact <autozimu@gmail.com>.

## TODO

- doc.
