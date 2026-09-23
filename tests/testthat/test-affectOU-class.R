# Test constructor and validation (1D) ----------------------------------------
test_that("affectOU defaults create valid model object", {
  expect_silent(affectOU())
})

test_that("affectOU creates valid 1D model object", {
  theta <- 0.5
  mu <- 0
  gamma <- 1
  model <- affectOU(theta = theta, mu = mu, gamma = gamma)

  expect_s3_class(model, "affectOU")
  expect_equal(model[["parameters"]][["theta"]], as.matrix(theta)) # should be stored as matrix
  expect_equal(model[["parameters"]][["mu"]], mu)
  expect_equal(model[["parameters"]][["gamma"]], as.matrix(gamma)) # should be stored as matrix
  expect_equal(model[["parameters"]][["sigma"]], as.matrix(gamma %*% t(gamma))) # should be stored as matrix
  expect_equal(model[["stationary"]][["mean"]], mu) # stationary mean should equal mu
  expect_equal(model[["ndim"]], 1)
})

test_that("affectOU stores stationary distribution (1D stable)", {
  model <- affectOU(theta = 0.5, mu = 2, gamma = 1)
  stat <- model[["stationary"]]
  expect_true(stat[["is_stable"]])
  expect_equal(stat[["mean"]], 2)
  # Theoretical sd: sqrt(gamma^2 / (2*theta)) = sqrt(1 / 1) = 1
  expect_equal(stat[["sd"]], 1, tolerance = 1e-10)
  expect_null(stat[["cov"]]) # NULL for 1D
})

test_that("affectOU stores stationary distribution (1D unstable)", {
  model <- affectOU(theta = -0.5, mu = 0, gamma = 1)
  stat <- model[["stationary"]]
  expect_false(stat[["is_stable"]])
  expect_null(stat[["mean"]])
  expect_null(stat[["sd"]])
})


test_that("affectOU rejects Inf parameters (1D)", {
  expect_error(
    affectOU(theta = Inf),
    class = "affectOU_error_not_finite"
  )

  expect_error(
    affectOU(mu = Inf),
    class = "affectOU_error_not_finite"
  )

  expect_error(
    affectOU(gamma = Inf),
    class = "affectOU_error_not_finite"
  )

  expect_error(
    affectOU(sigma = Inf),
    class = "affectOU_error_not_finite"
  )
})

test_that("affectOU requires scalar parameters for 1D", {
  expect_error(
    affectOU(ndim = 1, theta = c(0.5, 0.3), mu = 0, gamma = 1),
    class = "affectOU_error_wrong_shape"
  )

  expect_error(
    affectOU(ndim = 1, theta = 0.5, mu = c(0, 1), gamma = 1),
    class = "affectOU_error_wrong_shape"
  )

  expect_error(
    affectOU(ndim = 1, theta = 0.5, mu = 0, gamma = c(1, 2)),
    class = "affectOU_error_wrong_shape"
  )

  expect_error(
    affectOU(ndim = 1, theta = 0.5, mu = 0, sigma = c(1, 2)),
    class = "affectOU_error_wrong_shape"
  )
})


test_that("affectOU infers ndim if not specified", {
  model <- affectOU(
    theta = diag(2),
    mu = c(0, 0),
    gamma = diag(2)
  )
  expect_equal(model[["ndim"]], 2)

  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  expect_equal(model[["ndim"]], 1)

  model <- affectOU(theta = diag(3), mu = 0, gamma = 1)
  expect_equal(model[["ndim"]], 3)

  model <- affectOU(theta = diag(3), mu = 0, gamma = 1)
  expect_equal(model[["ndim"]], 3)

  expect_error(
    affectOU(theta = diag(2), mu = 0, gamma = diag(3)),
    class = "affectOU_error_inconsistent_ndim"
  )
})

# Test constructor and validation (2D) ----------------------------------------

test_that("affectOU defaults create valid 2D model object", {
  ndim <- 2
  expect_silent(affectOU(ndim = ndim))
})

test_that("affectOU creates valid 2D model object", {
  ndim <- 2
  theta <- matrix(c(0.5, 0, 0, 0.3), nrow = ndim)
  mu <- c(0, 1)
  gamma <- diag(ndim)

  model <- affectOU(ndim = ndim, theta = theta, mu = mu, gamma = gamma)

  expect_s3_class(model, "affectOU")
  expect_equal(model[["parameters"]][["theta"]], theta)
  expect_equal(model[["parameters"]][["mu"]], mu)
  expect_equal(model[["parameters"]][["gamma"]], gamma)
  expect_equal(model[["stationary"]][["mean"]], mu) # stationary mean should equal mu
  expect_equal(model[["ndim"]], ndim)
})

test_that("affectOU stores stationary distribution (2D stable)", {
  ndim <- 2
  theta <- matrix(c(0.5, 0, 0, 0.3), nrow = ndim)
  mu <- c(0, 1)
  gamma <- diag(ndim)

  model <- affectOU(ndim = ndim, theta = theta, mu = mu, gamma = gamma)
  stat <- model[["stationary"]]

  expect_true(stat[["is_stable"]])
  expect_equal(stat[["mean"]], mu)
  expect_length(stat[["sd"]], ndim)
  expect_true(is.matrix(stat[["cov"]]))
  expect_equal(dim(stat[["cov"]]), c(ndim, ndim))
})

test_that("affectOU validates theta, gamma, sigma dimensions (2D)", {
  # Non-square matrix
  expect_error(
    affectOU(
      ndim = 2,
      theta = matrix(1:6, nrow = 2, ncol = 3)
    ),
    class = "affectOU_error_wrong_shape"
  )

  expect_error(
    affectOU(
      ndim = 2,
      gamma = matrix(1:6, nrow = 2, ncol = 3)
    ),
    class = "affectOU_error_wrong_shape"
  )

  expect_error(
    affectOU(
      ndim = 2,
      sigma = matrix(1:6, nrow = 2, ncol = 3)
    ),
    class = "affectOU_error_wrong_shape"
  )
})

test_that("affectOU validates mu dimensions (2D)", {
  ndim <- 2
  theta <- diag(2)
  gamma <- diag(2)

  # Wrong length
  expect_error(
    affectOU(ndim = ndim, mu = c(0, 0, 0)),
    class = "affectOU_error_wrong_shape"
  )

  # Scalar instead of vector
  expect_no_error(
    affectOU(ndim = ndim, theta = theta, mu = 0, gamma = gamma)
  )
})

test_that("affectOU validates gamma, sigma positive semi-definite (2D)", {
  ndim <- 2
  theta <- diag(2)
  mu <- c(0, 0)

  # Gamma must be lower triangular
  expect_error(
    affectOU(
      ndim = ndim,
      gamma = matrix(c(1, 2, 2, -1), nrow = 2)
    ),
    class = "affectOU_error_gamma_not_lower_triangular"
  )

  # Lower triangular gamma with negative values is fine (does not need PD)
  expect_no_error(
    affectOU(
      ndim = ndim,
      gamma = matrix(c(1, 2, 0, -1), nrow = 2)
    )
  )

  # But sigma should be positive semi-definite
  expect_error(
    affectOU(
      ndim = ndim,
      sigma = matrix(c(1, 2, 2, -1), nrow = 2)
    ),
    class = "affectOU_error_sigma_not_psd"
  )
})

test_that("sigma can be zero", {
  expect_no_error(m <- affectOU(ndim = 1, sigma = 0))
  expect_equal(m[["parameters"]][["sigma"]], matrix(0))
  expect_equal(m[["parameters"]][["gamma"]], matrix(0))
  expect_working_model(m)

  ndim <- 3
  expect_no_error(m <- affectOU(ndim = 3, sigma = 0))
  expect_equal(m[["parameters"]][["sigma"]], matrix(0, nrow = ndim, ncol = ndim))
  expect_equal(m[["parameters"]][["gamma"]], matrix(0, nrow = ndim, ncol = ndim))
  expect_working_model(m)

  expect_no_error(
    m <- affectOU(
      ndim = ndim,
      sigma = matrix(0, nrow = ndim, ncol = ndim)
    )
  )
  expect_equal(m[["parameters"]][["sigma"]], matrix(0, nrow = ndim, ncol = ndim))
  expect_equal(m[["parameters"]][["gamma"]], matrix(0, nrow = ndim, ncol = ndim))
  expect_working_model(m)
})


test_that("gamma can be zero", {
  expect_no_error(m <- affectOU(ndim = 1, gamma = 0))
  expect_equal(m[["parameters"]][["gamma"]], matrix(0))
  expect_equal(m[["parameters"]][["sigma"]], matrix(0))
  expect_working_model(m)

  ndim <- 3
  expect_no_error(m <- affectOU(ndim = 3, gamma = 0))
  expect_equal(m[["parameters"]][["gamma"]], matrix(0, nrow = ndim, ncol = ndim))
  expect_equal(m[["parameters"]][["sigma"]], matrix(0, nrow = ndim, ncol = ndim))
  expect_working_model(m)

  expect_no_error(
    m <- affectOU(
      ndim = ndim,
      gamma = matrix(0, nrow = ndim, ncol = ndim)
    )
  )
  expect_equal(m[["parameters"]][["gamma"]], matrix(0, nrow = ndim, ncol = ndim))
  expect_equal(m[["parameters"]][["sigma"]], matrix(0, nrow = ndim, ncol = ndim))
  expect_working_model(m)
})


test_that("theta can be zero", {
  expect_no_error(m <- affectOU(theta = 0))
  expect_equal(m[["parameters"]][["theta"]], matrix(0))
  expect_working_model(m)

  ndim <- 3
  expect_no_error(m <- affectOU(ndim = ndim, theta = matrix(0, nrow = ndim, ncol = ndim)))
  expect_equal(m[["parameters"]][["theta"]], matrix(0, nrow = ndim, ncol = ndim))
  expect_working_model(m)

  expect_no_error(m <- affectOU(ndim = ndim, theta = diag(0, nrow = ndim, ncol = ndim)))
  expect_equal(m[["parameters"]][["theta"]], matrix(0, nrow = ndim, ncol = ndim))
  expect_working_model(m)
})


test_that("converting sigma and gamma back and forth produces same sigma", {
  # 1D
  sigma_1d <- matrix(4)
  gamma_1d <- t(chol(sigma_1d))
  m1 <- affectOU(sigma = sigma_1d)
  gamma_1d_m1 <- m1$parameters$gamma
  expect_equal(m1$parameters$sigma, sigma_1d)
  expect_equal(
    gamma_1d_m1, gamma_1d
  )
  expect_equal(
    gamma_1d_m1 %*% t(gamma_1d_m1),
    sigma_1d
  )
  sigma_1d_rec <- gamma_1d_m1 %*% t(gamma_1d_m1)
  expect_equal(sigma_1d_rec, sigma_1d)

  # 2D with off-diagonal correlation
  sigma_2d <- matrix(c(2, 0.5, 0.5, 3), nrow = 2)
  gamma_2d <- t(chol(sigma_2d))
  m2 <- affectOU(ndim = 2, sigma = sigma_2d)
  gamma_2d_m2 <- m2$parameters$gamma
  expect_equal(m2$parameters$sigma, sigma_2d)
  expect_equal(
    gamma_2d_m2, gamma_2d
  )
  expect_equal(
    gamma_2d_m2 %*% t(gamma_2d_m2),
    sigma_2d
  )
  sigma_2d_rec <- gamma_2d_m2 %*% t(gamma_2d_m2)
  expect_equal(sigma_2d_rec, sigma_2d)
})


test_that("unstable OU models run", {
  expect_no_error(
    m <- affectOU(theta = -0.5, mu = 0, gamma = 1)
  )
  expect_working_model(m)

  ndim <- 2
  expect_no_error(
    m <- affectOU(
      ndim = ndim,
      theta = matrix(c(-0.5, 0, 0, -0.3), nrow = ndim),
      mu = c(0, 1),
      gamma = diag(ndim)
    )
  )
  expect_working_model(m)
})


test_that("affectOU rejects Inf parameters (2D)", {
  ndim <- 2
  theta <- diag(2)
  mu <- c(0, 0)
  gamma <- diag(2)

  expect_error(
    affectOU(ndim = ndim, theta = matrix(Inf, 2, 2)),
    class = "affectOU_error_not_finite"
  )

  expect_error(
    affectOU(ndim = ndim, mu = c(Inf, 0)),
    class = "affectOU_error_not_finite"
  )

  expect_error(
    affectOU(ndim = ndim, gamma = matrix(Inf, 2, 2)),
    class = "affectOU_error_not_finite"
  )

  expect_error(
    affectOU(ndim = ndim, sigma = matrix(Inf, 2, 2)),
    class = "affectOU_error_not_finite"
  )
})


test_that("affectOU rejects 0-dimensional systems", {
  expect_error(affectOU(ndim = 0), "`ndim` must be a whole number")
})


# Gamma lower-triangular constraint ------------------------------------------

test_that("gamma must be lower triangular for nD models", {
  # Upper triangular: rejected

  expect_error(
    affectOU(ndim = 2, gamma = matrix(c(1, 0, 0.5, 1), nrow = 2)),
    class = "affectOU_error_gamma_not_lower_triangular"
  )

  # Symmetric (non-diagonal): rejected
  expect_error(
    affectOU(ndim = 2, gamma = matrix(c(1, 0.3, 0.3, 1), nrow = 2)),
    class = "affectOU_error_gamma_not_lower_triangular"
  )

  # Full matrix: rejected
  expect_error(
    affectOU(ndim = 2, gamma = matrix(c(1, 0.2, 0.5, 1), nrow = 2)),
    class = "affectOU_error_gamma_not_lower_triangular"
  )

  # Lower triangular: accepted
  expect_no_error(
    affectOU(ndim = 2, gamma = matrix(c(1, 0.3, 0, 1), nrow = 2))
  )

  # Diagonal: accepted (trivially lower triangular)
  expect_no_error(
    affectOU(ndim = 2, gamma = diag(c(0.5, 1.2)))
  )

  # Scalar shorthand: accepted (expanded to diagonal)
  expect_no_error(
    affectOU(ndim = 2, gamma = 1)
  )

  # Vector shorthand: accepted (expanded to diagonal)
  expect_no_error(
    affectOU(ndim = 2, gamma = c(0.5, 1.2))
  )

  # 1D scalar: always valid
  expect_no_error(
    affectOU(ndim = 1, gamma = 2)
  )
})

test_that("specifying both gamma and sigma is an error", {
  expect_error(
    affectOU(gamma = 1, sigma = 1),
    class = "affectOU_error_gamma_sigma_both"
  )

  expect_error(
    affectOU(ndim = 2, gamma = diag(2), sigma = diag(2)),
    class = "affectOU_error_gamma_sigma_both"
  )
})

test_that("sigma to gamma round-trip produces same sigma", {
  # 1D
  sigma_1d <- matrix(4)
  m1 <- affectOU(sigma = sigma_1d)
  expect_equal(m1$parameters$sigma, sigma_1d)
  expect_equal(
    m1$parameters$gamma %*% t(m1$parameters$gamma),
    sigma_1d
  )

  # 2D with off-diagonal correlation
  sigma_2d <- matrix(c(2, 0.5, 0.5, 3), nrow = 2)
  m2 <- affectOU(ndim = 2, sigma = sigma_2d)
  expect_equal(m2$parameters$sigma, sigma_2d, tolerance = 1e-10)
  expect_equal(
    m2$parameters$gamma %*% t(m2$parameters$gamma),
    sigma_2d,
    tolerance = 1e-10
  )

  # Recovered gamma should be lower triangular
  expect_true(all(abs(m2$parameters$gamma[upper.tri(m2$parameters$gamma)]) < 1e-10))
})

test_that("singular positive semi-definite sigma is accepted", {
  sigma <- matrix(c(1, 1, 1, 1), nrow = 2)
  model <- affectOU(ndim = 2, sigma = sigma)

  expect_equal(model$parameters$sigma, sigma)
  expect_true(is_lower_triangular(model$parameters$gamma))
  expect_equal(
    model$parameters$gamma %*% t(model$parameters$gamma),
    sigma,
    tolerance = 1e-10
  )
  expect_working_model(model)
})

test_that("sigma must be symmetric", {
  sigma <- matrix(c(1, 0.5, 0, 1), nrow = 2)

  expect_error(
    affectOU(ndim = 2, sigma = sigma),
    class = "affectOU_error_sigma_not_symmetric"
  )
})
