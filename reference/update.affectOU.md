# Update model configuration

Modify the parameters of an Ornstein-Uhlenbeck (OU) model.

## Usage

``` r
# S3 method for class 'affectOU'
update(
  object,
  ndim = NULL,
  theta = NULL,
  mu = NULL,
  gamma = NULL,
  sigma = NULL,
  ...
)
```

## Arguments

- object:

  An object of class
  [`affectOU`](https://kcevers.github.io/affectOU/reference/affectOU.md).

- ndim:

  Optional. New number of affect dimensions modelled.

- theta:

  Optional. New value for how quickly affect returns to baseline (a
  single number or a matrix).

- mu:

  Optional. New baseline affect the process returns to (a single number
  or a vector).

- gamma:

  Optional. New value for how strongly affect responds to ongoing random
  fluctuation (a single number or a lower triangular matrix). Specify
  either `gamma` or `sigma`, not both. If `sigma` is provided, `gamma`
  is computed via Cholesky decomposition.

- sigma:

  Optional. New noise covariance: how much random fluctuation drives
  each dimension and how those fluctuations move together (a single
  number or a symmetric, positive semi-definite matrix). Specify either
  `gamma` or `sigma`, not both. If `gamma` is provided, `sigma` is
  computed as `gamma %*% t(gamma)`.

- ...:

  Additional arguments (unused)

## Value

Updated
[affectOU](https://kcevers.github.io/affectOU/reference/affectOU.md)
object

## Examples

``` r
# 1D model
model <- affectOU()
model_new <- update(model, mu = 1)

# 2D model
theta <- matrix(c(0.5, 0, 0, 0.3), nrow = 2)
model_2d <- affectOU(theta = theta, mu = 0, gamma = diag(2))
model_2d_new <- update(model_2d, mu = c(1, -1))
```
