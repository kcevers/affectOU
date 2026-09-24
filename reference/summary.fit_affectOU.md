# Summarize fitted OU affect model

Summarize the result of fitting an Ornstein-Uhlenbeck model to data.
Output includes a parameter table with estimates, standard errors, and
confidence intervals, as well as goodness-of-fit statistics.

## Usage

``` r
# S3 method for class 'fit_affectOU'
summary(object, level = 0.95, ...)
```

## Arguments

- object:

  An object of class
  [`fit_affectOU`](https://kcevers.github.io/affectOU/reference/fit.affectOU.md).

- level:

  Confidence level for intervals: a number between 0 and 1 (default
  0.95).

- ...:

  Additional arguments (unused).

## Value

An object of class `summary_fit_affectOU` containing:

- coefficients:

  Data frame with columns `estimate`, `se`, `lower`, and `upper` for
  each parameter.

- log_likelihood:

  Maximized log-likelihood value.

- rmse:

  Root mean squared error.

- nobs:

  Number of observations.

- convergence:

  Optimizer convergence code (0 = success).

- level:

  Confidence level used.

- method:

  Estimation method used.

## Examples

``` r
model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
data <- as.data.frame(sim)
fitted <- fit(model, data = data$value, times = data$time)
summary(fitted)
#> 
#> ── Fitted Ornstein-Uhlenbeck Model Summary ─────────────────────────────────────
#> Method: mle, 5001 observations
#> 
#> ── Coefficients ──
#> 
#>       Estimate    SE          95% CI
#> theta    0.489 0.045  [0.400, 0.578]
#> mu       0.108 0.092 [-0.073, 0.289]
#> gamma    1.008 0.010  [0.988, 1.029]
#> 
#> ── Goodness of fit ──
#> 
#> Log-likelihood: -1258.897
#> RMSE: 0.311
```
