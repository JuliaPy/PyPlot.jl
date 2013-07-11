Overview
--------

================== =========================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================
Function           Description
================== =========================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================
`acorr`            Plot the autocorrelation of *x*.
`annotate`         Create an annotation: a piece of text referring to a data point.
`arrow`            Add an arrow to the axes.
`autoscale`        Autoscale the axis view to the data (toggle).
`axes`             Add an axes to the figure.
`axhline`          Add a horizontal line across the axis.
`axhspan`          Add a horizontal span (rectangle) across the axis.
`axis`             Set or get the axis properties.::        >>> axis()      returns the current axes limits ``[xmin, xmax, ymin, ymax]``.::        >>> axis(v)      sets the min and max of the x and y axes, with     ``v = [xmin, xmax, ymin, ymax]``.::        >>> axis('off')      turns off the axis lines and labels.::        >>> axis('equal')      changes limits of *x* or *y* axis so that equal increments of *x*     and *y* have the same length; a circle is circular.::        >>> axis('scaled')      achieves the same result by changing the dimensions of the plot box instead     of the axis data limits.::        >>> axis('tight')      changes *x* and *y* axis limits such that all data is shown.
`axvline`          Add a vertical line across the axes.
`axvspan`          Add a vertical span (rectangle) across the axes.
`bar`              Make a bar plot.
`barbs`            Plot a 2-D field of barbs.
`barh`             Make a horizontal bar plot.
`box`              Turn the axes box on or off.
`boxplot`          Make a box and whisker plot.
`broken_barh`      Plot horizontal bars.
`cla`              Clear the current axes.
`clabel`           Label a contour plot.
`clf`              Clear the current figure.
`clim`             Set the color limits of the current image.
`close`            Close a figure window.
`cohere`           Plot the coherence between *x* and *y*.
`colorbar`         Add a colorbar to a plot.
`contour`          Plot contours.
`contourf`         Plot contours.
`csd`              Plot cross-spectral density.
`delaxes`          Remove an axes from the current figure.
`draw`             Redraw the current figure.
`errorbar`         Plot an errorbar graph.
`figimage`         Adds a non-resampled image to the figure.
`figlegend`        Place a legend in the figure.
`figtext`          Add text to figure.
`figure`           Create a new figure.
`fill`             Plot filled polygons.
`fill_between`     Make filled polygons between two curves.
`fill_betweenx`    Make filled polygons between two horizontal curves.
`findobj`          Find artist objects.
`gca`              Return the current axis instance.
`gcf`              Return a reference to the current figure.
`gci`              Get the current colorable artist.
`get_figlabels`    Return a list of existing figure labels.
`get_fignums`      Return a list of existing figure numbers.
`grid`             Turn the axes grids on or off.
`hexbin`           Make a hexagonal binning plot.
`hist`             Plot a histogram.
`hist2d`           Make a 2D histogram plot.
`hlines`           Plot horizontal lines.
`hold`             Set the hold state.
`imread`           Read an image from a file into an array.
`imsave`           Save an array as in image file.
`imshow`           Display an image on the axes.
`ioff`             Turn interactive mode off.
`ion`              Turn interactive mode on.
`ishold`           Return the hold status of the current axes.
`isinteractive`    Return status of interactive mode.
`legend`           Place a legend on the current axes.
`locator_params`   Control behavior of tick locators.
`loglog`           Make a plot with log scaling on both the *x* and *y* axis.
`margins`          Set or retrieve autoscaling margins.
`matshow`          Display an array as a matrix in a new figure window.
`minorticks_off`   Remove minor ticks from the current plot.
`minorticks_on`    Display minor ticks on the current plot.
`over`             Call a function with hold(True).
`pause`            Pause for *interval* seconds.
`pcolor`           Create a pseudocolor plot of a 2-D array.
`pcolormesh`       Plot a quadrilateral mesh.
`pie`              Plot a pie chart.
`plot`             Plot lines and/or markers to the :class:`~matplotlib.axes.Axes`.
`plot_date`        Plot with data with dates.
`plotfile`         Plot the data in in a file.
`polar`            Make a polar plot.
`psd`              Plot the power spectral density.
`quiver`           Plot a 2-D field of arrows.
`quiverkey`        Add a key to a quiver plot.
`rc`               Set the current rc params.
`rcdefaults`       Restore the default rc params.
`rgrids`           Get or set the radial gridlines on a polar plot.
`savefig`          Save the current figure.
`sca`              Set the current Axes instance to *ax*.
`scatter`          Make a scatter plot.
`sci`              Set the current image.
`semilogx`         Make a plot with log scaling on the *x* axis.
`semilogy`         Make a plot with log scaling on the *y* axis.
`set_cmap`         Set the default colormap.
`setp`             Set a property on an artist object.
`show`             Display a figure.
`specgram`         Plot a spectrogram.
`spy`              Plot the sparsity pattern on a 2-D array.
`stackplot`        Draws a stacked area plot.
`stem`             Create a stem plot.
`step`             Make a step plot.
`streamplot`       Draws streamlines of a vector flow.
`subplot`          Return a subplot axes positioned by the given grid definition.
`subplot2grid`     Create a subplot in a grid.
`subplot_tool`     Launch a subplot tool window for a figure.
`subplots`         Create a figure with a set of subplots already made.
`subplots_adjust`  Tune the subplot layout.
`suptitle`         Add a centered title to the figure.
`switch_backend`   Switch the default backend.
`table`            Add a table to the current axes.
`text`             Add text to the axes.
`thetagrids`       Get or set the theta locations of the gridlines in a polar plot.
`tick_params`      Change the appearance of ticks and tick labels.
`ticklabel_format` Change the `~matplotlib.ticker.ScalarFormatter` used by default for linear axes.
`tight_layout`     Automatically adjust subplot parameters to give specified padding.
`title`            Set the title of the current axis.
`tricontour`       Draw contours on an unstructured triangular grid.
`tricontourf`      Draw contours on an unstructured triangular grid.
`tripcolor`        Create a pseudocolor plot of an unstructured triangular grid.
`triplot`          Draw a unstructured triangular grid as lines and/or markers.
`twinx`            Make a second axes that shares the *x*-axis.
`twiny`            Make a second axes that shares the *y*-axis.
`vlines`           Plot vertical lines.
`xcorr`            Plot the cross correlation between *x* and *y*.
`xlabel`           Set the *x* axis label of the current axis.
`xlim`             Get or set the *x* limits of the current axes.
`xscale`           Set the scaling of the *x*-axis.
`xticks`           Get or set the *x*-limits of the current tick locations and labels.
`ylabel`           Set the *y* axis label of the current axis.
`ylim`             Get or set the *y*-limits of the current axes.
`yscale`           Set the scaling of the *y*-axis.
`yticks`           Get or set the *y*-limits of the current tick locations and labels.
================== =========================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================
