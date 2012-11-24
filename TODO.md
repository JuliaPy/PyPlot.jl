## TODO

* Functions: annotate/figtext, hist
* Portable
    * Make script use relative path. Currently all script rely on an env
    variable exported from the `setup.sh`, i.e., `JuliaLab_HOME`, which
    contains a definitive path.
* More sophisticated way to communicate between `plot.pl` and `eval.py`.
Open subprocess to start `eval.py`, write command to subprocess's STDIN,
thus made the evaluation process more elegent and economic, as well as
the debug process easier though writing log to file.
* Rewrite test using Julia test framework.
* Document on requirements, setups, usages and examples.
    * requirements
        * julia
        * `grealpath`/`realpath`: from coreutils
        * ipython, matploblib
        * tmux (optional)
        * patience
