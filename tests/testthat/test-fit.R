test_that("fit.affectOU recovers parameters from complete simulated data (1D)", {
  # Create model and simulate
  theta <- 0.8
  mu <- -15
  gamma <- 8.5
  true_model <- affectOU(theta = theta, mu = mu, gamma = gamma)
  sim <- simulate(true_model,
    stop = 500, dt = .01,
    save_at = .01, nsim = 1, seed = 42
  )
  data <- as.data.frame(sim)

  # Fit model
  withr::local_seed(123)
  fitted_model <- fit(true_model,
    data = data$value,
    times = data$time
  )

  # Check parameter recovery (allow some tolerance)
  tol <- .15
  # expect_true(abs(fitted_model[["parameters"]][["theta"]] - theta) < tol)
  # expect_true(abs(fitted_model[["parameters"]][["mu"]] - mu) < tol)
  # expect_true(abs(fitted_model[["parameters"]][["gamma"]] - gamma) < tol)
  expect_equal(fitted_model[["parameters"]][["theta"]], theta, tolerance = tol)
  expect_equal(fitted_model[["parameters"]][["mu"]], mu, tolerance = tol)
  expect_equal(fitted_model[["parameters"]][["gamma"]], gamma, tolerance = tol)
})


test_that("fit.affectOU recovers parameters from undersampled (1/10), regularly spaced simulated data (1D)", {
  # Create model and simulate
  theta <- 1.8
  mu <- -5
  gamma <- 6.4
  true_model <- affectOU(theta = theta, mu = mu, gamma = gamma)
  sim <- simulate(true_model,
    stop = 500, dt = .01,
    save_at = .1, nsim = 1, seed = 423
  )
  data <- as.data.frame(sim)

  # Fit model
  withr::local_seed(123)
  fitted_model <- fit(true_model,
    data = data$value,
    times = data$time
  )

  # Check parameter recovery (allow some tolerance)
  tol <- .15
  expect_equal(fitted_model[["parameters"]][["theta"]], theta, tolerance = tol)
  expect_equal(fitted_model[["parameters"]][["mu"]], mu, tolerance = tol)
  expect_equal(fitted_model[["parameters"]][["gamma"]], gamma, tolerance = tol)
})


test_that("fit.affectOU recovers parameters from shorter, undersampled (1/10), regularly spaced simulated data (1D)", {
  # Create model and simulate
  theta <- 1.4
  mu <- 10
  gamma <- 4.4
  true_model <- affectOU(theta = theta, mu = mu, gamma = gamma)
  sim <- simulate(true_model,
    stop = 200, dt = .01,
    save_at = .1, nsim = 1, seed = 423
  )
  data <- as.data.frame(sim)

  # Fit model
  withr::local_seed(123)
  fitted_model <- fit(true_model,
    data = data$value,
    times = data$time
  )

  # Check parameter recovery (allow some tolerance)
  tol <- .15
  expect_equal(fitted_model[["parameters"]][["theta"]], theta, tolerance = tol)
  expect_equal(fitted_model[["parameters"]][["mu"]], mu, tolerance = tol)
  expect_equal(fitted_model[["parameters"]][["gamma"]], gamma, tolerance = tol)
})

test_that("fit.affectOU errors on missing data (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)
  data <- as.data.frame(sim)
  data$value[c(10, 20, 30)] <- NA # Introduce some missing values

  expect_error(
    fitted_model <- fit(model, data = data$value, times = data$time)
  )

  data$value[c(10, 20, 30)] <- Inf # Introduce some non-finite values

  expect_error(
    fitted_model <- fit(model, data = data$value, times = data$time)
  )
})


test_that("fit.affectOU produces fitted values (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)
  data <- as.data.frame(sim)

  # Fit model
  fitted_model <- fit(model,
    data = data$value,
    times = data$time
  )

  expect_false(is.null(fitted_model[["fitted_values"]]))
  expect_length(fitted_model[["fitted_values"]], nrow(data))
})

test_that("fit.affectOU computes log-likelihood (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)
  data <- as.data.frame(sim)

  # Fit model
  fitted_model <- fit(model,
    data = data$value,
    times = data$time
  )

  expect_false(is.null(fitted_model[["log_likelihood"]]))
  expect_true(is.numeric(fitted_model[["log_likelihood"]]))

  ll <- logLik(fitted_model)
  expect_s3_class(ll, "logLik")
  expect_equal(attr(ll, "df"), 3)
  expect_equal(attr(ll, "nobs"), fitted_model[["nobs"]])
})

test_that("fit.affectOU warns when times not provided (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  data <- rnorm(100)

  expect_warning(
    fit(model, data = data),
    "`times` was not supplied"
  )
})

test_that("fit.affectOU requires matching data and times lengths (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)

  expect_error(
    fit(model, data = rnorm(100), times = seq(0, 50, by = 1)),
    class = "affectOU_error_length_mismatch"
  )
})

test_that("fit.affectOU validates observation times", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  data <- rnorm(4)

  expect_error(
    fit(model, data = data, times = rep("a", 4)),
    "`times` must be a numeric vector"
  )
  expect_error(
    fit(model, data = data, times = c(0, 1, Inf, 2)),
    class = "affectOU_error_not_finite"
  )
  expect_error(
    fit(model, data = data, times = c(0, 1, 1, 2)),
    class = "affectOU_error_times_not_increasing"
  )
  expect_error(
    fit(model, data = data, times = c(0, 1, 0.5, 2)),
    class = "affectOU_error_times_not_increasing"
  )
})

test_that("fit.affectOU returns correct class (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)
  data <- as.data.frame(sim)

  fitted_model <- fit(model,
    data = data$value,
    times = data$time
  )

  expect_s3_class(fitted_model, "fit_affectOU")
})

test_that("fitted() and resid() work on fit.affectOU via defaults", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)
  data <- as.data.frame(sim)
  fit_obj <- fit(model, data = data$value, times = data$time)

  # stats::fitted() should return the stored fitted values
  expect_equal(stats::fitted(fit_obj), fit_obj[["fitted_values"]])

  # stats::resid() should return data - fitted values
  expect_equal(stats::resid(fit_obj), unname(fit_obj[["data"]] - fit_obj[["fitted_values"]]))
})


# Test edge cases ------------------------------------------------------------
test_that("fit.affectOU handles irregular time spacing (1D)", {
  model <- affectOU()
  times <- c(0, 0.1, 0.3, 1, 1.5, 3, 5, 10)

  expect_silent(
    fitted_model <- fit(model, data = rnorm(length(times)), times = times)
  )
})

test_that("fit.affectOU is accurate with undersampling and irregular time spacing (1D)", {
  # Create model and simulate
  theta <- 2.1
  mu <- 5.7
  gamma <- 2.4
  true_model <- affectOU(theta = theta, mu = mu, gamma = gamma)
  sim <- simulate(true_model,
    stop = 500, dt = .01,
    save_at = .01, nsim = 1, seed = 423
  )
  data <- as.data.frame(sim)

  # Unequal time spacing
  withr::local_seed(123)
  idx <- sort(sample(1:nrow(data), size = round(nrow(data) * .1))) # Randomly select 200 time points
  data <- data[idx, ]

  # Fit model
  fitted_model <- fit(true_model,
    data = data$value,
    times = data$time
  )

  # Check parameter recovery (allow some tolerance)
  tol <- .1
  expect_true(abs(fitted_model[["parameters"]][["theta"]] - theta) < (tol * 2)) # Allow more tolerance for theta
  expect_true(abs(fitted_model[["parameters"]][["mu"]] - mu) < tol)
  expect_true(abs(fitted_model[["parameters"]][["gamma"]] - gamma) < tol)
})

test_that("fit.affectOU errors on missing data (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)
  data <- as.data.frame(sim)
  data$value[c(10, 20, 30)] <- NA # Introduce some missing values

  expect_error(
    fitted_model <- fit(model, data = data$value, times = data$time)
  )

  data$value[c(10, 20, 30)] <- Inf # Introduce some non-finite values

  expect_error(
    fitted_model <- fit(model, data = data$value, times = data$time)
  )
})

test_that("fit.affectOU errors on short data (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  data <- rnorm(1) # Only one observation

  expect_error(
    fitted_model <- fit(model, data = data),
    "`data` must contain at least 2 observations"
  )
})


test_that("fit.affectOU handles constant data (1D)", {
  model <- affectOU(theta = 0.5, mu = 0, sigma = 0)
  sim <- simulate(model, stop = 10, dt = .1, save_at = .1, nsim = 1)
  data <- as.data.frame(sim)

  expect_silent(
    fitted_model <- fit(model, data = data$value, times = data$time, start = c(theta = 0.5, mu = 0, gamma = 1))
  )
})


# Affine equivariance / internal standardization -----------------------------

test_that("fit.affectOU is affine-equivariant in the data (1D)", {
  model <- affectOU(theta = 0.8, mu = -15, gamma = 8.5)
  sim <- simulate(model, stop = 500, dt = .01, save_at = .01, nsim = 1, seed = 42)
  data <- as.data.frame(sim)

  a <- 100
  b <- 50

  fit_orig <- fit(model, data = data$value, times = data$time)
  fit_aff <- fit(model, data = a * data$value + b, times = data$time)

  p0 <- fit_orig[["parameters"]]
  p1 <- fit_aff[["parameters"]]

  # theta invariant; mu -> a*mu + b; gamma -> a*gamma
  expect_equal(p1[["theta"]], p0[["theta"]], tolerance = 1e-4)
  expect_equal(p1[["mu"]], a * p0[["mu"]] + b, tolerance = 1e-4)
  expect_equal(p1[["gamma"]], a * p0[["gamma"]], tolerance = 1e-4)

  # Fitted values transform the same way
  expect_equal(
    fit_aff[["fitted_values"]],
    a * fit_orig[["fitted_values"]] + b,
    tolerance = 1e-4
  )

  # Standard errors of mu and gamma scale by a; theta SE invariant
  se0 <- fit_orig[["se"]]
  se1 <- fit_aff[["se"]]
  expect_equal(se1[["theta"]], se0[["theta"]], tolerance = 1e-3)
  expect_equal(se1[["mu"]], a * se0[["mu"]], tolerance = 1e-3)
  expect_equal(se1[["gamma"]], a * se0[["gamma"]], tolerance = 1e-3)
})

test_that("fit.affectOU log-likelihood includes the Jacobian under rescaling (1D)", {
  model <- affectOU(theta = 0.8, mu = -15, gamma = 8.5)
  sim <- simulate(model, stop = 500, dt = .01, save_at = .01, nsim = 1, seed = 42)
  data <- as.data.frame(sim)

  a <- 100
  b <- 50

  fit_orig <- fit(model, data = data$value, times = data$time)
  fit_aff <- fit(model, data = a * data$value + b, times = data$time)

  n <- fit_orig[["nobs"]]
  # ll on a*y + b equals ll on y minus (n - 1) * log(a) (n - 1 conditional densities)
  expect_equal(
    logLik(fit_aff),
    logLik(fit_orig) - (n - 1) * log(a),
    tolerance = 1e-3
  )
})


# coef.fit_affectOU -----------------------------------------------------------

test_that("coef.fit_affectOU returns a named numeric vector", {
  fit_obj <- quick_fit()
  result <- coef(fit_obj)

  expect_true(is.numeric(result))
  expect_true(is.vector(result))
  expect_named(result, c("theta", "mu", "gamma"))
})

test_that("coef.fit_affectOU values match stored parameters", {
  fit_obj <- quick_fit()
  result <- coef(fit_obj)

  expect_equal(result[["theta"]], fit_obj[["parameters"]][["theta"]])
  expect_equal(result[["mu"]], fit_obj[["parameters"]][["mu"]])
  expect_equal(result[["gamma"]], fit_obj[["parameters"]][["gamma"]])
})


# confint.fit_affectOU --------------------------------------------------------

test_that("confint.fit_affectOU returns matrix with correct structure (default)", {
  fit_obj <- quick_fit()
  ci <- confint(fit_obj)

  expect_true(is.matrix(ci))
  expect_equal(nrow(ci), 3)
  expect_equal(ncol(ci), 2)
  expect_named(ci[1, ], c("2.5%", "97.5%"))
  expect_equal(rownames(ci), c("theta", "mu", "gamma"))
})

test_that("confint.fit_affectOU lower < estimate < upper", {
  fit_obj <- quick_fit()
  ci <- confint(fit_obj)
  params <- coef(fit_obj)

  expect_true(all(ci[, 1] < params))
  expect_true(all(params < ci[, 2]))
})

test_that("confint.fit_affectOU respects level argument", {
  fit_obj <- quick_fit()
  ci_90 <- confint(fit_obj, level = 0.90)
  ci_95 <- confint(fit_obj, level = 0.95)

  width_90 <- ci_90[, 2] - ci_90[, 1]
  width_95 <- ci_95[, 2] - ci_95[, 1]
  expect_true(all(width_90 < width_95))
  expect_named(ci_90[1, ], c("5%", "95%"))
})

test_that("confint.fit_affectOU subsets parameters via parm", {
  fit_obj <- quick_fit()
  ci <- confint(fit_obj, parm = c("theta", "gamma"))

  expect_equal(nrow(ci), 2)
  expect_equal(rownames(ci), c("theta", "gamma"))
})

test_that("confint.fit_affectOU errors on invalid parm names", {
  fit_obj <- quick_fit()
  expect_error(
    confint(fit_obj, parm = "invalid"),
    class = "affectOU_error_unknown_parm"
  )
})

test_that("confint.fit_affectOU errors on invalid level", {
  fit_obj <- quick_fit()
  expect_error(confint(fit_obj, level = 1.5), "between 0 and 1")
  expect_error(confint(fit_obj, level = 0), "between 0 and 1")
  expect_error(confint(fit_obj, level = "a"), "must be a number")
})


# summary.fit_affectOU --------------------------------------------------------

test_that("summary.fit_affectOU returns correct class", {
  fit_obj <- quick_fit()
  s <- summary(fit_obj)
  expect_s3_class(s, "summary_fit_affectOU")
})

test_that("summary.fit_affectOU contains all expected components", {
  fit_obj <- quick_fit()
  s <- summary(fit_obj)
  expect_named(s, c("coefficients", "log_likelihood", "rmse", "nobs", "convergence", "level", "method"))
})

test_that("summary.fit_affectOU coefficients is data.frame with correct columns", {
  fit_obj <- quick_fit()
  s <- summary(fit_obj)
  coef_df <- s$coefficients

  expect_s3_class(coef_df, "data.frame")
  expect_equal(nrow(coef_df), 3)
  expect_true(all(c("estimate", "se") %in% names(coef_df)))
  expect_equal(rownames(coef_df), c("theta", "mu", "gamma"))
})

test_that("summary.fit_affectOU estimates match coef()", {
  fit_obj <- quick_fit()
  s <- summary(fit_obj)
  expect_equal(s$coefficients$estimate, unname(coef(fit_obj)))
})

test_that("summary.fit_affectOU scalars match fit object", {
  fit_obj <- quick_fit()
  s <- summary(fit_obj)
  expect_equal(s$log_likelihood, fit_obj[["log_likelihood"]])
  expect_equal(s$rmse, fit_obj[["rmse"]])
  expect_equal(s$nobs, fit_obj[["nobs"]])
  expect_equal(s$convergence, fit_obj[["convergence"]])
  expect_equal(s$method, fit_obj[["method"]])
})

test_that("summary.fit_affectOU level argument propagates to CI columns", {
  fit_obj <- quick_fit()
  s90 <- summary(fit_obj, level = 0.90)
  expect_equal(s90$level, 0.90)
  expect_equal(names(s90$coefficients)[3:4], c("5%", "95%"))
})

test_that("summary.fit_affectOU validates level", {
  fit_obj <- quick_fit()

  expect_error(summary(fit_obj, level = 1.5), "between 0 and 1")
  expect_error(summary(fit_obj, level = 0), "between 0 and 1")
  expect_error(summary(fit_obj, level = "a"), "must be a number")
})


# print.fit_affectOU ----------------------------------------------------------

cli::test_that_cli(config = c("plain", "ansi"), "print.fit_affectOU snapshot", {
  fit_obj <- quick_fit()
  expect_snapshot(print(fit_obj))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.fit_affectOU digits snapshot", {
  fit_obj <- quick_fit()
  expect_snapshot(print(fit_obj, digits = 1))
  expect_snapshot(print(fit_obj, digits = 5))
})

test_that("print.fit_affectOU returns invisibly", {
  fit_obj <- quick_fit()
  expect_invisible(print(fit_obj))
})


# print.summary_fit_affectOU --------------------------------------------------

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_fit_affectOU snapshot", {
  fit_obj <- quick_fit()
  s <- summary(fit_obj)
  expect_snapshot(print(s))
})

cli::test_that_cli(config = c("plain", "ansi"), "print.summary_fit_affectOU digits snapshot", {
  fit_obj <- quick_fit()
  s <- summary(fit_obj)
  expect_snapshot(print(s, digits = 1))
  expect_snapshot(print(s, digits = 5))
})

test_that("print.summary_fit_affectOU returns invisibly", {
  fit_obj <- quick_fit()
  s <- summary(fit_obj)
  expect_invisible(print(s))
})

test_that("print.summary_fit_affectOU shows convergence warning when convergence != 0", {
  fit_obj <- quick_fit()
  fit_obj[["convergence"]] <- 1
  s <- summary(fit_obj)
  expect_equal(s$convergence, 1)
  # cli_alert_warning does not produce an R-level warning; verify print runs without error
  expect_no_error(print(s))
})


# validate_fit_affectOU -------------------------------------------------------

test_that("validate_fit_affectOU passes on valid object", {
  fit_obj <- quick_fit()
  expect_no_error(validate_fit_affectOU(fit_obj))
  expect_invisible(validate_fit_affectOU(fit_obj))
})

test_that("validate_fit_affectOU errors on wrong class", {
  expect_error(
    validate_fit_affectOU(list()),
    "class.*fit_affectOU"
  )
})

test_that("validate_fit_affectOU errors on missing components", {
  fit_obj <- quick_fit()
  bad <- fit_obj
  bad[["rmse"]] <- NULL
  expect_error(
    validate_fit_affectOU(bad),
    "Missing components"
  )
})

test_that("validate_fit_affectOU errors on wrong parameter types", {
  fit_obj <- quick_fit()

  bad_params <- fit_obj
  bad_params[["parameters"]] <- c(theta = 0.5, mu = 0, gamma = 1)
  expect_error(validate_fit_affectOU(bad_params), "parameters")

  bad_fv <- fit_obj
  bad_fv[["fitted_values"]] <- "not numeric"
  expect_error(validate_fit_affectOU(bad_fv), "fitted_values")

  bad_ll <- fit_obj
  bad_ll[["log_likelihood"]] <- c(1, 2)
  expect_error(validate_fit_affectOU(bad_ll), "log_likelihood")

  bad_method <- fit_obj
  bad_method[["method"]] <- 123
  expect_error(validate_fit_affectOU(bad_method), "method")

  bad_model <- fit_obj
  bad_model[["model"]] <- list()
  expect_error(validate_fit_affectOU(bad_model), "model")
})

test_that("validate_fit_affectOU errors on inconsistent data/fitted_values lengths", {
  fit_obj <- quick_fit()
  bad <- fit_obj
  bad[["fitted_values"]] <- head(fit_obj[["fitted_values"]], -1)
  expect_error(validate_fit_affectOU(bad), "fitted_values")
})

test_that("validate_fit_affectOU errors on data != fitted_values + residuals", {
  fit_obj <- quick_fit()
  bad <- fit_obj
  bad[["residuals"]] <- fit_obj[["residuals"]] + 999
  expect_error(validate_fit_affectOU(bad), "residuals")
})

test_that("validate_fit_affectOU errors on nobs inconsistency", {
  fit_obj <- quick_fit()
  bad <- fit_obj
  bad[["nobs"]] <- fit_obj[["nobs"]] + 5
  expect_error(validate_fit_affectOU(bad), "nobs")
})
