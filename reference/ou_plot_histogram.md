# Plot simulation histogram

Visualise the distribution of affect values from an OU affect simulation
using histograms for each dimension. In case of multiple simulations,
the histograms aggregate data across all simulations for each dimension.
Different dimensions can be plotted in separate panels by setting
`by_dim = TRUE`. Specific dimensions or simulations can be plotted with
`which_dim` and `which_sim`, respectively.

## Usage

``` r
ou_plot_histogram(
  x,
  which_dim = NULL,
  which_sim = NULL,
  by_dim = FALSE,
  palette = "Dark 3",
  col_theory = "grey30",
  alpha = 1,
  share_xaxis = TRUE,
  share_yaxis = !freq,
  freq = FALSE,
  breaks = 30,
  main = "Affect Distribution",
  sub = paste("Dimension", if (is.null(which_dim)) {
    
    seq.int(x[["model"]][["ndim"]])
 } else {
     which_dim
 }),
  xlab = "Affect",
  ylab = ifelse(freq, "Frequency", "Density"),
  legend_position = "topright",
  ...,
  call = rlang::current_env()
)
```

## Arguments

- x:

  A `simulate_affectOU` model object produced by
  [`simulate.affectOU()`](https://kcevers.github.io/affectOU/reference/simulate.affectOU.md)

- which_dim:

  Dimension indices to plot (NULL for all)

- which_sim:

  Simulation indices to plot (NULL for all)

- by_dim:

  Logical; plot each dimension in separate panel?

- palette:

  Color palette. Should be one of
  [`grDevices::hcl.pals()`](https://rdrr.io/r/grDevices/palettes.html).

- col_theory:

  Color for theoretical distribution line (if stationary)

- alpha:

  Alpha transparency for colors (0 = transparent, 1 = opaque)

- share_xaxis:

  Logical; use same x-axis limits for all panels?

- share_yaxis:

  Logical; use same y-axis limits for all panels?

- freq:

  Logical; plot frequency instead of density?

- breaks:

  Number of histogram breaks

- main:

  Main title

- sub:

  Subtitle for panels

- xlab:

  X-axis label

- ylab:

  Y-axis label

- legend_position:

  Position of legend (one of `"bottomright"`, `"bottom"`,
  `"bottomleft"`, `"left"`, `"topleft"`, `"top"`, `"topright"`,
  `"right"`, `"center"`, `"none"`). Set to `"none"` to hide legend.

- ...:

  Additional graphical parameters

- call:

  Environment used to report errors. Relevant only when calling this
  function from another function, so that errors name the function the
  user called.

## Value

`NULL` (invisibly), called for side effects only.

## Stationary Distribution

When the system is stable, the stationary distribution of the
multivariate OU is normal with mean \\\mathbf{\mu}\\ and covariance
matrix \\\mathbf{\Sigma}\_\infty\\ derived as the solution of the
Lyapunov equation \\\mathbf{\Gamma} \mathbf{\Gamma}^T = \mathbf{\Theta}
\mathbf{\Sigma}\_\infty + \mathbf{\Sigma}\_\infty \mathbf{\Theta}^T\\.
The theoretical density curve is overlaid on the histogram when the
system is stationary.

Different parameter combinations can yield the same stationary variance
but produce different dynamics. For example, doubling both \\\theta\\
and \\\gamma\\ keeps the stationary covariances constant but changes the
half- life.

## Examples

``` r
model <- affectOU(ndim = 2)
sim <- simulate(model, nsim = 3)
ou_plot_histogram(sim)


# Plot dimensions in separate panels
sim <- simulate(model, nsim = 1)
ou_plot_histogram(sim, by_dim = TRUE)


# Same stationary SD, different dynamics
m1 <- affectOU(theta = 0.5, mu = 0, gamma = 1) # SD = 1
m2 <- affectOU(theta = 2.0, mu = 0, gamma = 2) # SD = 1
s1 <- simulate(m1, stop = 100)
s2 <- simulate(m2, stop = 100)
ou_plot_histogram(s1, main = "Slow regulation")

ou_plot_histogram(s2, main = "Fast regulation")

```
