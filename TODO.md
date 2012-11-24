## TODO

* Functions: annotate/figtext, hist
* Portable
    * Make script use relative path. Currently all script rely on an env
    variable exported from the `setup.sh`, i.e., `JuliaLab_HOME`, which
    contains a definitive path.
    * Tell julia where to find JuliLab module. Currently, it is solved
    by linking `JuliaLab.jl` to `JULIA_HOME/lib/julia/extras/`. Problems
    may be solved when given more info on Julia package system [1][wiki], [2][METADATA].
* More sophisticated way to communicate between `plot.pl` and `eval.py`.
* Document on prerequirements, setups, usages and examples.

[wiki]: https://github.com/JuliaLang/julia/wiki/Package-system
[METADATA]: https://github.com/JuliaLang/METADATA.jl
