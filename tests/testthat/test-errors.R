# Wording of user-facing conditions.
#
# The other test files assert *which* condition is raised, by class. This file
# is the only place that pins down the exact text, so a reworded message shows
# up as one reviewable snapshot diff rather than as scattered regexp failures.
#
# Internal assertions (`.internal = TRUE`) are deliberately not snapshotted:
# their bug-report footer wraps by console width.

cli::test_that_cli(config = "plain", "affectOU() error messages", {
  expect_snapshot(error = TRUE, {
    affectOU(gamma = 1, sigma = 1)
    affectOU(ndim = 0)
    affectOU(theta = "a")
    affectOU(ndim = 2, sigma = list())
    affectOU(ndim = 2, theta = matrix(1, 3, 3))
    affectOU(ndim = 2, mu = c(1, 2, 3))
    affectOU(theta = matrix(c(1, NA, 0, 1), 2))
    affectOU(theta = diag(2), sigma = diag(3))
    affectOU(sigma = -1)
    affectOU(sigma = matrix(c(1, 2, 3, 4), 2))
    affectOU(sigma = matrix(c(1, 1.5, 1.5, 1), 2))
    affectOU(gamma = matrix(c(1, 0, 2, 1), 2))
  })
})

cli::test_that_cli(config = "plain", "update() and plot() error messages", {
  model <- affectOU()

  expect_snapshot(error = TRUE, {
    update(model, gamma = 1, sigma = 1)
    update(model, mu = "a")
    plot(model)
  })
})

cli::test_that_cli(config = "plain", "simulate() error messages", {
  model <- affectOU()
  model_3d <- affectOU(ndim = 3)

  expect_snapshot(error = TRUE, {
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
  })
})

cli::test_that_cli(config = "plain", "simulation method error messages", {
  sim <- simulate(affectOU(), stop = 20, save_at = 0.5, seed = 1)

  expect_snapshot(error = TRUE, {
    summary(sim, discard_initial_time = 100)
    summary(sim, discard_initial_time = -1)
    head(sim, n = 0)
    tail(sim, n = -1)

    # Renamed in 1.0.3: the old name must not be silently ignored
    summary(sim, burnin = 10)
  })
})

cli::test_that_cli(config = "plain", "fit() error messages", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  model_3d <- affectOU(ndim = 3)

  expect_snapshot(error = TRUE, {
    fit(model_3d, data = rnorm(10), times = seq_len(10))
    fit(model, data = 1)
    fit(model, data = list())
    fit(model, data = c(1, NA, 3))
    fit(model, data = 1:10, times = letters[1:9])
    fit(model, data = 1:5, times = c(1, 2, NA, 4, 5))
    fit(model, data = 1:100, times = 1:99)
    fit(model, data = 1:5, times = c(1, 2, 2, 4, 5))
    fit(model, data = 1:5, times = 1:5, method = "ols")
    fit(model, data = 1:5, times = 1:5, start = c(a = 1, b = 2, c = 3))
    fit(model, data = 1:5, times = 1:5, start = c(theta = 1, mu = NA, gamma = 1))
  })
})

cli::test_that_cli(config = "plain", "fitted model error messages", {
  model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
  sim <- simulate(model, stop = 100, save_at = 0.5, seed = 1)
  d <- as.data.frame(sim)
  fitted <- fit(model, data = d$value, times = d$time)

  expect_snapshot(error = TRUE, {
    confint(fitted, parm = "alpha")
    confint(fitted, level = 1.5)
    summary(fitted, level = 0)
  })
})

cli::test_that_cli(config = "plain", "plot() error messages", {
  withr::local_pdf(NULL)

  sim <- simulate(affectOU(ndim = 3), nsim = 10, stop = 20, save_at = 0.5, seed = 1)

  expect_snapshot(error = TRUE, {
    plot(sim, which_dim = 5)
    plot(sim, which_dim = "a")
    plot(sim, which_sim = 25)
    plot(sim, type = "acf", which_sim = 1:3)
    plot(sim, ylim = list(c(0, 1), c(0, 1)))
    plot(sim, sub = c("a", "b"))
    plot(sim, type = "histogram", freq = "yes")
    plot(sim, type = "acf", lag.max = -1)
  })
})

cli::test_that_cli(config = "plain", "warning messages", {
  expect_snapshot({
    # Non-stationary system: no stationary distribution to draw from
    invisible(simulate(affectOU(theta = -0.5), stop = 1, save_at = 0.5, seed = 1))

    # No observation times supplied
    invisible(fit(affectOU(theta = 0.5, mu = 0, gamma = 1), data = rnorm(50)))
  })
})
