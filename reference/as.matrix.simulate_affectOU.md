# Convert simulation results to matrix

Returns the simulation data as a 2-dimensional matrix in either long or
wide format.

## Usage

``` r
# S3 method for class 'simulate_affectOU'
as.matrix(x, direction = c("long", "wide"), ...)
```

## Arguments

- x:

  A `simulate_affectOU` object

- direction:

  Character, either `"long"` (default) or `"wide"`. Long format has one
  row per observation with columns for time, dim, sim, and value. Wide
  format has time as rows and dimension-simulation combinations as
  columns.

- ...:

  Additional arguments (unused)

## Value

For `direction = "long"`, a matrix with columns `time`, `dim`, `sim`,
`value`. For `direction = "wide"`, a matrix with dimensions (ntime x
ndim\*nsim). Columns iterate over dimensions first, then simulations.
Column names are `dim1`, `dim2`, ... when `nsim = 1`, or `dim1.sim1`,
`dim2.sim1`, ..., `dim1.sim2`, ... when `nsim > 1`.

## Examples

``` r
model <- affectOU(ndim = 2)
sim <- simulate(model, nsim = 3)

# Long format (default)
mat_long <- as.matrix(sim)
head(mat_long)
#>      time dim sim      value
#> [1,] 0.00   1   1 -0.4472194
#> [2,] 0.01   1   1 -0.3469975
#> [3,] 0.02   1   1 -0.3432191
#> [4,] 0.03   1   1 -0.2547027
#> [5,] 0.04   1   1 -0.1953308
#> [6,] 0.05   1   1 -0.1147203

# Wide format
mat_wide <- as.matrix(sim, direction = "wide")
head(mat_wide)
#>       dim1.sim1    dim2.sim1 dim1.sim2 dim2.sim2 dim1.sim3 dim2.sim3
#> 0    -0.4472194 -0.207446344 -1.114095 0.3738359  2.604715 1.4389293
#> 0.01 -0.3469975 -0.116354821 -1.183975 0.4554206  2.629441 1.2739436
#> 0.02 -0.3432191  0.006543822 -1.308866 0.3318818  2.533854 1.1549992
#> 0.03 -0.2547027  0.022931662 -1.222850 0.2948153  2.653730 1.0359318
#> 0.04 -0.1953308 -0.073606893 -1.192542 0.1915264  2.657547 0.9274900
#> 0.05 -0.1147203 -0.155496907 -1.121070 0.2785176  2.667994 0.9245385
```
