# Print summary of fitted OU affect model

Print summary of fitted OU affect model

## Usage

``` r
# S3 method for class 'summary_fit_affectOU'
print(x, digits = 3, ...)
```

## Arguments

- x:

  An object of class
  [`summary_fit_affectOU`](https://kcevers.github.io/affectOU/reference/summary.fit_affectOU.md).

- digits:

  Number of digits for numeric display.

- ...:

  Additional arguments (unused).

## Value

Returns `x` invisibly.

## Examples

``` r
model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
data <- as.data.frame(sim)
fitted <- fit(model, data = data$value, times = data$time)
print(summary(fitted))
#> 
#> ── Fitted Ornstein-Uhlenbeck Model Summary ─────────────────────────────────────
#> Method: mle, 5001 observations
#> 
#> ── Coefficients ──
#> 
#>       Estimate    SE          95% CI
#> theta    0.576 0.049  [0.479, 0.673]
#> mu       0.087 0.079 [-0.067, 0.242]
#> gamma    1.014 0.010  [0.993, 1.034]
#> 
#> ── Goodness of fit ──
#> 
#> Log-likelihood: -1264.653
#> RMSE: 0.312
```
