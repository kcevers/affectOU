# Print fitted OU affect model

Provide a concise overview of a
[`fit_affectOU`](https://kcevers.github.io/affectOU/reference/fit.affectOU.md)
object.

## Usage

``` r
# S3 method for class 'fit_affectOU'
print(x, digits = 3, ...)
```

## Arguments

- x:

  An object of class
  [`fit_affectOU`](https://kcevers.github.io/affectOU/reference/fit.affectOU.md)

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
print(fitted)
#> 
#> ── Fitted 1D Ornstein-Uhlenbeck Model ──────────────────────────────────────────
#> 5001 data points (dt ≈ 0.100)
#> θ = 0.392, μ = -0.047, γ = 0.984
#> Log-likelihood: -1161.080
#> RMSE: 0.305
```
