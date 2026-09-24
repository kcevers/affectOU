# Extract log-likelihood from fitted OU affect model

Extract log-likelihood from fitted OU affect model

## Usage

``` r
# S3 method for class 'fit_affectOU'
logLik(object, ...)
```

## Arguments

- object:

  An object of class
  [`fit_affectOU`](https://kcevers.github.io/affectOU/reference/fit.affectOU.md).

- ...:

  Additional arguments (unused).

## Value

An object of class `logLik` with `df` and `nobs` attributes.

## Examples

``` r
model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
data <- as.data.frame(sim)
fitted <- fit(model, data = data$value, times = data$time)
logLik(fitted)
#> 'log Lik.' -1231.131 (df=3)
```
