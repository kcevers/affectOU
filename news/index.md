# Changelog

## affectOU 1.0.3

- Improved error messages. For example, errors on domain constraints now
  explain the constraint in terms of affect dynamics.
- Conditions now carry `affectOU_error_*` classes, so they can be caught
  programmatically with
  [`tryCatch()`](https://rdrr.io/r/base/conditions.html) or tested with
  `expect_error(class = ...)`.
- **Breaking:** the `initial_state` argument of
  [`simulate()`](https://rdrr.io/r/stats/simulate.html) is now
  `initial`, and the `burnin` argument of
  [`summary()`](https://rdrr.io/r/base/summary.html) for simulations is
  now `discard_initial_time`.
- New explicit dependency on rlang (\>= 1.2.0), which cli already
  required.

## affectOU 1.0.2

- Fixed [`summary()`](https://rdrr.io/r/base/summary.html) for
  multivariate simulations so means, standard deviations, covariances,
  and correlations are pooled by dimension correctly when multiple
  simulations are summarized.
- [`simulate()`](https://rdrr.io/r/stats/simulate.html) now always
  includes the requested `stop` time without returning `NA` values when
  `dt` and `save_at` do not divide the total simulation time exactly.
- [`simulate()`](https://rdrr.io/r/stats/simulate.html) now works for
  stable multivariate models with singular stationary covariance
  matrices, such as models with a dimension that has no stochastic
  noise.
- [`affectOU()`](https://kcevers.github.io/affectOU/reference/affectOU.md)
  now accepts singular positive semi-definite `sigma` matrices and gives
  a clear error for non-symmetric `sigma` matrices.
- [`fit()`](https://generics.r-lib.org/reference/fit.html) now gives a
  clear error when `times` are non-finite, duplicated, or not strictly
  increasing.
- [`logLik()`](https://rdrr.io/r/stats/logLik.html) for fitted models
  now returns a standard `logLik` object with degrees of freedom and
  number of observations attached.
- ACF plots for non-stationary simulations no longer show a theoretical
  stationary line.
- Corrected documentation for the multivariate stationary covariance
  equation and the `simpaper` example equation.

## affectOU 1.0.1

- [`plot()`](https://rdrr.io/r/graphics/plot.default.html) now supports
  `legend_position = "none"`

## affectOU 1.0.0

First stable version.
