
"""
    plot(fitter::Fitter; kwargs...)

Plots the data and fitting functions associated with `fitter`. Updates the
settings of `fitter` from the values given in `kwargs` before fitting.
Returns the canvas.
"""
function plot(fitter::Fitter; kwargs...)
    set!(fitter, kwargs...)

    fig = plt.figure()

    ax_main = plt.subplot2grid((4, 1), (0, 0), rowspan=3)
    plt.xscale(fitter[:xscale])
    plt.yscale(fitter[:yscale])

    ax_resid = plt.subplot2grid((4, 1), (3, 0), rowspan=1, sharex=ax_main)
    plt.xscale(fitter[:xscale])

    xmin = is(fitter[:xmin], nothing) ? minimum(fitter.xdata) : fitter[:xmin]
    xmax = is(fitter[:xmax], nothing) ? maximum(fitter.xdata) : fitter[:xmax]

    xextra = 0.1 * (xmax - xmin)

    xmin -= xextra
    xmax += xextra

    ax_main[:set_xlim](xmin, xmax)

    ax_resid[:set_xlabel](fitter[:xlabel])
    ax_resid[:set_ylabel]("Studentized residuals")
    ax_main[:set_ylabel](fitter[:ylabel])
    plt.setp(ax_main[:get_xticklabels](), visible=false)

    ax_main[:errorbar](fitter.xdata, fitter.ydata, fitter.eydata;
                       fitter[:style_data]...)

    try
        residuals = studentized_residuals(fitter)

        ax_resid[:errorbar](fitter.xdata, residuals, ones(fitter.xdata);
                          fitter[:style_data]...)

        if fitter[:plot_curve] || fitter[:plot_guess]
            x_plot = linspace(xmin, xmax, fitter[:fpoints])
        end

        if fitter[:plot_curve]
            y_curve = apply_f(fitter, x_plot)
            ax_main[:plot](x_plot, y_curve; fitter[:style_fit]...)
            ax_resid[:plot]([xmin, xmax], [0, 0];
                          fitter[:style_fit]...)
        end

        if fitter[:plot_guess]
            y_guess = apply_f(fitter, x_plot, fitter.guesses)
            ax_main[:plot](x_plot, y_guess; fitter[:style_guess]...)
        end
    catch e
        if isa(e, ErrorException)
            print(e.msg)
        else
            rethrow(e)
        end
    end

    fig
end