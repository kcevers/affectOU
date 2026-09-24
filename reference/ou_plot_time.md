# Plot simulation trajectory

Visualise the time series trajectories of affect dimensions from an OU
affect simulation. Each dimension can be plotted in a separate panel by
setting `by_dim = TRUE`. Specific dimensions or simulations can be
plotted with `which_dim` and `which_sim`, respectively.

## Usage

``` r
ou_plot_time(
  x,
  which_dim = NULL,
  which_sim = NULL,
  by_dim = FALSE,
  palette = "Dark 3",
  col_theory = "grey30",
  alpha = 1,
  lwd = ifelse(x[["nsim"]] > 1, 1, 1.25),
  share_yaxis = TRUE,
  main = paste0("Affect Dynamics", if (x[["nsim"]] > 1) {
     paste0(" (", if
    (is.null(which_sim)) {
x[["nsim"]]
     }
     else {
        
    length(which_sim)
     }, " simulations)")
 }),
  sub = paste("Dimension", if (is.null(which_dim)) {
    
    seq.int(x[["model"]][["ndim"]])
 } else {
     which_dim
 }),
  xlab = "Time",
  ylab = "Affect",
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

  Color for `mu` (i.e., attractor) line

- alpha:

  Alpha transparency for colors (0 = transparent, 1 = opaque)

- lwd:

  Line width

- share_yaxis:

  Logical; use same y-axis limits for all panels?

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

## Attractor Line

The horizontal dashed line shows the attractor level \\\mu\\.
Trajectories fluctuate around this baseline, pulled back by the drift
term \\\theta(\mu - X(t))\\. The strength of mean reversion (\\\theta\\)
determines how tightly trajectories cluster around \\\mu\\.

## Examples

``` r
model <- affectOU(ndim = 2)
sim <- simulate(model, nsim = 3)
ou_plot_time(sim)


# Plot dimensions in separate panels
sim <- simulate(model, nsim = 1)
ou_plot_time(sim, by_dim = TRUE)

```
