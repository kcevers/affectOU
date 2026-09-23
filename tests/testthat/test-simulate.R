# Test simulate method (1D) --------------------------------------------------

test_that("simulate.affectOU produces correct output dimensions (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)

  expect_s3_class(sim, "simulate_affectOU")
  expect_equal(dim(sim[["data"]]), c(101, 1, 1)) # 0 to 10 by 0.1
  expect_length(sim[["times"]], 101)
  expect_equal(sim[["nsim"]], 1)
})

test_that("simulate.affectOU works with multiple replications (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 3)

  expect_true(is.array(sim[["data"]]))
  expect_equal(dim(sim[["data"]]), c(101, 1, 3))
  expect_equal(sim[["nsim"]], 3)
})

test_that("simulate.affectOU respects seed (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)

  sim1 <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 3, seed = 123)
  sim2 <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 3, seed = 123)

  expect_equal(sim1[["data"]], sim2[["data"]])
})

test_that("simulate.affectOU respects local seed (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)

  withr::local_seed(12345)
  sim1 <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 3)
  withr::local_seed(12345)
  sim2 <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 3)

  expect_equal(sim1[["data"]], sim2[["data"]])
})

test_that("simulate.affectOU starts at initial (1D)", {
  x0 <- 5
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, initial = x0)

  expect_equal(sim[["data"]][1], x0)
})

test_that("simulate.affectOU NULL initial draws from stationary (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  # With nsim > 1 and NULL initial, first values should vary across sims
  sim <- simulate(model, nsim = 10, stop = 1, dt = .1, save_at = .1, seed = 42)
  first_vals <- sim[["data"]][1, 1, ]
  expect_true(length(unique(round(first_vals, 6))) > 1)
})

test_that("simulate.affectOU NULL initial warns for unstable system (1D)", {
  model <- affectOU(theta = -0.5, mu = 2, gamma = 1)
  expect_warning(
    sim <- simulate(model, nsim = 2, stop = 1, dt = .1, save_at = .1),
    "not stable"
  )
  # All simulations should start at mu = 2
  expect_equal(sim[["data"]][1, 1, 1], 2)
  expect_equal(sim[["data"]][1, 1, 2], 2)
})

test_that("simulate.affectOU trajectory reverts to mu (1D)", {
  model <- affectOU(theta = 0.5, mu = 2, gamma = 0.1)
  sim <- simulate(model, stop = 100, dt = .1, save_at = .1, nsim = 1, initial = 10)

  # After long time, should be close to mu
  final_values <- sim[["data"]][(length(sim[["data"]]) - 50):length(sim[["data"]])]
  expect_true(abs(mean(final_values) - 2) < 1) # Within 1 of mu
})

# Test simulate method (2D) --------------------------------------------------

test_that("simulate.affectOU produces correct output dimensions (2D, nsim=1)", {
  ndim <- 2
  theta <- matrix(c(0.5, 0, 0, 0.3), nrow = 2)
  model <- affectOU(ndim = ndim, theta = theta, mu = c(0, 0), gamma = diag(2))
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)

  expect_s3_class(sim, "simulate_affectOU")
  expect_true(is.array(sim[["data"]]))
  expect_equal(dim(sim[["data"]]), c(101, 2, 1))
  expect_length(sim[["times"]], 101)
})

test_that("simulate.affectOU produces correct output dimensions (2D, nsim>1)", {
  ndim <- 2
  theta <- matrix(c(0.5, 0, 0, 0.3), nrow = 2)
  model <- affectOU(ndim = ndim, theta = theta, mu = c(0, 0), gamma = diag(2))
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 3)

  expect_true(is.array(sim[["data"]]))
  expect_equal(dim(sim[["data"]]), c(101, 2, 3)) # n_times x 2 x nsim
})

test_that("simulate.affectOU respects seed (2D)", {
  ndim <- 2
  theta <- matrix(c(0.5, 0, 0, 0.3), nrow = 2)
  model <- affectOU(ndim = ndim, theta = theta, mu = c(0, 0), gamma = diag(2))

  sim1 <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1, seed = 123)
  sim2 <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1, seed = 123)

  expect_equal(sim1[["data"]], sim2[["data"]])
})

test_that("simulate.affectOU starts at initial (2D)", {
  ndim <- 2
  theta <- matrix(c(0.5, 0, 0, 0.3), nrow = 2)
  initial <- c(5, -3)
  model <- affectOU(ndim = ndim, theta = theta, mu = c(0, 0), gamma = diag(2))
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1, initial = initial)

  expect_equal(sim[["data"]][1, , 1], initial)
})

test_that("simulate.affectOU trajectory reverts to mu (2D)", {
  ndim <- 2
  theta <- matrix(c(0.5, 0, 0, 0.5), nrow = 2)
  mu <- c(2, -1)
  model <- affectOU(ndim = ndim, theta = theta, mu = mu, gamma = diag(c(0.1, 0.1)))
  sim <- simulate(model, stop = 100, dt = .1, save_at = .1, nsim = 1, initial = c(10, 10))

  # After long time, should be close to mu
  final_indices <- (nrow(sim[["data"]]) - 50):nrow(sim[["data"]])
  final_mean_1 <- mean(sim[["data"]][final_indices, 1, 1])
  final_mean_2 <- mean(sim[["data"]][final_indices, 2, 1])

  expect_true(abs(final_mean_1 - 2) < 1)
  expect_true(abs(final_mean_2 - (-1)) < 1)
})

test_that("simulate.affectOU handles coupled dynamics (2D)", {
  # Non-diagonal theta
  ndim <- 2
  theta <- matrix(c(0.5, 0.1, 0.1, 0.3), nrow = 2)
  model <- affectOU(ndim = ndim, theta = theta, mu = c(0, 0), gamma = diag(2))

  expect_silent(simulate(model, stop = 100, dt = .1, save_at = .1, nsim = 1))
})

test_that("simulate.affectOU handles correlated noise (2D)", {
  # Correlated sigma
  ndim <- 2
  theta <- diag(2) * 0.5
  sigma <- matrix(c(1.25, 1, 1, 1.25), nrow = 2)
  model <- affectOU(ndim = ndim, theta = theta, mu = c(0, 0), sigma = sigma)

  expect_silent(simulate(model, stop = 100, dt = .1, save_at = .1, nsim = 1))
})

# Test simulate method (higher dimensions) -----------------------------------

test_that("simulate.affectOU works for 10D", {
  ndim <- 10
  theta <- diag(ndim) * 0.5
  mu <- rep(0, ndim)
  gamma <- diag(ndim)

  model <- affectOU(ndim = ndim, theta = theta, mu = mu, gamma = gamma)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)

  expect_equal(dim(sim[["data"]]), c(101, ndim, 1))
})


# Test model properties (1D) -------------------------------------------------

test_that("OU model has correct stationary distribution (1D)", {
  # Simulate long trajectory
  mu <- 2
  gamma <- 1
  theta <- 0.5
  model <- affectOU(theta = theta, mu = mu, gamma = gamma)
  sim <- simulate(model, stop = 1000, dt = .1, save_at = .1, nsim = 1)

  # Remove burn-in
  data <- sim[["data"]][5000:10001, 1, 1]

  # Check empirical mean close to mu
  expect_equal(mean(data), mu, tolerance = 0.2)

  # Check empirical variance close to gamma^2 / (2*theta)
  theoretical_var <- gamma^2 / (2 * theta)
  expect_equal(var(data), theoretical_var, tolerance = 0.3)
})

test_that("OU model autocorrelation decays exponentially (1D)", {
  theta <- 0.5
  dt <- 0.1
  model <- affectOU(theta = theta, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .01, save_at = .1, nsim = 1, seed = 123)

  # Compute autocorrelation at lag 1
  acf_result <- acf(sim[["data"]], lag.max = 1, plot = FALSE)
  empirical_acf1 <- acf_result$acf[2]

  # Theoretical ACF at lag 1: exp(-theta * dt)
  theoretical_acf1 <- exp(-theta * dt)

  expect_equal(empirical_acf1, theoretical_acf1, tolerance = 0.1)
})

# head/tail ------------------------------------------------------------------

test_that("head.simulate_affectOU returns a data.frame with first n rows", {
  sim <- quick_sim(ndim = 2, nsim = 3)

  h <- head(sim, n = 5)
  expect_s3_class(h, "data.frame")
  expect_named(h, c("time", "dim", "sim", "value"))
  expect_equal(nrow(h), 5)
  expect_equal(h$time, sim$times[1:5])
})

test_that("tail.simulate_affectOU returns a data.frame with last n rows", {
  sim <- quick_sim(ndim = 2, nsim = 3)

  t <- tail(sim, n = 7)
  expect_s3_class(t, "data.frame")
  expect_named(t, c("time", "dim", "sim", "value"))
  expect_equal(nrow(t), 7)
  expect_equal(t$time, tail(sim$times, 7))
})

test_that("head/tail validate n is positive integer", {
  sim <- quick_sim(ndim = 1, nsim = 1)

  expect_error(head(sim, n = 0), "`n` must be a whole number")
  expect_error(tail(sim, n = -1), "`n` must be a whole number")
})

# Test edge cases ------------------------------------------------------------

test_that("affectOU handles very small dt", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)

  expect_silent(
    simulate(model, stop = 10, dt = .001)
  )
})

test_that("affectOU handles very large theta (fast reversion)", {
  mu <- 0
  model <- affectOU(theta = 10, mu = mu, gamma = .1)
  sim <- simulate(model, stop = 10, dt = .01, save_at = .1, nsim = 1, initial = 5)

  # Should revert very quickly
  expect_true(abs(sim[["data"]][50] - mu) < .1)
})

test_that("affectOU handles very small theta (slow reversion)", {
  x0 <- 5
  mu <- 0
  model <- affectOU(theta = 0.001, mu = mu, gamma = .1)
  sim <- simulate(model, stop = 10, dt = .01, save_at = .1, nsim = 1, initial = x0)

  # Should still be far from equilibrium
  expect_true(abs(sim[["data"]][101] - mu) > 1)
})

test_that("affectOU data structure consistency across nsim (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)

  sim1 <- simulate(model, stop = 10, dt = .01, save_at = .1, nsim = 1)
  sim2 <- simulate(model, stop = 10, dt = .01, save_at = .1, nsim = 3)

  # Both should have same number of time points
  expect_equal(dim(sim1[["data"]])[1:2], dim(sim2[["data"]])[1:2])
})

test_that("simulate.affectOU includes stop without NA when time grids do not align", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 1, dt = 0.3, save_at = 0.5, seed = 1)

  expect_equal(sim[["times"]], c(0, 0.5, 1))
  expect_false(anyNA(sim[["data"]]))
})

test_that("simulate.affectOU draws initial states from rank-deficient stationary covariance", {
  model <- affectOU(ndim = 2, gamma = diag(c(1, 0)))

  expect_silent(
    sim <- simulate(model, stop = 1, dt = 0.1, save_at = 0.1, seed = 123)
  )
  expect_false(anyNA(sim[["data"]]))
})


# as.array -------------------------------------------------------------------

test_that("as.array returns 3D array with correct dimensions", {
  sim <- quick_sim(ndim = 2, nsim = 3)
  arr <- as.array(sim)

  expect_true(is.array(arr))
  expect_length(dim(arr), 3)
  expect_equal(dim(arr), c(length(sim$times), 2, 3))
})

test_that("as.array has correct dimnames", {
  sim <- quick_sim(ndim = 2, nsim = 3)
  arr <- as.array(sim)

  expect_named(dimnames(arr), c("time", "dim", "sim"))
  expect_equal(dimnames(arr)$dim, c("dim1", "dim2"))
  expect_equal(dimnames(arr)$sim, c("sim1", "sim2", "sim3"))
})

test_that("as.array works for univariate case", {
  sim <- quick_sim(ndim = 1, nsim = 1)
  arr <- as.array(sim)

  expect_equal(dim(arr)[2], 1)
  expect_equal(dim(arr)[3], 1)
})

# print.simulate_affectOU ---------------------------------------------------------

cli::test_that_cli(config = c("plain", "ansi"), "print.simulate_affectOU snapshot (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1, seed = 42)

  expect_snapshot(print(sim))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.simulate_affectOU snapshot (2D, nsim=3)", {
  ndim <- 2
  theta <- diag(ndim) * 0.5
  mu <- rep(0, ndim)
  gamma <- diag(ndim)
  model <- affectOU(ndim = ndim, theta = theta, mu = mu, gamma = gamma)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 3, seed = 123)

  expect_snapshot(print(sim))
})


# as.matrix ------------------------------------------------------------------

test_that("as.matrix long format has correct structure", {
  sim <- quick_sim(ndim = 2, nsim = 3)
  mat <- as.matrix(sim, direction = "long")

  expect_true(is.matrix(mat))
  expect_equal(ncol(mat), 4)
  expect_equal(colnames(mat), c("time", "dim", "sim", "value"))
})

test_that("as.matrix wide format has correct structure", {
  sim <- quick_sim(ndim = 2, nsim = 3)
  mat <- as.matrix(sim, direction = "wide")

  expect_true(is.matrix(mat))
  expect_equal(nrow(mat), length(sim$times))
  expect_equal(ncol(mat), 2 * 3)
})

test_that("as.matrix long is default", {
  sim <- quick_sim(ndim = 2, nsim = 1)

  expect_equal(as.matrix(sim), as.matrix(sim, direction = "long"))
})

test_that("as.matrix wide column names simplify appropriately", {
  # Single dim, single sim
  sim_1_1 <- quick_sim(ndim = 1, nsim = 1)
  expect_equal(colnames(as.matrix(sim_1_1, direction = "wide")), "dim1")

  # Single dim, multiple sim
  sim_1_3 <- quick_sim(ndim = 1, nsim = 3)
  expect_equal(
    colnames(as.matrix(sim_1_3, direction = "wide")),
    c("dim1.sim1", "dim1.sim2", "dim1.sim3")
  )

  # Multiple dim, single sim
  sim_2_1 <- quick_sim(ndim = 2, nsim = 1)
  expect_equal(
    colnames(as.matrix(sim_2_1, direction = "wide")),
    c("dim1", "dim2")
  )

  # Multiple dim, multiple sim
  sim_2_2 <- quick_sim(ndim = 2, nsim = 2)
  expect_equal(
    colnames(as.matrix(sim_2_2, direction = "wide")),
    c("dim1.sim1", "dim2.sim1", "dim1.sim2", "dim2.sim2")
  )
})


# as.data.frame --------------------------------------------------------------

test_that("as.data.frame long format has correct structure", {
  ndim <- 2
  nsim <- 3
  sim <- quick_sim(ndim = ndim, nsim = nsim)
  df <- as.data.frame(sim, direction = "long")

  expect_s3_class(df, "data.frame")
  expect_named(df, c("time", "dim", "sim", "value"))

  expected_rows <- length(sim$times) * ndim * nsim
  expect_equal(nrow(df), expected_rows)
})

test_that("as.data.frame wide format has correct structure", {
  ndim <- 2
  nsim <- 3
  sim <- quick_sim(ndim = ndim, nsim = nsim)
  df <- as.data.frame(sim, direction = "wide")

  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), length(sim$times))
  expect_equal(ncol(df), 1 + ndim * nsim)
  expect_true("time" %in% colnames(df))
})

test_that("as.data.frame long is default", {
  sim <- quick_sim(ndim = 2, nsim = 1)

  expect_equal(
    as.data.frame(sim),
    as.data.frame(sim, direction = "long")
  )
})


# as.list --------------------------------------------------------------------

test_that("as.list returns list with correct length", {
  sim <- quick_sim(ndim = 2, nsim = 3)
  lst <- as.list(sim)

  expect_type(lst, "list")
  expect_length(lst, 3)
  expect_named(lst, c("sim1", "sim2", "sim3"))
})

test_that("as.list wide format has correct structure", {
  sim <- quick_sim(ndim = 2, nsim = 3)
  lst <- as.list(sim, direction = "wide")

  expect_s3_class(lst[[1]], "data.frame")
  expect_named(lst[[1]], c("time", "dim1", "dim2"))
  expect_equal(nrow(lst[[1]]), length(sim$times))
})

test_that("as.list long format has correct structure", {
  sim <- quick_sim(ndim = 2, nsim = 3)
  lst <- as.list(sim, direction = "long")

  expect_s3_class(lst[[1]], "data.frame")
  expect_named(lst[[1]], c("time", "dim", "value"))
  expect_s3_class(lst[[1]]$dim, "factor")
})

test_that("as.list wide is default", {
  sim <- quick_sim(ndim = 2, nsim = 1)

  expect_equal(as.list(sim), as.list(sim, direction = "wide"))
})


# Data consistency -----------------------------------------------------------

test_that("coercion methods preserve data values", {
  ndim <- 2
  nsim <- 3
  sim <- quick_sim(ndim = ndim, nsim = nsim)

  arr <- as.array(sim)
  mat_wide <- as.matrix(sim, direction = "wide")
  df_wide <- as.data.frame(sim, direction = "wide")
  lst_wide <- as.list(sim, direction = "wide")[[1]]

  # All should have same values for first dimension
  expect_equal(arr[, 1, 1], mat_wide[, 1])
  expect_equal(unname(arr[, 1, 1]), df_wide[[2]])
  expect_equal(unname(arr[, 1, 1]), lst_wide$dim1)
})


# Test summary method --------------------------------------------------------
test_that("summary.simulate_affectOU returns correct class", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)
  s <- summary(sim)
  expect_s3_class(s, "summary_simulate_affectOU")
})

test_that("summary.simulate_affectOU has consistent structure (1D stationary)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 3)
  s <- summary(sim)

  # Check top-level components (flat structure)
  expect_named(s, c(
    "ndim", "nsim", "n_timepoints", "discard_initial_time",
    "dt", "stop", "save_at", "seed",
    "statistics", "theoretical"
  ))

  # Check statistics components
  expect_named(s$statistics, c("mean", "sd", "cov", "cor"))
  expect_length(s$statistics$mean, 1)
  expect_length(s$statistics$sd, 1)
  expect_null(s$statistics$cov) # NULL for 1D
  expect_null(s$statistics$cor) # NULL for 1D

  # Check theoretical components (stationary model)
  expect_named(s$theoretical, c("mean", "sd", "cov", "cor"))
  expect_length(s$theoretical$mean, 1)
  expect_length(s$theoretical$sd, 1)
  expect_null(s$theoretical$cov) # NULL for 1D
  expect_null(s$theoretical$cor) # NULL for 1D

  # Check flat metadata
  expect_equal(s$ndim, 1)
  expect_equal(s$nsim, 3)
  expect_equal(s$discard_initial_time, 0)
})

test_that("summary.simulate_affectOU has consistent structure (2D stationary)", {
  model <- affectOU(ndim = 2, theta = diag(c(0.5, 0.3)), mu = c(1, -1))
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 2)
  s <- summary(sim)

  # Check statistics components
  expect_length(s$statistics$mean, 2)
  expect_length(s$statistics$sd, 2)
  expect_true(is.matrix(s$statistics$cov))
  expect_equal(dim(s$statistics$cov), c(2, 2))
  expect_true(is.matrix(s$statistics$cor))
  expect_equal(dim(s$statistics$cor), c(2, 2))

  # Check theoretical components
  expect_length(s$theoretical$mean, 2)
  expect_length(s$theoretical$sd, 2)
  expect_true(is.matrix(s$theoretical$cov))
  expect_true(is.matrix(s$theoretical$cor))
})

test_that("summary.simulate_affectOU handles non-stationary model", {
  # Negative theta means non-stationary
  model <- affectOU(theta = -0.5, mu = 0, gamma = 1)
  sim <- suppressWarnings(simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1))
  s <- summary(sim)

  # Structure should be consistent (flat)
  expect_named(s, c(
    "ndim", "nsim", "n_timepoints", "discard_initial_time",
    "dt", "stop", "save_at", "seed",
    "statistics", "theoretical"
  ))

  # Statistics should still be computed
  expect_named(s$statistics, c("mean", "sd", "cov", "cor"))
  expect_length(s$statistics$mean, 1)

  # Theoretical should be NULL
  expect_null(s$theoretical)
})

test_that("summary.simulate_affectOU discard_initial_time filters time points", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)

  s_no_discard <- summary(sim, discard_initial_time = 0)
  s_with_discard <- summary(sim, discard_initial_time = 5)

  # Full simulation has 101 time points (0 to 10 by 0.1)
  expect_equal(s_no_discard$n_timepoints, 101)

  # With discard_initial_time = 5, should have 51 time points (5.0 to 10 by 0.1)
  expect_equal(s_with_discard$n_timepoints, 51)
  expect_equal(s_with_discard$discard_initial_time, 5)
})

test_that("summary.simulate_affectOU validates discard_initial_time parameter", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)

  expect_error(summary(sim, discard_initial_time = -1))
  expect_error(summary(sim, discard_initial_time = 10)) # discard_initial_time >= stop
  expect_error(summary(sim, discard_initial_time = "a"))
  expect_error(summary(sim, discard_initial_time = c(1, 2)))
})

test_that("summary.simulate_affectOU computes reasonable statistics", {
  # Long simulation should converge to theoretical values
  model <- affectOU(theta = 0.5, mu = 2, gamma = 1)
  sim <- simulate(model, stop = 1000, dt = .1, save_at = .1, nsim = 10, seed = 123)
  s <- summary(sim, discard_initial_time = 100)

  # Sample mean should be close to theoretical mean (mu = 2)
  expect_equal(s$statistics$mean, s$theoretical$mean, tolerance = 0.1)

  # Sample SD should be close to theoretical SD
  expect_equal(s$statistics$sd, s$theoretical$sd, tolerance = 0.1)
})

test_that("summary.simulate_affectOU pools multivariate statistics by dimension", {
  model <- affectOU(ndim = 2, gamma = 0)
  data <- array(NA_real_, dim = c(2, 2, 2))
  data[, 1, 1] <- c(1, 1)
  data[, 2, 1] <- c(10, 10)
  data[, 1, 2] <- c(2, 2)
  data[, 2, 2] <- c(20, 20)
  sim <- new_simulate_affectOU(
    model = model,
    data = data,
    times = c(0, 1),
    nsim = 2,
    dt = 1,
    stop = 1,
    save_at = 1,
    seed = NULL
  )

  s <- summary(sim)

  expect_equal(s$statistics$mean, c(1.5, 15))
  expect_equal(
    s$statistics$sd,
    c(stats::sd(c(1, 1, 2, 2)), stats::sd(c(10, 10, 20, 20)))
  )
})

test_that("print.summary_simulate_affectOU returns invisibly", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)
  s <- summary(sim)

  expect_invisible(print(s))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_simulate_affectOU snapshot (1D stationary)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 100, dt = .1, save_at = .1, nsim = 5, seed = 123)
  s <- summary(sim, discard_initial_time = 10)

  expect_snapshot(print(s))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_simulate_affectOU respects digits", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 100, dt = .1, save_at = .1, nsim = 5, seed = 123)
  s <- summary(sim, discard_initial_time = 10)

  expect_snapshot(print(s, digits = 2))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_simulate_affectOU snapshot (2D stationary)", {
  model <- affectOU(ndim = 2, theta = diag(c(0.5, 0.3)), mu = c(1, -1))
  sim <- simulate(model, stop = 100, dt = .1, save_at = .1, nsim = 3, seed = 456)
  s <- summary(sim, discard_initial_time = 20)

  expect_snapshot(print(s))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_simulate_affectOU snapshot (non-stationary)", {
  model <- affectOU(theta = -0.5, mu = 0, gamma = 1)
  sim <- suppressWarnings(
    simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1, seed = 789)
  )
  s <- summary(sim)

  expect_snapshot(print(s))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_simulate_affectOU snapshot (high-dimensional stationary)", {
  ndim <- 25
  model <- affectOU(ndim = ndim, theta = diag(ndim) * 0.5, mu = rep(0, ndim))
  sim <- simulate(model, stop = 50, dt = .1, save_at = .1, nsim = 2, seed = 101)
  s <- summary(sim, discard_initial_time = 10)

  expect_snapshot(print(s))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_simulate_affectOU snapshot (high-dimensional non-stationary)", {
  ndim <- 25
  theta <- diag(ndim) * 0.5
  theta[1, 1] <- -0.5 # Make one dimension non-stationary
  model <- affectOU(ndim = ndim, theta = theta, mu = rep(0, ndim))
  sim <- suppressWarnings(
    simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1, seed = 102)
  )
  s <- summary(sim)

  expect_snapshot(print(s))
})
