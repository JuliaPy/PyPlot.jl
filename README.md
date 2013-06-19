## What

Graphics solution for [Julia][] based on [matploblib][], mainly the pyplot
module.

## Demo

<a href="http://youtu.be/XCQeqiHixQ0"><img
src="https://raw.github.com/autozimu/Pyplot.jl/master/youtube-screenshot.png"/></a>


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
git clone https://github.com/autozimu/Pyplot.jl ~/.julia/Pyplot
```

Now in a Julia session, type

```julia
using Pyplot
figure()
```

If a matplotlib window opened up, it should be a successful installation.

## Usage

Most function signatures are same to the corresponding functions in
pyplot. [Tests][test] should be enough for elementary and medium usage.

[test]: https://github.com/autozimu/Pyplot.jl/tree/master/test

## Support and Contact

If any questions or comments, feel free to contact <autozimu@gmail.com>.

[Julia]: http://julialang.org/ "The Julia Language"
[matploblib]: http://matplotlib.org/ "matplotlib"
