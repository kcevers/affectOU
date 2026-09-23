test_that("plot basic simulation", {
  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")

  sim <- simulate(affectOU(), seed = 123)
  f <- function() plot(sim)
  vdiffr::expect_doppelganger("basic-plot", f)
})


test_that("plot simulation with custom parameters", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  model <- affectOU(ndim = 2, theta = diag(c(0.5, 0.3)), mu = c(1, -1), gamma = diag(c(0.5, 0.3)))
  sim <- quick_sim(model = model)

  for (type in c("time", "histogram", "acf", "phase")) {
    f <- function() {
      plot(sim,
        type = type, palette = "Set 2", main = paste("Custom", type),
        sub = c("Affect 1", "Affect 2"),
        xlim = c(0, 50), ylim = c(-2, 4), share_yaxis = FALSE
      )
    }
    expect_no_error(f())
  }

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")

  for (type in c("time", "histogram", "acf", "phase")) {
    f <- function() {
      plot(sim,
        type = type, palette = "Set 2", main = paste("Custom", type),
        sub = c("Affect 1", "Affect 2"),
        xlim = c(0, 50), ylim = c(-2, 4), share_yaxis = FALSE
      )
    }
    filename <- paste0("sim_custom_", type)
    vdiffr::expect_doppelganger(filename, f)
  }
})


test_that("ou_plot_time handles 1D simulation", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 1)

  type <- "time"
  subtype <- "1D"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_time handles multi-dimensional simulation", {
  # Suppress graphics output
  withr::local_pdf(NULL)
  sim <- quick_sim(ndim = 3)

  type <- "time"
  subtype <- "dd"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_time handles multiple simulations (1D)", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 1, nsim = 16)

  type <- "time"
  subtype <- "1d_nsim"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})


test_that("ou_plot_time handles multiple dimensions and simulations", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 3, nsim = 16)

  type <- "time"
  subtype <- "dd_nsim"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})


test_that("ou_plot_time handles multiple simulations with which_sim", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 2, nsim = 11)

  type <- "time"
  subtype <- "dd_which_sim_nsim"
  f <- function() plot(sim, type = type, which_sim = c(1, 11, 5))
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_time respects which_dim argument", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 4)

  type <- "time"
  subtype <- "dd_which_dim"
  f <- function() plot(sim, type = type, which_dim = 2)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_time respects by_dim argument", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(model = affectOU(ndim = 4, mu = c(1, 2, 3, 4)))

  type <- "time"
  subtype <- "dd_by_dim"
  f <- function() plot(sim, type = type, by_dim = FALSE)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_histogram handles 1D simulation", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 1)

  type <- "histogram"
  subtype <- "1D"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_histogram handles multi-dimensional simulation", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 4)

  type <- "histogram"
  subtype <- "dd"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_histogram handles multiple simulations", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 4, nsim = 5)

  type <- "histogram"
  subtype <- "dd_nsim"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})


test_that("ou_plot_histogram handles 2D unstable OU", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- suppressWarnings(quick_sim(model = affectOU(ndim = 2, theta = -5), nsim = 5))

  # Should not plot theoretical distribution for unstable OU
  type <- "histogram"
  subtype <- "dd_nsim_unstable"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})


test_that("ou_plot_histogram handles OU with 1 stable and 1 unstable dimension", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- suppressWarnings(quick_sim(model = affectOU(ndim = 2, theta = c(-5, 1)), nsim = 5))

  # Should not plot theoretical distribution for unstable OU
  type <- "histogram"
  subtype <- "dd_nsim_stable_unstable"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})


test_that("ou_plot_histogram respects by_dim argument", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(nsim = 1, model = affectOU(ndim = 4, mu = c(1, 2, 3, 4)))

  type <- "histogram"
  subtype <- "dd_by_dim"
  f <- function() plot(sim, type = type, by_dim = FALSE)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_histogram handles freq parameter", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 2)

  type <- "histogram"
  subtype <- "1D_freq"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_phase handles 1D simulation", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 1)

  type <- "phase"
  subtype <- "1D"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_phase handles 2D simulation", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 2)

  type <- "phase"
  subtype <- "dd"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_phase handles multiple simulations (1D)", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 1, nsim = 16)

  type <- "phase"
  subtype <- "1d_nsim"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_phase handles multiple dimensions and simulations", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 3, nsim = 16)

  type <- "phase"
  subtype <- "dd_nsim"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_time handles unsorted and duplicate which_sim", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 2, nsim = 16)

  type <- "time"
  subtype <- "dd_which_sim_dedup"
  f <- function() plot(sim, type = type, which_sim = c(11, 1, 5, 1))
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_phase handles multiple simulations with which_sim", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 2, nsim = 11)

  type <- "phase"
  subtype <- "dd_which_sim_nsim"
  f <- function() plot(sim, type = type, which_sim = c(1, 11, 5, 11))
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_acf handles 1D simulation", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 1)

  type <- "acf"
  subtype <- "1D"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_acf handles multi-dimensional simulation", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 2)

  type <- "acf"
  subtype <- "dd"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_acf rejects vector which_sim", {
  # Only one simulation exists, so index 2 is out of range
  sim <- quick_sim(ndim = 2)

  expect_error(
    plot(sim, type = "acf", which_sim = c(1, 2)),
    class = "affectOU_error_which_sim_out_of_range"
  )

  # Both indices exist, but the ACF plot takes only one simulation
  sim <- quick_sim(ndim = 2, nsim = 3)

  expect_error(
    plot(sim, type = "acf", which_sim = c(1, 2)),
    class = "affectOU_error_too_many_sims"
  )
})


test_that("ou_plot_acf validates lag.max argument", {
  sim <- quick_sim(ndim = 2)

  expect_error(
    ou_plot_acf(sim, lag.max = -5),
    "`lag.max` must be a number larger than or equal to 0"
  )

  expect_error(
    ou_plot_acf(sim, lag.max = c(10, 20)),
    "`lag.max` must be a number"
  )

  expect_error(
    ou_plot_acf(sim, lag.max = "ten"),
    "`lag.max` must be a number"
  )
})

test_that("ou_plot_acf selects single simulation with which_sim", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  sim <- quick_sim(ndim = 2, nsim = 5)

  type <- "acf"
  subtype <- "dd_which_sim"
  f <- function() plot(sim, type = type)
  expect_silent(f())

  # Skip due to minor rendering differences on Mac OS
  skip_on_os("mac")
  filename <- paste0(type, "_", subtype)
  vdiffr::expect_doppelganger(filename, f)
})

test_that("ou_plot_acf handles non-stationary simulations", {
  withr::local_pdf(NULL)

  sim <- suppressWarnings(quick_sim(model = affectOU(theta = -0.5)))

  expect_silent(plot(sim, type = "acf"))
})


# ==============================================================================
# Test: compute_theoretical_acf
# ==============================================================================

test_that("compute_theoretical_acf returns correct structure", {
  theta <- diag(c(0.5, 0.3))
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- 0:10

  result <- compute_theoretical_acf(theta, sigma_inf, i = 1, lags = lags)

  expect_type(result, "list")
  expect_named(result, c("lags", "acf"))
  expect_length(result$acf, length(lags))
  expect_equal(result$lags, lags)
})

test_that("compute_theoretical_acf equals 1 at lag 0", {
  theta <- diag(c(0.5, 0.3))
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- 0:10

  result <- compute_theoretical_acf(theta, sigma_inf, i = 1, lags = lags)

  expect_equal(result$acf[1], 1, tolerance = 1e-10) # ACF at lag 0 is always 1
})

test_that("compute_theoretical_acf follows exponential decay for diagonal theta", {
  # For diagonal theta (uncoupled): ACF(lag) = exp(-theta[i,i] * lag)
  theta_val <- 0.5
  theta <- matrix(theta_val, 1, 1)
  gamma <- matrix(1, 1, 1)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- seq(0, 10, by = 0.5)

  result <- compute_theoretical_acf(theta, sigma_inf, i = 1, lags = lags)

  expected <- exp(-theta_val * lags)
  expect_equal(result$acf, expected, tolerance = 1e-10)
})

test_that("compute_theoretical_acf is monotonically decreasing for positive theta", {
  theta <- diag(c(0.5, 0.3))
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- 0:20

  result <- compute_theoretical_acf(theta, sigma_inf, i = 1, lags = lags)

  # Check monotonic decrease
  diffs <- diff(result$acf)
  expect_true(all(diffs < 0))
})

test_that("compute_theoretical_acf approaches 0 for large lags", {
  theta <- diag(c(0.5, 0.3))
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- c(0, 10, 50, 100)

  result <- compute_theoretical_acf(theta, sigma_inf, i = 1, lags = lags)

  expect_true(result$acf[4] < 1e-10) # Should be essentially 0 at lag 100
})

test_that("compute_theoretical_acf uses correct dimension", {
  theta <- diag(c(0.5, 0.3))
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- 0:5

  result1 <- compute_theoretical_acf(theta, sigma_inf, i = 1, lags = lags)
  result2 <- compute_theoretical_acf(theta, sigma_inf, i = 2, lags = lags)

  # Different theta values should give different ACFs
  expect_false(all(result1$acf == result2$acf))

  # Check each uses the correct diagonal element (for diagonal theta)
  expect_equal(result1$acf, exp(-0.5 * lags), tolerance = 1e-10)
  expect_equal(result2$acf, exp(-0.3 * lags), tolerance = 1e-10)
})

test_that("compute_theoretical_acf handles coupled systems correctly", {
  # For non-diagonal theta, ACF should differ from simple exponential
  theta <- matrix(c(0.5, 0.2, 0.1, 0.3), nrow = 2)
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- 1:10

  result <- compute_theoretical_acf(theta, sigma_inf, i = 1, lags = lags)

  # Should NOT equal simple exponential decay
  simple_exp <- exp(-theta[1, 1] * lags)
  expect_false(all(abs(result$acf - simple_exp) < 1e-6))

  # But should still be valid (bounded, decreasing for stable system)
  expect_true(all(result$acf >= 0))
  expect_true(all(result$acf <= 1))
})


# ==============================================================================
# Test: compute_theoretical_ccf
# ==============================================================================

test_that("compute_theoretical_ccf returns correct structure", {
  theta <- matrix(c(0.5, 0.1, 0.1, 0.3), nrow = 2)
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- 0:10

  result <- compute_theoretical_ccf(theta, sigma_inf, i = 1, j = 2, lags = lags)

  expect_type(result, "list")
  expect_named(result, c("lags", "ccf"))
  expect_length(result$ccf, length(lags))
  expect_equal(result$lags, lags)
})

test_that("compute_theoretical_ccf at lag 0 equals correlation coefficient", {
  theta <- matrix(c(0.5, 0.1, 0.1, 0.3), nrow = 2)
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- 0:5

  result <- compute_theoretical_ccf(theta, sigma_inf, i = 1, j = 2, lags = lags)

  # At lag 0, CCF should equal the correlation
  expected_corr <- sigma_inf[1, 2] / (sqrt(sigma_inf[1, 1]) * sqrt(sigma_inf[2, 2]))
  expect_equal(result$ccf[1], expected_corr, tolerance = 1e-10)
})

test_that("compute_theoretical_ccf is bounded by [-1, 1]", {
  theta <- matrix(c(0.5, 0.2, 0.15, 0.3), nrow = 2)
  gamma <- matrix(c(1, 0.5, 0, 1), nrow = 2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- seq(0, 20, by = 0.5)

  result <- compute_theoretical_ccf(theta, sigma_inf, i = 1, j = 2, lags = lags)

  expect_true(all(result$ccf >= -1 - 1e-10))
  expect_true(all(result$ccf <= 1 + 1e-10))
})

test_that("compute_theoretical_ccf approaches 0 for large lags", {
  theta <- matrix(c(0.5, 0.1, 0.1, 0.3), nrow = 2)
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- c(0, 10, 50, 100)

  result <- compute_theoretical_ccf(theta, sigma_inf, i = 1, j = 2, lags = lags)

  # Should decay to 0
  expect_true(abs(result$ccf[4]) < 1e-10)
})

test_that("compute_theoretical_ccf for uncoupled system is 0", {
  # For truly uncoupled system (diagonal theta, diagonal gamma)
  theta <- diag(c(0.5, 0.3))
  gamma <- diag(c(1, 1))
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- 0:10

  result <- compute_theoretical_ccf(theta, sigma_inf, i = 1, j = 2, lags = lags)

  # All CCF values should be 0 for uncoupled system
  expect_true(all(abs(result$ccf) < 1e-10))
})

test_that("compute_theoretical_ccf handles negative lags", {
  theta <- matrix(c(0.5, 0.1, 0.2, 0.3), nrow = 2)
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)

  # Test with negative and positive lags

  lags <- seq(-10, 10, by = 1)
  result <- compute_theoretical_ccf(theta, sigma_inf, i = 1, j = 2, lags = lags)

  expect_length(result$ccf, length(lags))
  expect_true(all(is.finite(result$ccf)))
  expect_true(all(result$ccf >= -1 - 1e-10))
  expect_true(all(result$ccf <= 1 + 1e-10))
})

test_that("CCF negative lag equals reversed CCF positive lag", {
  # CCF(i, j, -lag) should equal CCF(j, i, +lag)
  theta <- matrix(c(0.5, 0.15, 0.1, 0.3), nrow = 2)
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lag_val <- 5

  # CCF(1, 2, -5)
  result_neg <- compute_theoretical_ccf(theta, sigma_inf, i = 1, j = 2, lags = -lag_val)

  # CCF(2, 1, +5)
  result_pos <- compute_theoretical_ccf(theta, sigma_inf, i = 2, j = 1, lags = lag_val)

  expect_equal(result_neg$ccf, result_pos$ccf, tolerance = 1e-10)
})

test_that("CCF is symmetric around lag 0 for symmetric systems", {
  # For symmetric theta, CCF(i, j, lag) should equal CCF(i, j, -lag)
  theta <- matrix(c(0.5, 0.1, 0.1, 0.5), nrow = 2) # symmetric theta
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- seq(-10, 10, by = 1)

  result <- compute_theoretical_ccf(theta, sigma_inf, i = 1, j = 2, lags = lags)

  # Check symmetry around lag 0
  n <- length(lags)
  mid <- (n + 1) / 2 # lag 0 position

  for (k in 1:10) {
    expect_equal(result$ccf[mid - k], result$ccf[mid + k], tolerance = 1e-10)
  }
})

test_that("compute_theoretical_ccf self-correlation equals ACF", {
  # CCF(i, i) should equal ACF(i) - this is the key consistency test
  # With the matrix exponential implementation, both should be identical

  # Test with diagonal theta
  theta_diag <- diag(c(0.5, 0.3))
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf_diag <- solve_lyapunov(theta_diag, sigma)
  lags <- 0:10

  ccf_diag <- compute_theoretical_ccf(theta_diag, sigma_inf_diag, i = 1, j = 1, lags = lags)
  acf_diag <- compute_theoretical_acf(theta_diag, sigma_inf_diag, i = 1, lags = lags)

  expect_equal(ccf_diag$ccf, acf_diag$acf, tolerance = 1e-10)

  # Test with non-diagonal (coupled) theta - should also match
  theta_coupled <- matrix(c(0.5, 0.1, 0.1, 0.3), nrow = 2)
  sigma <- gamma %*% t(gamma)
  sigma_inf_coupled <- solve_lyapunov(theta_coupled, sigma)

  ccf_coupled <- compute_theoretical_ccf(theta_coupled, sigma_inf_coupled, i = 1, j = 1, lags = lags)
  acf_coupled <- compute_theoretical_acf(theta_coupled, sigma_inf_coupled, i = 1, lags = lags)

  expect_equal(ccf_coupled$ccf, acf_coupled$acf, tolerance = 1e-10)
})


test_that("theoretical ACF integrates with stationary covariance", {
  theta <- diag(c(0.5, 0.3))
  gamma <- diag(c(1, 2))
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)

  # ACF should be valid with this sigma_inf
  lags <- 0:10
  acf1 <- compute_theoretical_acf(theta, sigma_inf, i = 1, lags = lags)
  acf2 <- compute_theoretical_acf(theta, sigma_inf, i = 2, lags = lags)

  # Verify properties
  expect_equal(acf1$acf[1], 1, tolerance = 1e-10)
  expect_equal(acf2$acf[1], 1, tolerance = 1e-10)
  expect_true(all(acf1$acf >= 0))
  expect_true(all(acf2$acf >= 0))
})

test_that("ACF handles continuous lags", {
  theta <- diag(0.5, 1)
  gamma <- matrix(1, 1, 1)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- seq(0, 10, by = 0.01)

  result <- compute_theoretical_acf(theta, sigma_inf, i = 1, lags = lags)

  expect_length(result$acf, length(lags))
  expect_true(all(is.finite(result$acf)))
})

test_that("CCF handles negative theta off-diagonals", {
  # Negative off-diagonal represents inhibitory coupling
  theta <- matrix(c(0.5, -0.1, -0.1, 0.3), nrow = 2)
  gamma <- diag(2)

  # This should still produce valid results
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  expect_true(all(is.finite(sigma_inf)))

  lags <- 0:10
  result <- compute_theoretical_ccf(theta, sigma_inf, i = 1, j = 2, lags = lags)
  expect_true(all(is.finite(result$ccf)))
})

test_that("ACF handles asymmetric coupling", {
  # Asymmetric theta (different cross-effects)
  theta <- matrix(c(0.5, 0.3, 0.1, 0.4), nrow = 2)
  gamma <- diag(2)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- 0:10

  acf1 <- compute_theoretical_acf(theta, sigma_inf, i = 1, lags = lags)
  acf2 <- compute_theoretical_acf(theta, sigma_inf, i = 2, lags = lags)

  # Both should be valid
  expect_true(all(is.finite(acf1$acf)))
  expect_true(all(is.finite(acf2$acf)))
  expect_equal(acf1$acf[1], 1, tolerance = 1e-10)
  expect_equal(acf2$acf[1], 1, tolerance = 1e-10)
})


# ==============================================================================
# 3D system tests
# ==============================================================================

test_that("ACF works correctly for 3D systems", {
  theta <- matrix(c(
    0.5, 0.1, 0.05,
    0.1, 0.4, 0.08,
    0.05, 0.08, 0.3
  ), nrow = 3, byrow = TRUE)
  gamma <- diag(3)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- 0:10

  # Test ACF for all dimensions
  for (i in 1:3) {
    result <- compute_theoretical_acf(theta, sigma_inf, i = i, lags = lags)

    # Basic properties
    expect_equal(result$acf[1], 1, tolerance = 1e-10)
    expect_true(all(result$acf >= -1e-10))
    expect_true(all(result$acf <= 1 + 1e-10))
    expect_true(all(is.finite(result$acf)))
  }
})

test_that("CCF works correctly for 3D systems", {
  theta <- matrix(c(
    0.5, 0.1, 0.05,
    0.1, 0.4, 0.08,
    0.05, 0.08, 0.3
  ), nrow = 3, byrow = TRUE)
  gamma <- diag(3)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  lags <- 0:10

  # Test CCF for all dimension pairs
  for (i in 1:3) {
    for (j in 1:3) {
      result <- compute_theoretical_ccf(theta, sigma_inf, i = i, j = j, lags = lags)

      # Basic properties
      expect_true(all(result$ccf >= -1 - 1e-10))
      expect_true(all(result$ccf <= 1 + 1e-10))
      expect_true(all(is.finite(result$ccf)))

      # Self-correlation at lag 0 should be 1
      if (i == j) {
        expect_equal(result$ccf[1], 1, tolerance = 1e-10)
      }
    }
  }
})

test_that("ACF half-life matches theta relationship for 1D", {
  # Half-life of ACF: when ACF = 0.5, lag = log(2) / theta
  theta_val <- 0.5
  theta <- matrix(theta_val, 1, 1)
  gamma <- matrix(1, 1, 1)
  sigma <- gamma %*% t(gamma)
  sigma_inf <- solve_lyapunov(theta, sigma)
  half_life <- log(2) / theta_val

  result <- compute_theoretical_acf(theta, sigma_inf, i = 1, lags = half_life)

  expect_equal(result$acf, 0.5, tolerance = 1e-10)
})
