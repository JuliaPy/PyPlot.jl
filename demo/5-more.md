## Want More?

As mentioned before, this module is just a simple wrapper for matplotlib,
the powerful python plot library. Usually the `*args` parameters in
matplotlib is translated to positional parameters in Julia, while the
`*kwargs` parameters could be send by `:Symbol, Value` pair (since the
multiple dispatch design of Julia make it hard to implement keyword
style parameters). If you want find more details on the plotting
functions and available parameters, matplotlib's [website][mpl] is a
good place, and it also provide a [gallary][] page to show how powerful
it could be. If you need some functions has not yet been wrapped (this
is quite probably, since I only implemented the functions that I think I
will use), a special function `mrun()` could be utilized to send any
matplotlib commands. Also, it is easy to wrap those functions, take
`src/plot.jl` as example and make your own.

[mpl]: http://matplotlib.org/
[gallery]: http://matplotlib.org/gallery.html
