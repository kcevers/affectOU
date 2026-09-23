test_that("get_plot_params returns default parameters", {
  result <- get_plot_params()

  expect_type(result, "list")
  expect_true("xlim" %in% names(result))
  expect_true("ylim" %in% names(result))
  expect_true("oma" %in% names(result))
  expect_true("mar" %in% names(result))
  expect_true("cex.main" %in% names(result))
})

test_that("get_plot_params merges specific defaults", {
  result <- get_plot_params(specific = list(main = "Test Title", xlab = "X"))

  expect_equal(result$main, "Test Title")
  expect_equal(result$xlab, "X")
  # Base defaults should still be present
  expect_true("cex.main" %in% names(result))
})

test_that("get_plot_params user args override defaults", {
  result <- get_plot_params(
    specific = list(main = "Specific"),
    user = list(main = "User", custom_arg = 123)
  )

  expect_equal(result$main, "User") # User overrides specific
  expect_equal(result$custom_arg, 123) # Custom args are preserved
})

test_that("get_plot_params priority is base < specific < user", {
  result <- get_plot_params(
    specific = list(cex.main = 2.0),
    user = list(cex.main = 3.0)
  )

  expect_equal(result$cex.main, 3.0) # User wins
})


# ==============================================================================
# Test: filter_args
# ==============================================================================

test_that("filter_args keeps only valid arguments", {
  args <- list(a = 1, b = 2, c = 3, d = 4)
  valid <- c("a", "c")

  result <- filter_args(args, valid)

  expect_equal(names(result), c("a", "c"))
  expect_equal(result$a, 1)
  expect_equal(result$c, 3)
})

test_that("filter_args returns empty list when no matches", {
  args <- list(x = 1, y = 2)
  valid <- c("a", "b")

  result <- filter_args(args, valid)

  expect_length(result, 0)
})


# ==============================================================================
# Test: get_valid_args
# ==============================================================================

test_that("get_valid_args extracts function arguments", {
  test_fun <- function(a, b, c = 1) NULL
  result <- get_valid_args(test_fun, include_par = FALSE)

  expect_true("a" %in% result)
  expect_true("b" %in% result)
  expect_true("c" %in% result)
  expect_false("..." %in% result)
})

test_that("get_valid_args handles ... by including par args", {
  test_fun <- function(x, ...) NULL
  result <- get_valid_args(test_fun, include_par = TRUE)

  expect_true("x" %in% result)
  # Should include par arguments like col, lwd, etc.
  expect_true("col" %in% result)
  expect_true("lwd" %in% result)
})


# ==============================================================================
# Test: get_layout
# ==============================================================================

test_that("get_layout computes square-ish layout for n panels", {
  # 4 panels -> 2x2
  result <- get_layout(4, list())
  expect_equal(result$nrow * result$ncol, 4)

  # 6 panels -> 2x3 or 3x2
  result <- get_layout(6, list())
  expect_true(result$nrow * result$ncol >= 6)

  # 1 panel -> 1x1
  result <- get_layout(1, list())
  expect_equal(result$nrow, 1)
  expect_equal(result$ncol, 1)
})

test_that("get_layout respects user-specified nrow", {
  P <- list(nrow = 2)
  result <- get_layout(6, P)

  expect_equal(result$nrow, 2)
  expect_equal(result$ncol, 3) # ceil(6/2)
})

test_that("get_layout respects user-specified ncol", {
  P <- list(ncol = 2)
  result <- get_layout(6, P)

  expect_equal(result$ncol, 2)
  expect_equal(result$nrow, 3) # ceil(6/2)
})

test_that("get_layout respects mfrow in user_args", {
  result <- get_layout(4, list(), user_args = list(mfrow = c(1, 4)))

  expect_equal(result$nrow, 1)
  expect_equal(result$ncol, 4)
})

test_that("get_layout errors when layout is too small", {
  expect_error(
    get_layout(10, list(nrow = 2, ncol = 2)),
    class = "affectOU_error_layout_too_small"
  )
})


# ==============================================================================
# Test: get_lims
# ==============================================================================

test_that("get_lims returns user-specified limits as list", {
  # User provides a list of limits
  lim <- list(c(0, 10), c(-5, 5))
  result <- get_lims(NULL, ndim = 2, nsim = 1, lim = lim)

  expect_equal(result, lim)
})

test_that("get_lims replicates single limit vector", {
  lim <- c(0, 100)
  result <- get_lims(NULL, ndim = 3, nsim = 1, lim = lim)

  expect_length(result, 3)
  expect_equal(result[[1]], c(0, 100))
  expect_equal(result[[2]], c(0, 100))
  expect_equal(result[[3]], c(0, 100))
})

test_that("get_lims computes shared axis from data", {
  data <- array(1:24, dim = c(4, 2, 3)) # 4 times, 2 dims, 3 sims
  data[, 1, ] <- data[, 1, ] * 10 # Dim 1: 10-240
  data[, 2, ] <- data[, 2, ] - 50 # Dim 2: -49 to -26

  result <- get_lims(data, ndim = 2, nsim = 3, lim = NULL, share_axis = TRUE)

  # Should be global range across all data
  global_range <- range(data)
  expect_equal(result[[1]], global_range)
  expect_equal(result[[2]], global_range)
})

test_that("get_lims computes per-dimension limits", {
  data <- array(0, dim = c(10, 2, 1))
  data[, 1, ] <- 1:10
  data[, 2, ] <- 101:110

  result <- get_lims(data, ndim = 2, nsim = 1, lim = NULL, share_axis = FALSE)

  expect_equal(result[[1]], c(1, 10))
  expect_equal(result[[2]], c(101, 110))
})

test_that("get_lims handles list data (for ACF/CCF)", {
  data <- list(c(0, 0.5, 1), c(-1, 0, 1), c(0.2, 0.8))

  result <- get_lims(data, ndim = 3, nsim = 1, lim = NULL, share_axis = TRUE)

  expect_equal(result[[1]], c(-1, 1)) # Global range
})

test_that("get_lims errors on mismatched list length", {
  lim <- list(c(0, 1), c(0, 2)) # 2 elements

  expect_error(
    get_lims(NULL, ndim = 3, nsim = 1, lim = lim),
    class = "affectOU_error_lim_length"
  )
})


# ==============================================================================
# Test: generate_shades
# ==============================================================================

test_that("generate_shades returns correct number of colors", {
  result <- generate_shades("blue", 5)

  expect_length(result, 5)
  expect_type(result, "character")
})

test_that("generate_shades produces valid color strings", {
  result <- generate_shades("red", 3)

  # Each should be a valid color (can be parsed by col2rgb)
  for (col in result) {
    expect_no_error(grDevices::col2rgb(col))
  }
})

test_that("generate_shades varies alpha from light to dark", {
  result <- generate_shades("#FF0000", 3)

  # Extract alpha values - last colors should be more opaque
  rgb1 <- grDevices::col2rgb(result[1], alpha = TRUE)
  rgb3 <- grDevices::col2rgb(result[3], alpha = TRUE)

  expect_true(rgb1["alpha", ] < rgb3["alpha", ])
})


# ==============================================================================
# Test: prep_sim
# ==============================================================================

test_that("prep_sim subsets dimensions correctly", {
  model <- affectOU(ndim = 3)
  sim <- simulate(model, dt = 0.1, nsim = 3)
  result <- prep_sim(sim, which_dim = c(1, 3), which_sim = 1:2)

  expect_equal(dim(result$data)[2], 2) # 2 dimensions selected
  expect_equal(result$model$ndim, 2)
  expect_equal(dim(result$data)[3], 2) # 2 simulations selected
  expect_equal(result$nsim, 2)
  expect_equal(length(result$model$parameters$mu), 2)
  expect_equal(dim(result$model$parameters$theta), c(2, 2))
})

test_that("prep_sim ensures 3D output array", {
  model <- affectOU(ndim = 3)
  sim <- simulate(model, dt = 0.1, nsim = 3)
  result <- prep_sim(sim, which_dim = 1:2, which_sim = 1)

  expect_equal(length(dim(result$data)), 3) # Should be 3D
  expect_equal(dim(result$data)[2], 2) # 2 dimensions selected
  expect_equal(result$model$ndim, 2)
  expect_equal(dim(result$data)[3], 1) # 1 simulation selected
  expect_equal(result$nsim, 1)
})

test_that("prep_sim handles 1D case", {
  model <- affectOU(ndim = 1)
  sim <- simulate(model, dt = 0.1, nsim = 1)
  result <- prep_sim(sim, which_dim = 1, which_sim = 1)

  expect_equal(length(dim(result$data)), 3) # Should be 3D
  expect_equal(dim(result$data)[2], 1) # 1 dimension
  expect_equal(result$model$ndim, 1)
  expect_equal(dim(result$data)[3], 1) # 1 simulation
  expect_equal(result$nsim, 1)
})

test_that("prep_sim errors on invalid dimension indices", {
  model <- affectOU(ndim = 1)
  sim <- simulate(model, dt = 0.1, nsim = 1)

  expect_error(
    prep_sim(sim, which_dim = c(1, 5), which_sim = 1),
    class = "affectOU_error_which_dim_out_of_range"
  )
})

test_that("prep_sim errors on invalid simulation indices", {
  model <- affectOU(ndim = 1)
  sim <- simulate(model, dt = 0.1, nsim = 1)

  expect_error(
    prep_sim(sim, which_dim = 1, which_sim = c(1, 2)),
    class = "affectOU_error_which_sim_out_of_range"
  )
})

test_that("prep_sim respects max_ndim constraint", {
  model <- affectOU(ndim = 3)
  sim <- simulate(model, dt = 0.1, nsim = 1)

  expect_error(
    prep_sim(sim, which_dim = 1:3, which_sim = 1, max_ndim = 2),
    class = "affectOU_error_too_many_dims"
  )
})

test_that("prep_sim respects max_nsim constraint", {
  model <- affectOU(ndim = 1)
  sim <- simulate(model, dt = 0.1, nsim = 3)

  expect_error(
    prep_sim(sim, which_dim = 1, which_sim = 1:3, max_nsim = 2),
    class = "affectOU_error_too_many_sims"
  )
})

test_that("prep_sim preserves theta, sigma, and mu subsetting", {
  ndim <- 3
  mu <- c(0, 1, 2)
  theta <- matrix(c(
    0.5, 0.1, 0.2,
    0.1, 0.3, 0.15,
    0.2, 0.15, 0.4
  ), nrow = ndim, byrow = TRUE)
  sigma <- matrix(c(
    1, 0.2, 0.1,
    0.2, 1, 0.3,
    0.1, 0.3, 1
  ), nrow = ndim, byrow = TRUE)

  model <- affectOU(ndim = ndim, theta = theta, sigma = sigma, mu = mu)
  sim <- simulate(model, dt = 0.1, nsim = 1)

  result <- prep_sim(sim, which_dim = c(1, 3), which_sim = 1)

  # Should extract rows/cols 1 and 3
  idx <- c(1, 3)
  expected_theta <- theta[idx, idx]
  expected_sigma <- sigma[idx, idx]
  expected_mu <- mu[idx]
  expected_gamma <- model$parameters$gamma[idx, idx]

  expect_equal(result$model$parameters$theta, expected_theta)
  expect_equal(result$model$parameters$sigma, expected_sigma)
  expect_equal(result$model$parameters$mu, expected_mu)
  expect_equal(result$model$parameters$gamma, expected_gamma)
})

test_that("prep_sim sorts and deduplicates which_sim", {
  model <- affectOU(ndim = 1)
  sim <- simulate(model, dt = 0.1, nsim = 5, seed = 1)

  r_sorted <- prep_sim(sim, which_dim = 1, which_sim = c(1, 3, 5))
  r_dup <- prep_sim(sim, which_dim = 1, which_sim = c(5, 1, 3, 1))

  expect_equal(r_sorted[["data"]], r_dup[["data"]])
  expect_equal(r_sorted[["nsim"]], 3L)
  expect_equal(r_dup[["nsim"]], 3L)
})


# ==============================================================================
# Test: assign_sim_lty / sim_legend_entries
# ==============================================================================

test_that("sim_legend_entries labels use sim_ids", {
  lty_vec <- affectOU:::assign_sim_lty(3)
  col_sim <- generate_shades("blue", 3)

  # Default: sequential positions
  leg <- affectOU:::sim_legend_entries(3, lty_vec, col_sim)
  expect_equal(leg$text, c("Sim 1", "Sim 2", "Sim 3"))

  # With original indices preserved
  leg_ids <- affectOU:::sim_legend_entries(3, lty_vec, col_sim,
    sim_ids = c(1L, 5L, 11L)
  )
  expect_equal(leg_ids$text, c("Sim 1", "Sim 5", "Sim 11"))
})

test_that("sim_legend_entries shows range when grouped", {
  lty_vec <- affectOU:::assign_sim_lty(10)
  col_sim <- generate_shades("blue", 10)

  leg <- affectOU:::sim_legend_entries(10, lty_vec, col_sim)
  expect_true(grepl("\u2013", leg$text[1]))
  expect_equal(leg$text[1], "Sim 1\u20132")
})

test_that("sim_legend_entries returns NULL for nsim <= 1", {
  lty_vec <- affectOU:::assign_sim_lty(1)
  col_sim <- generate_shades("blue", 1)
  expect_null(affectOU:::sim_legend_entries(1, lty_vec, col_sim))
})


# ==============================================================================
# Test: apply_par
# ==============================================================================

test_that("apply_par sets graphical parameters", {
  # Suppress graphics output
  withr::local_pdf(NULL)

  P <- get_plot_params()

  # # Save current par
  # old_par <- par(no.readonly = TRUE)
  # on.exit(par(old_par), add = TRUE)

  expect_no_error(apply_par(P))

  # Check that some parameters were set
  expect_equal(par("las"), P$las)
  expect_equal(par("cex.axis"), P$cex.axis)
  expect_equal(par("mar"), P$mar)
  expect_equal(par("family"), P$family)
})


# ==============================================================================
# Test: add_panel_legend
# ==============================================================================

test_that("add_panel_legend hides legend when position is 'none'", {
  withr::local_pdf(NULL)
  plot.new()

  # Should not error and should draw nothing (returns NULL invisibly)
  expect_no_error(
    result <- add_panel_legend(
      position = "none",
      xlim = c(0, 1), ylim = c(0, 1),
      legend = "Test", col = "black", lty = 1
    )
  )
  expect_null(result)
})

test_that("ou_plot functions accept legend_position = 'none'", {
  withr::local_pdf(NULL)

  model <- affectOU(ndim = 2)
  sim <- simulate(model, dt = 0.1, nsim = 3, seed = 1)

  expect_no_error(ou_plot_time(sim, legend_position = "none"))
  expect_no_error(ou_plot_histogram(sim, legend_position = "none"))
  expect_no_error(ou_plot_acf(sim, legend_position = "none"))
  expect_no_error(ou_plot_phase(sim, legend_position = "none"))
})
