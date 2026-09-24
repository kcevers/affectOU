# Plot parameter documentation

Plot parameter documentation

## Arguments

- which_dim:

  Dimension indices to plot (NULL for all)

- which_sim:

  Simulation indices to plot (NULL for all)

- by_dim:

  Logical; plot each dimension in separate panel?

- palette:

  Color palette. Should be one of
  [`grDevices::hcl.pals()`](https://rdrr.io/r/grDevices/palettes.html).

- alpha:

  Alpha transparency for colors (0 = transparent, 1 = opaque)

- lwd:

  Line width

- share_xaxis:

  Logical; use same x-axis limits for all panels?

- share_yaxis:

  Logical; use same y-axis limits for all panels?

- freq:

  Logical; plot frequency instead of density?

- breaks:

  Number of histogram breaks

- lag.max:

  Maximum lag to compute. Specified in terms of saved time units. For
  example, `lag.max = 10` with `save_at = 0.1` corresponds to a lag of
  10 time units and 10/0.1=100 time points.

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
