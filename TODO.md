## TODO

* Functions: annotate/figtext, hist, pie (I don't use thos
  functionality, will be implemented upon required)
* Better ways to communicate between `plot.pl` and `eval.py`. Possible
  solutions:
    * Use ZMQ (more promising) [1](http://www.zeromq.org/) [2](https://github.com/JuliaLang/METADATA.jl/tree/master/ZMQ "julia binding for ZMQ")
    * Open a subprocess to start `eval.py`, write command to this
      subprocess's STDIN, thus make the evaluation process more elegent
      and economic, as well as the debug process easier though writing
      log to file.
* Document on requirements, setups, usages and demos.
    * requirements
        * [julia](http://julialang.org/)
        * [ipython](http://ipython.org/), [matploblib](http://matplotlib.org/)
        * [daemonize](http://software.clapper.org/daemonize/)
        * patience
    * setups
    * usage
    * demos
