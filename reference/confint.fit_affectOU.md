# Confidence intervals for fitted OU affect model

Confidence intervals for fitted OU affect model

## Usage

``` r
# S3 method for class 'fit_affectOU'
confint(object, parm, level = 0.95, ...)
```

## Arguments

- object:

  An object of class
  [`fit_affectOU`](https://kcevers.github.io/affectOU/reference/fit.affectOU.md).

- parm:

  Optional character vector naming parameters of the fitted model to
  include: any of `theta`, `mu`, and `gamma`. If missing, all parameters
  are included.

- level:

  Confidence level for intervals: a number between 0 and 1 (default
  0.95).

- ...:

  Additional arguments (unused).

## Value

Matrix of confidence intervals with columns for lower and upper bounds.

## Examples

``` r
model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
data <- as.data.frame(sim)
fitted <- fit(model, data = data$value, times = data$time)
confint(fitted)
#>             2.5%     97.5%
#> theta  0.3836220 0.5578238
#> mu    -0.1745091 0.1936820
#> gamma  0.9687320 1.0083990
```
