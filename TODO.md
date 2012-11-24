## TODO

* Functions: annotate/figtext, hist
* More sophisticated way to communicate between `plot.pl` and `eval.py`.
Open subprocess to start `eval.py`, write command to subprocess's STDIN,
thus made the evaluation process more elegent and economic, as well as
the debug process easier though writing log to file.
* Document on requirements, setups, usages and examples.
    * requirements
        * julia
        * `grealpath`/`realpath`: from coreutils
        * ipython, matploblib
        * tmux (optional)
        * patience
