## TODO

* Functions: annotate/figtext, hist
* Portable
    * Make script use relative path. Currently all script rely on an env
    variable exported from the `setup.sh`, i.e., `JuliaLab_HOME`, which
    contains a definitive path.
    * Tell julia where to find JuliLab module. Currently, it is solved
    by linking `JuliaLab.jl` to `JULIA_HOME/lib/julia/extras/`. Problems
    may be solved when given more info on Julia packaging system
    [1][wiki], [2][METADATA].
* More sophisticated way to communicate between `plot.pl` and `eval.py`.
Open subprocess to start `eval.py`, write command to subprocess's STDIN,
thus made the evaluation process more elegent and economic, as well as
the debug process easier though writing log to file.
* Rewrite Options syntax using Options module.
* Rewrite test using Julia test framework.
* Document on prerequirements, setups, usages and examples.

[wiki]: https://github.com/JuliaLang/julia/wiki/Package-system
[METADATA]: https://github.com/JuliaLang/METADATA.jl
