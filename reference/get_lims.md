# Calculate axis limits for multiple panels

Calculate axis limits for multiple panels

## Usage

``` r
get_lims(
  data,
  ndim,
  nsim,
  lim = NULL,
  share_axis = FALSE,
  include = NULL,
  call = rlang::caller_env()
)
```

## Arguments

- data:

  Data array

- ndim:

  Number of dimensions

- nsim:

  Number of simulations

- lim:

  User-supplied lim (NULL, vector, or list)

- share_axis:

  Logical; share axis across panels?

## Value

List of lim vectors
