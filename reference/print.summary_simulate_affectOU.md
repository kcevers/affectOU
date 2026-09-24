# Print summary of simulation results

Print summary of simulation results

## Usage

``` r
# S3 method for class 'summary_simulate_affectOU'
print(x, digits = 3, max_dim = 10, ...)
```

## Arguments

- x:

  An object of class `summary_simulate_affectOU`

- digits:

  Number of digits for numeric display

- max_dim:

  Maximum number of dimensions to display full details for. For higher
  dimensions, only summary information is shown.

- ...:

  Additional arguments (unused)

## Value

Invisibly returns the input object `x` after printing the summary.

## Examples

``` r
model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
sim <- simulate(model, nsim = 3)
print(summary(sim))
#> 
#> ── 1D Ornstein-Uhlenbeck Simulation Summary (3 replications) ───────────────────
#> 
#> ── Simulation settings ──
#> 
#> Time: 0 → 100.000
#> Time points: 10001; dt: 0.01; save_at: 0.01
#> 
#> ── Comparison to theoretical distribution ──
#> 
#>      Simulated Theoretical
#> Mean    -0.015           0
#> SD       1.014           1
```
