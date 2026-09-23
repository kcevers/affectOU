# Test print method ----------------------------------------------------------

cli::test_that_cli(config = c("plain", "ansi"), "print.affectOU snapshot (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)

  expect_snapshot(print(model))
  expect_snapshot(print(model, digits = 5))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.affectOU snapshot (2D)", {
  ndim <- 2
  theta <- matrix(c(0.5, 0, 0, 0.3), nrow = 2)
  mu <- c(1, -1)
  gamma <- diag(2)

  model <- affectOU(ndim = ndim, theta = theta, mu = mu, gamma = gamma)

  expect_snapshot(print(model))
  expect_snapshot(print(model, digits = 5))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.affectOU snapshot (21D)", {
  ndim <- 21
  model <- affectOU(ndim = ndim, theta = 1, mu = 0, gamma = 1)
  expect_snapshot(print(model))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.affectOU digits snapshot", {
  model <- affectOU(theta = 0.123456, mu = 0, gamma = 1)

  expect_snapshot(print(model, digits = 1))
  expect_snapshot(print(model, digits = 5))
})


# Test summary method --------------------------------------------------------

test_that("summary.affectOU returns correct class", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  s <- summary(model)

  expect_s3_class(s, "summary_affectOU")
})

test_that("summary.affectOU contains all expected components (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  s <- summary(model)

  expect_named(s, c(
    "ndim", "stability", "stationary",
    "coupling", "noise_structure"
  ))

  expect_equal(s$ndim, 1)
  expect_s3_class(s$stability, "stability_affectOU")
  expect_s3_class(s$stationary, "stationary_affectOU")
  expect_true(is.na(s$coupling)) # NA for 1D
  expect_true(is.na(s$noise_structure)) # NA for 1D
})

test_that("summary.affectOU contains all expected components (2D)", {
  model <- affectOU(ndim = 2, theta = diag(c(0.5, 0.3)), mu = c(0, 0), gamma = diag(2))
  s <- summary(model)

  expect_equal(s$ndim, 2)
  expect_s3_class(s$stability, "stability_affectOU")
  expect_s3_class(s$stationary, "stationary_affectOU")
  expect_null(s$coupling) # NULL for diagonal theta
  expect_null(s$noise_structure) # NULL for diagonal sigma
})

test_that("summary.affectOU delegates correctly to sub-generics", {
  model <- affectOU(theta = 0.5, mu = 3, gamma = 1)
  s <- summary(model)

  # Summary results should match calling the generics directly
  expect_equal(s$stationary$mean, stationary(model)$mean)
  expect_equal(s$stationary$sd, stationary(model)$sd)
  expect_equal(s$stability$is_stable, stability(model)$is_stable)
})

test_that("summary.affectOU detects coupling structure in theta", {
  model_diag <- affectOU(ndim = 2, theta = diag(c(0.5, 0.3)))
  model_coupled <- affectOU(ndim = 2, theta = matrix(c(0.5, 0.1, 0.1, 0.3), 2, 2))

  # Diagonal theta -> NULL coupling
  expect_null(summary(model_diag)$coupling)

  # Coupled theta -> data frame with coupling info
  coupling <- summary(model_coupled)$coupling
  expect_s3_class(coupling, "data.frame")
  expect_named(coupling, c("from", "to", "value", "sign"))
  expect_equal(nrow(coupling), 2) # Two off-diagonal elements
})

test_that("summary.affectOU coupling direction is correct (col influences row)", {
  # theta_12 = 0.2 means column 2 influences row 1, i.e., Dim 2 -> Dim 1
  # theta_21 = 0 means no influence from column 1 to row 2
  theta <- matrix(c(0.5, 0, 0.2, 0.3), nrow = 2)
  # theta is:
  #      [,1] [,2]
  # [1,]  0.5  0.2   <- row 1: theta_12 = 0.2
  # [2,]  0.0  0.3   <- row 2: theta_21 = 0

  model <- affectOU(ndim = 2, theta = theta)
  coupling <- summary(model)$coupling

  # Should have exactly one coupling: from=2, to=1 (Dim 2 -> Dim 1)
  expect_equal(nrow(coupling), 1)
  expect_equal(coupling$from, 2)
  expect_equal(coupling$to, 1)
  expect_equal(coupling$value, 0.2)
  expect_equal(coupling$sign, "+")
})

test_that("summary.affectOU coupling captures asymmetric coupling", {
  # Asymmetric coupling: Dim 1 inhibits Dim 2, Dim 2 excites Dim 1
  # theta_12 = 0.15 (positive): Dim 2 -> Dim 1 (+)
  # theta_21 = -0.1 (negative): Dim 1 -> Dim 2 (-)
  theta <- matrix(c(0.5, -0.1, 0.15, 0.3), nrow = 2)

  model <- affectOU(ndim = 2, theta = theta)
  coupling <- summary(model)$coupling

  expect_equal(nrow(coupling), 2)

  # Find the coupling from Dim 2 to Dim 1
  c_2to1 <- coupling[coupling$from == 2 & coupling$to == 1, ]
  expect_equal(nrow(c_2to1), 1)
  expect_equal(c_2to1$value, 0.15)
  expect_equal(c_2to1$sign, "+")

  # Find the coupling from Dim 1 to Dim 2
  c_1to2 <- coupling[coupling$from == 1 & coupling$to == 2, ]
  expect_equal(nrow(c_1to2), 1)
  expect_equal(c_1to2$value, -0.1)
  expect_equal(c_1to2$sign, "-")
})

test_that("summary.affectOU handles unstable system", {
  # Verify summary delegates correctly even for unstable systems
  model <- suppressWarnings(affectOU(theta = -0.5, mu = 0, gamma = 1))
  s <- summary(model)

  expect_false(s$stability$is_stable)
  expect_false(s$stationary$is_stable)
})


test_that("summary.affectOU detects noise correlation structure in sigma", {
  ndim <- 2
  model_diag <- affectOU(
    ndim = ndim, theta = 1,
    gamma = diag(ndim)
  )
  model_corr <- affectOU(
    ndim = ndim, theta = 1,
    sigma = matrix(c(1.09, 0.6, 0.6, 1.09), ndim, ndim)
  )

  # Diagonal sigma -> NULL noise_structure
  expect_null(summary(model_diag)$noise_structure)

  # Correlated noise -> data frame with structure info
  noise <- summary(model_corr)$noise_structure
  expect_s3_class(noise, "data.frame")
  expect_named(noise, c("dim1", "dim2", "value", "sign"))
  expect_equal(nrow(noise), 1) # One unique pair (upper triangle)
})


# print.summary_affectOU ----------------------------------------------------

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_affectOU snapshot (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  s <- summary(model)

  expect_snapshot(print(s))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_affectOU snapshot (2D)", {
  model <- affectOU(ndim = 2, theta = diag(c(0.5, 0.3)), mu = c(0, 0), gamma = diag(2))
  s <- summary(model)

  expect_snapshot(print(s))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_affectOU snapshot (coupled)", {
  theta <- matrix(c(0.5, 0.1, 0.1, 0.3), nrow = 2)
  model <- affectOU(ndim = 2, theta = theta, mu = c(0, 0), gamma = diag(2))
  s <- summary(model)

  expect_snapshot(print(s))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_affectOU snapshot (unstable)", {
  model <- suppressWarnings(affectOU(theta = -0.5, mu = 0, gamma = 1))
  s <- summary(model)

  expect_snapshot(print(s))
})


test_that("print.summary_affectOU returns invisibly", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  s <- summary(model)

  expect_invisible(print(s))
})


# Test update method ----------------------------------------------------------

test_that("update.affectOU works (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  new_theta <- 0.2
  new_mu <- 4
  new_gamma <- 0.5
  model2 <- update(model, theta = new_theta, mu = new_mu, gamma = new_gamma)

  expect_equal(model2[["parameters"]][["theta"]], as.matrix(new_theta))
  expect_equal(model2[["parameters"]][["mu"]], new_mu)
  expect_equal(model2[["parameters"]][["gamma"]], as.matrix(new_gamma))
  expect_equal(model2[["stationary"]][["mean"]], new_mu)
})

test_that("update.affectOU works (2D)", {
  ndim <- 2
  theta <- matrix(c(0.5, 0, 0, 0.3), nrow = 2)
  model <- affectOU(ndim = ndim, theta = theta, mu = c(0, 0), gamma = diag(2))

  new_mu <- c(1, -1)
  model2 <- update(model, mu = new_mu)

  expect_equal(model2[["parameters"]][["mu"]], new_mu)
  expect_equal(model2[["parameters"]][["theta"]], theta) # Unchanged
  expect_equal(model2[["parameters"]][["gamma"]], diag(2)) # Unchanged
  expect_equal(model2[["parameters"]][["sigma"]], diag(2)) # Unchanged
})

test_that("update.affectOU preserves dimensionality", {
  # 1D stays 1D
  model_1d <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  updated_1d <- update(model_1d, mu = 2)
  expect_equal(updated_1d[["ndim"]], 1)

  # 2D stays 2D
  model_2d <- affectOU(ndim = 2, theta = diag(2), mu = c(0, 0), gamma = diag(2))
  updated_2d <- update(model_2d, mu = c(1, 1))
  expect_equal(updated_2d[["ndim"]], 2)
})

test_that("update to increase dimensionality works", {
  model <- affectOU(ndim = 1)
  expect_silent(model2 <- update(model, ndim = 2))
})

test_that("update to decrease dimensionality throws error", {
  model <- affectOU(ndim = 2)
  expect_error(update(model, ndim = 1))
})


# Test coef method ------------------------------------------------------------

test_that("coef.affectOU works (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  params <- coef(model)

  expect_equal(params$theta, 0.5) # not a matrix
  expect_equal(params$mu, 0)
  expect_equal(params$gamma, 1) # not a matrix
  expect_equal(params$sigma, 1) # not a matrix
})

test_that("coef.affectOU works (2D)", {
  ndim <- 2
  theta <- matrix(c(0.5, 0, 0, 0.3), nrow = 2)
  mu <- c(1, -1)
  gamma <- diag(2)

  model <- affectOU(ndim = ndim, theta = theta, mu = mu, gamma = gamma)
  params <- coef(model)

  expect_equal(params$theta, theta)
  expect_equal(params$mu, mu)
  expect_equal(params$gamma, gamma)
  expect_equal(params$sigma, gamma %*% t(gamma))
})


# plot.affectOU -------------------------------------------------------------

test_that("plot.affectOU errors", {
  model <- affectOU()

  expect_error(
    plot(model),
    class = "affectOU_error_plot_unsupported"
  )
})
