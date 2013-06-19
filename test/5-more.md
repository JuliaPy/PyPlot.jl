## Want More?

As mentioned before, this package is simply a wrapper around matplotlib,
the powerful python plot library. If you want find more details on the
plotting functions and available parameters, matplotlib's [website][mpl]
is a good place. And there is also a [gallery][] page to show how
powerful it could be. If you need some functions that have not yet been
wrapped by this module (this is highly possible, since I only exported
the functions that I think I will use in my simple research work), a
special function `pyplot.pyplot()` could be used to send arbitrary
matplotlib commands.  Also, it is quite easy to wrap those functions,
take `src/alias.jl` as example and make your own.

[mpl]: http://matplotlib.org/
[gallery]: http://matplotlib.org/gallery.html
