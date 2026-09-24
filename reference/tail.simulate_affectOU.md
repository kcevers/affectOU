# Tail of simulation results

Returns the last `n` time points from a `simulate_affectOU` object.

## Usage

``` r
# S3 method for class 'simulate_affectOU'
tail(x, n = 6L, ...)
```

## Arguments

- x:

  A `simulate_affectOU` simulation object

- n:

  Number of time points to keep from the end (default 6)

- ...:

  Additional arguments passed to
  [`utils::tail()`](https://rdrr.io/r/utils/head.html)

## Value

A simulation data.frame truncated to the last `n` time points.

## Examples

``` r
model <- affectOU()
sim <- simulate(model)
tail(sim)
#>         time dim sim      value
#> 9996   99.95   1   1 -0.5261102
#> 9997   99.96   1   1 -0.5786917
#> 9998   99.97   1   1 -0.7566526
#> 9999   99.98   1   1 -0.7983275
#> 10000  99.99   1   1 -0.7030156
#> 10001 100.00   1   1 -0.7482644
```
