# Convert simulation results to array

Returns the raw simulation data as a 3-dimensional array with dimensions
(time × ndim × nsim).

## Usage

``` r
# S3 method for class 'simulate_affectOU'
as.array(x, ...)
```

## Arguments

- x:

  A `simulate_affectOU` object

- ...:

  Additional arguments (unused)

## Value

A 3-dimensional array with dimensions:

- time:

  Time points (named by time values)

- dim:

  Dimension index

- sim:

  Simulation index

## Examples

``` r
model <- affectOU(ndim = 2)
sim <- simulate(model, nsim = 3)
arr <- as.array(sim)
dim(arr)
#> [1] 10001     2     3

# Access first time point across all dimensions and simulations:
arr[1, , ]
#>       sim
#> dim         sim1      sim2       sim3
#>   dim1  1.507695 0.9526543 -0.3696639
#>   dim2 -1.043183 1.7227714 -1.0261385
```
