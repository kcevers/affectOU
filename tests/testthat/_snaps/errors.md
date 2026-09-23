# affectOU() error messages [plain]

    Code
      affectOU(gamma = 1, sigma = 1)
    Condition
      Error in `affectOU()`:
      ! Specify either `gamma` or `sigma`, not both.
      i `sigma` is the noise covariance matrix and `gamma` is its lower triangular square root, so supplying one determines the other.
    Code
      affectOU(ndim = 0)
    Condition
      Error in `affectOU()`:
      ! `ndim` must be a whole number larger than or equal to 1, not the number 0.
    Code
      affectOU(theta = "a")
    Condition
      Error in `affectOU()`:
      ! `theta` must be a single number, not the string "a".
    Code
      affectOU(ndim = 2, sigma = list())
    Condition
      Error in `affectOU()`:
      ! `sigma` must be a single number, a vector of length 2, or a 2x2 matrix, not an empty list.
    Code
      affectOU(ndim = 2, theta = matrix(1, 3, 3))
    Condition
      Error in `affectOU()`:
      ! `theta` must be a 2x2 matrix, not a 3x3 matrix.
      i `ndim` is 2, so every parameter must describe 2 affect dimensions.
    Code
      affectOU(ndim = 2, mu = c(1, 2, 3))
    Condition
      Error in `affectOU()`:
      ! `mu` must be a single number or a vector of length 2, not a vector of length 3.
      i `ndim` is 2, so every parameter must describe 2 affect dimensions.
    Code
      affectOU(theta = matrix(c(1, NA, 0, 1), 2))
    Condition
      Error in `affectOU()`:
      ! `theta` must contain only finite values.
      x It contains `NA` values.
    Code
      affectOU(theta = diag(2), sigma = diag(3))
    Condition
      Error in `affectOU()`:
      ! Model parameters must all describe the same number of affect dimensions.
      x `theta` implies 2 dimensions and `sigma` implies 3.
      i Set `ndim` explicitly to choose one?
    Code
      affectOU(sigma = -1)
    Condition
      Error in `affectOU()`:
      ! `sigma` must be a number larger than or equal to 0, not the number -1.
      i `sigma` is the variance of the random fluctuation driving affect, so it cannot be negative.
    Code
      affectOU(sigma = matrix(c(1, 2, 3, 4), 2))
    Condition
      Error in `affectOU()`:
      ! `sigma` must be a symmetric matrix.
      i `sigma` is a covariance matrix: the covariance between two affect dimensions is the same in either direction.
    Code
      affectOU(sigma = matrix(c(1, 1.5, 1.5, 1), 2))
    Condition
      Error in `affectOU()`:
      ! `sigma` must be positive semi-definite.
      x Its smallest eigenvalue is -0.5.
      i `sigma` is the covariance matrix of the random fluctuation driving affect; a negative eigenvalue would give some combination of affect dimensions a negative variance.
    Code
      affectOU(gamma = matrix(c(1, 0, 2, 1), 2))
    Condition
      Error in `affectOU()`:
      ! `gamma` must be a lower triangular matrix.
      i Supply `sigma` (the noise covariance matrix) instead to have `gamma` derived from it?

# update() and plot() error messages [plain]

    Code
      update(model, gamma = 1, sigma = 1)
    Condition
      Error in `update()`:
      ! Specify either `gamma` or `sigma`, not both.
      i `sigma` is the noise covariance matrix and `gamma` is its lower triangular square root, so supplying one determines the other.
    Code
      update(model, mu = "a")
    Condition
      Error in `update()`:
      ! `mu` must be a single number, not the string "a".
    Code
      plot(model)
    Condition
      Error in `plot()`:
      ! `plot()` is not supported for an <affectOU> model.
      i Simulate data with `simulate()` and plot the result?

# simulate() error messages [plain]

    Code
      withr::with_seed(1, {
        simulate(model, nsim = 2.5)
        simulate(model, nsim = -1)
        simulate(model, dt = "a")
        simulate(model, dt = -0.1)
        simulate(model, dt = 0)
        simulate(model, save_at = 5, stop = 2)
        simulate(model, dt = 0.1, save_at = 0.01)
        simulate(model, seed = "a")
        simulate(model_3d, initial = c(1, 2))
      })
    Condition
      Error in `simulate()`:
      ! `nsim` must be a whole number, not the number 2.5.

# simulation method error messages [plain]

    Code
      summary(sim, discard_initial_time = 100)
    Condition
      Error in `summary()`:
      ! `discard_initial_time` must be less than the simulated period.
      x `discard_initial_time` is 100 and the simulation stops at 20.
      i No time points would remain to summarise.
    Code
      summary(sim, discard_initial_time = -1)
    Condition
      Error in `summary()`:
      ! `discard_initial_time` must be a number larger than or equal to 0, not the number -1.
    Code
      head(sim, n = 0)
    Condition
      Error in `head()`:
      ! `n` must be a whole number larger than or equal to 1, not the number 0.
    Code
      tail(sim, n = -1)
    Condition
      Error in `tail()`:
      ! `n` must be a whole number larger than or equal to 1, not the number -1.
    Code
      summary(sim, burnin = 10)
    Message
      
      -- 1D Ornstein-Uhlenbeck Simulation Summary ------------------------------------
      
      -- Simulation settings --
      
      Time: 0 → 20.000
      Time points: 41; dt: 0.01; save_at: 0.5
      Seed: 1
      
      -- Comparison to theoretical distribution --
      
           Simulated Theoretical
      Mean    -0.273           0
      SD       0.667           1

# fit() error messages [plain]

    Code
      fit(model_3d, data = rnorm(10), times = seq_len(10))
    Condition
      Error in `fit()`:
      ! `fit()` currently supports one-dimensional models only.
      x `object` has 3 dimensions.
    Code
      fit(model, data = 1)
    Condition
      Error in `fit()`:
      ! `data` must contain at least 2 observations, not 1.
    Code
      fit(model, data = list())
    Condition
      Error in `fit()`:
      ! `data` must be a numeric vector, not an empty list.
    Code
      fit(model, data = c(1, NA, 3))
    Condition
      Error in `fit()`:
      ! `data` must contain only finite values.
      x It contains `NA` values.
      i Remove or impute missing observations before fitting.
    Code
      fit(model, data = 1:10, times = letters[1:9])
    Condition
      Error in `fit()`:
      ! `times` must be a numeric vector, not a character vector.
    Code
      fit(model, data = 1:5, times = c(1, 2, NA, 4, 5))
    Condition
      Error in `fit()`:
      ! `times` must contain only finite values.
      x It contains `NA` values.
    Code
      fit(model, data = 1:100, times = 1:99)
    Condition
      Error in `fit()`:
      ! `data` and `times` must be the same length.
      x `data` has 100 values and `times` has 99.
    Code
      fit(model, data = 1:5, times = c(1, 2, 2, 4, 5))
    Condition
      Error in `fit()`:
      ! `times` must be strictly increasing.
      x `times[3]` is not greater than `times[2]`.
      i Observations must be ordered in time, with no repeated time points.
    Code
      fit(model, data = 1:5, times = 1:5, method = "ols")
    Condition
      Error in `fit()`:
      ! `method` must be "mle", not "ols".
    Code
      fit(model, data = 1:5, times = 1:5, start = c(a = 1, b = 2, c = 3))
    Condition
      Error in `fit()`:
      ! `start` must be a named vector with names "theta", "mu", and "gamma".
      x Its names are "a", "b", and "c".
    Code
      fit(model, data = 1:5, times = 1:5, start = c(theta = 1, mu = NA, gamma = 1))
    Condition
      Error in `fit()`:
      ! `start` must contain only finite values.
      x It contains `NA` values.

# fitted model error messages [plain]

    Code
      confint(fitted, parm = "alpha")
    Condition
      Error in `confint()`:
      ! `parm` must name parameters of the fitted model.
      x "alpha" is not one of "theta", "mu", or "gamma".
    Code
      confint(fitted, level = 1.5)
    Condition
      Error in `confint()`:
      ! `level` must be a number between 0 and 1, not the number 1.5.
    Code
      summary(fitted, level = 0)
    Condition
      Error in `summary()`:
      ! `level` must be a number between 0 and 1, not the number 0.

# plot() error messages [plain]

    Code
      plot(sim, which_dim = 5)
    Condition
      Error in `plot()`:
      ! `which_dim` must contain values between 1 and 3, not 5.
    Code
      plot(sim, which_dim = "a")
    Condition
      Error in `plot()`:
      ! `which_dim` must be a numeric vector of dimension indices, not the string "a".
    Code
      plot(sim, which_sim = 25)
    Condition
      Error in `plot()`:
      ! `which_sim` must contain values between 1 and 10, not 25.
    Code
      plot(sim, type = "acf", which_sim = 1:3)
    Condition
      Error in `plot()`:
      ! `which_sim` must select at most 1 simulation, not 3.
    Code
      plot(sim, ylim = list(c(0, 1), c(0, 1)))
    Condition
      Error in `plot()`:
      ! `lim` must have one element per dimension.
      x `lim` has 2 elements and the model has 3 dimensions.
    Code
      plot(sim, sub = c("a", "b"))
    Condition
      Error in `plot()`:
      ! `sub` must have one element per dimension plotted.
      x `sub` has 2 elements and 3 dimensions are plotted.
    Code
      plot(sim, type = "histogram", freq = "yes")
    Condition
      Error in `plot()`:
      ! `freq` must be `TRUE` or `FALSE`, not the string "yes".
    Code
      plot(sim, type = "acf", lag.max = -1)
    Condition
      Error in `plot()`:
      ! `lag.max` must be a number larger than or equal to 0, not the number -1.

# warning messages [plain]

    Code
      invisible(simulate(affectOU(theta = -0.5), stop = 1, save_at = 0.5, seed = 1))
    Condition
      Warning:
      ! The system is not stable, so no stationary distribution exists.
      i `initial` defaults to `mu`.
    Code
      invisible(fit(affectOU(theta = 0.5, mu = 0, gamma = 1), data = rnorm(50)))
    Condition
      Warning:
      ! `times` was not supplied; assuming unit spacing (0, 1, 2, ...).
      i Supply `times` if the observations are unevenly spaced?

