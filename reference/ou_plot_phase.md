# Plot phase portrait

Visualise the phase portrait of an OU affect simulation. In the case of
a 1D simulation, this plots the lag-1 phase portrait (i.e., dimension at
time t vs. dimension at time t+dt). In the case of multi-dimensional
simulations, this creates a grid of panels: diagonal panels show lag-1
phase portraits for each dimension, while off-diagonal panels show
contemporaneous scatter plots between pairs of dimensions.

## Usage

``` r
ou_plot_phase(
  x,
  which_dim = NULL,
  which_sim = NULL,
  share_xaxis = TRUE,
  share_yaxis = TRUE,
  palette = "Dark 3",
  col_theory = "grey30",
  lwd = ifelse(x[["nsim"]] > 1, 1, 1.25),
  alpha = 1,
  main = "Phase Portrait",
  sub = paste("Dimension", if (is.null(which_dim)) {
    
    seq.int(x[["model"]][["ndim"]])
 } else {
     which_dim
 }),
  xlab = "",
  ylab = "",
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

- share_xaxis:

  Logical; use same x-axis limits for all panels?

- share_yaxis:

  Logical; use same y-axis limits for all panels?

- palette:

  Color palette. Should be one of
  [`grDevices::hcl.pals()`](https://rdrr.io/r/grDevices/palettes.html).

- col_theory:

  Color for theoretical relationship line

- lwd:

  Line width

- alpha:

  Alpha transparency for colors (0 = transparent, 1 = opaque)

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

## Diagonal panels (lag-1 phase portrait)

The diagonal panels plot \\X_i(t)\\ against \\X_i(t + \Delta t)\\,
showing the relationship between the current and next value of each
dimension. When the system is stable (\\\theta\_{ii} \> 0\\), the
conditional expectation is: \$\$E\[X_i(t + \Delta t) \mid X_i(t) = x\] =
\mu_i + (x - \mu_i)e^{-\theta\_{ii} \Delta t}\$\$

This is a line through \\(\mu_i, \mu_i)\\ with slope \\e^{-\theta\_{ii}
\Delta t} \< 1\\. The slope being less than 1 reflects mean reversion:
values above \\\mu_i\\ are expected to decrease; values below \\\mu_i\\
are expected to increase. The star marks the attractor point \\(\mu_i,
\mu_i)\\. The theoretical line is only drawn when the system is stable.

## Off-diagonal panels (contemporaneous scatter)

The off-diagonal panels plot \\X_i(t)\\ against \\X_j(t)\\ at the same
time point, showing the joint distribution of dimensions \\i\\ and
\\j\\. When the system is stable, the conditional expectation based on
the stationary covariance \\\Sigma\_\infty\\ is: \$\$E\[X_j \mid X_i =
x\] = \mu_j + \frac{\Sigma\_{\infty,ij}}{\Sigma\_{\infty,ii}}(x -
\mu_i)\$\$

This is a regression line through \\(\mu_i, \mu_j)\\ with slope
determined by the stationary covariance structure. The theoretical line
is only drawn when the system is stable.

## Examples

``` r
model <- affectOU(ndim = 2)
sim <- simulate(model, nsim = 3)
ou_plot_phase(sim)


# Mean reversion visible in slope < 1
model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
sim <- simulate(model, stop = 100, dt = 0.01, save_at = 0.1)
ou_plot_phase(sim) # slope = exp(-0.5 * 0.1) = 0.95
```
