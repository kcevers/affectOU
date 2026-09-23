#' Plot fitted model diagnostics
#'
#' Provides various diagnostic plots for fitted [`fit_affectOU`][fit.affectOU()] objects, including:
#' - `"time"`: Observed vs fitted trajectory over time produced by [ou_plot_fit_time()].
#' - `"residuals"`: Residuals (data - fitted) over time produced by [ou_plot_fit_residuals()].
#' - `"acf"`: ACF of residuals produced by [ou_plot_fit_acf()].
#' - `"qq"`: Normal Q-Q plot of residuals produced by [ou_plot_fit_qq()].
#'
#' @param x An object of class [`fit_affectOU`][fit.affectOU()]
#' @param type Type of plot; one of `"time"`, `"residuals"`, `"acf"`, or `"qq"`
#' @param ... Additional graphical parameters passed to the specific plotting functions
#'
#' @return NULL (invisibly), called for side effects only.
#'
#' @export
#' @concept fit
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' plot(fitted, type = "time")
#' plot(fitted, type = "residuals")
#' plot(fitted, type = "acf")
#' plot(fitted, type = "qq")
plot.fit_affectOU <- function(x,
                              type = c(
                                "time", "residuals",
                                "acf", "qq"
                              ),
                              ...) {
  type <- match.arg(type)

  switch(type,
    time = ou_plot_fit_time(x, ...),
    residuals = ou_plot_fit_residuals(x, ...),
    acf = ou_plot_fit_acf(x, ...),
    qq = ou_plot_fit_qq(x, ...)
  )
}


#' Plot observed vs fitted trajectory
#'
#' Compare the observed data with the fitted trajectory over time. This plot
#' helps assess how well the model captures the overall pattern of the data.
#'
#' @param fit A `fit_affectOU` object
#' @inheritParams plot_parameters
#' @param ... Additional graphical parameters
#'
#' @return NULL (invisibly), called for side effects only.
#'
#' @export
#' @concept fit
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' ou_plot_fit_time(fitted)
ou_plot_fit_time <- function(fit,
                             palette = "Dark 3",
                             alpha = 0.5,
                             main = "Observed and Fitted Trajectory",
                             xlab = "Time",
                             ylab = "Affect",
                             legend_position = "topright",
                             ...) {
  # Parse arguments
  args <- c(as.list(environment()), list(...))
  args[["fit"]] <- NULL
  P <- get_plot_params(user = args)

  # Extract data
  data <- fit[["data"]]
  times <- fit[["times"]]
  fitted <- fit[["fitted_values"]]

  # Set up par and restore on exit
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par), add = TRUE)
  apply_par(P)

  # Axis limits
  xlim <- if (is.null(P[["xlim"]])) range(times) else P[["xlim"]]
  ylim <- if (is.null(P[["ylim"]])) range(c(data, fitted), na.rm = TRUE) else P[["ylim"]]

  # Colours
  cols <- grDevices::hcl.colors(2, palette = palette, alpha = alpha)

  # Set up panel (labels added as outer labels for consistency)
  setup_panel(xlim, ylim, P)

  # Plot observed data
  lines(times, data, col = cols[1], lwd = 2)

  # Plot fitted values
  lines(times, fitted,
    col = cols[2],
    lwd = 2
  )

  # Outer labels and legend overlay
  add_outer_labels(P, main = P[["main"]], xlab = P[["xlab"]], ylab = P[["ylab"]])
  add_panel_legend(
    position = P[["legend_position"]],
    xlim = xlim,
    ylim = ylim,
    panel_row = 1,
    panel_col = 1,
    legend = c("Observed", "Fitted"),
    col = cols,
    lty = 1,
    lwd = 2,
    bty = "o", bg = "white"
  )

  invisible(NULL)
}


#' Plot residuals over time
#'
#' Visualize the residuals (differences between observed and fitted values) over
#' time to assess model fit. Ideally, residuals should show no systematic
#' patterns and be randomly scattered around zero.
#'
#' @param fit A `fit_affectOU` object
#' @inheritParams plot_parameters
#' @param ... Additional graphical parameters
#'
#' @return NULL (invisibly), called for side effects only.
#'
#' @export
#' @concept fit
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' ou_plot_fit_residuals(fitted)
ou_plot_fit_residuals <- function(fit,
                                  palette = "Dark 3",
                                  main = "Residuals over Time",
                                  xlab = "Time",
                                  ylab = "Residual",
                                  alpha = 0.8,
                                  ...) {
  # Parse arguments
  args <- c(as.list(environment()), list(...))
  args[["fit"]] <- NULL
  P <- get_plot_params(user = args)

  # Extract data
  times <- fit[["times"]]
  residuals <- fit[["data"]] - fit[["fitted_values"]]

  # Set up par and restore on exit
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par), add = TRUE)
  apply_par(P)

  # Axis limits
  xlim <- if (is.null(P[["xlim"]])) range(times) else P[["xlim"]]
  ylim <- if (is.null(P[["ylim"]])) range(residuals, na.rm = TRUE) else P[["ylim"]]

  # Colours
  cols <- grDevices::hcl.colors(1, palette = palette, alpha = P[["alpha"]])

  # Set up panel (labels added as outer labels for consistency)
  setup_panel(xlim, ylim, P)

  # Zero line
  abline(h = 0, col = P[["col.axis"]], lty = 2, lwd = 2)

  # Plot residuals
  lines(times, residuals, col = cols[1], lwd = 1)

  # Outer labels
  add_outer_labels(P, main = P[["main"]], xlab = P[["xlab"]], ylab = P[["ylab"]])

  invisible(NULL)
}


#' Plot ACF of residuals
#'
#' Assess remaining autocorrelation in the residuals of the fitted model by
#' plotting the autocorrelation function (ACF). Ideally, there should be no
#' significant autocorrelation remaining, indicating that the model has
#' adequately captured the temporal dependencies in the data.
#'
#' @param fit A `fit_affectOU` object
#' @inheritParams plot_parameters
#' @param ... Additional graphical parameters
#'
#' @return NULL (invisibly), called for side effects only.
#'
#' @export
#' @concept fit
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' ou_plot_fit_acf(fitted)
ou_plot_fit_acf <- function(fit,
                            lag.max = 30,
                            palette = "Dark 3",
                            main = "ACF of Residuals",
                            xlab = "Lag",
                            ylab = "ACF",
                            alpha = .8,
                            ...) {
  # Parse arguments
  args <- c(as.list(environment()), list(...))
  args[["fit"]] <- NULL
  P <- get_plot_params(user = args)

  # Extract data
  residuals <- fit[["data"]] - fit[["fitted_values"]]

  # Compute ACF
  acf_result <- stats::acf(residuals, lag.max = lag.max, plot = FALSE)
  lags <- as.numeric(acf_result[["lag"]])
  acf_vals <- replace_na(as.numeric(acf_result[["acf"]]))

  # Confidence bounds (approximate 95%)
  n <- length(residuals)
  ci <- stats::qnorm(0.975) / sqrt(n)

  # Set up par and restore on exit
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par), add = TRUE)
  apply_par(P)

  # Axis limits
  xlim <- if (is.null(P[["xlim"]])) range(lags) else P[["xlim"]]
  ylim <- if (is.null(P[["ylim"]])) c(min(acf_vals, -ci), max(acf_vals, ci)) else P[["ylim"]]

  # Colours
  cols <- grDevices::hcl.colors(1, palette = palette, alpha = P[["alpha"]])

  # Set up panel (labels added as outer labels for consistency)
  setup_panel(xlim, ylim, P)

  # Zero line
  abline(h = 0, col = P[["col.axis"]], lty = 1, lwd = 1)

  # Confidence bounds
  abline(h = c(-ci, ci), col = P[["col.axis"]], lty = 2, lwd = 1)

  # Plot ACF bars
  segments(
    x0 = lags,
    y0 = 0,
    x1 = lags,
    y1 = acf_vals,
    col = cols[1],
    lwd = 2
  )

  # Outer labels
  add_outer_labels(P, main = P[["main"]], xlab = P[["xlab"]], ylab = P[["ylab"]])

  invisible(NULL)
}


#' QQ plot of residuals
#'
#' Visualize a normal Q-Q plot of the residuals to assess their distributional
#' properties. Ideally, residuals should lie approximately along the reference
#' line, indicating normality.
#'
#' @param fit A `fit_affectOU` object
#' @inheritParams plot_parameters
#' @param ... Additional graphical parameters
#'
#' @return NULL (invisibly), called for side effects only.
#'
#' @export
#' @concept fit
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' ou_plot_fit_qq(fitted)
ou_plot_fit_qq <- function(fit,
                           palette = "Dark 3",
                           main = "Normal Q-Q Plot of Residuals",
                           xlab = "Theoretical Quantiles",
                           ylab = "Sample Quantiles",
                           alpha = 0.8,
                           ...) {
  # Parse arguments
  args <- c(as.list(environment()), list(...))
  args[["fit"]] <- NULL
  P <- get_plot_params(user = args)

  # Extract and standardize residuals
  residuals <- fit[["data"]] - fit[["fitted_values"]]
  residuals <- (residuals - mean(residuals)) / stats::sd(residuals)

  # Compute QQ coordinates
  n <- length(residuals)
  theoretical <- stats::qnorm(stats::ppoints(n))
  sample_quantiles <- sort(residuals)

  # Set up par and restore on exit
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par), add = TRUE)
  apply_par(P)

  # Axis limits
  lim_range <- range(c(theoretical, sample_quantiles), na.rm = TRUE)
  xlim <- if (is.null(P[["xlim"]])) lim_range else P[["xlim"]]
  ylim <- if (is.null(P[["ylim"]])) lim_range else P[["ylim"]]

  # Colours
  cols <- grDevices::hcl.colors(1, palette = palette, alpha = P[["alpha"]])

  # Set up panel (labels added as outer labels for consistency)
  setup_panel(xlim, ylim, P)

  # Reference line (identity)
  abline(a = 0, b = 1, col = P[["col.axis"]], lty = 2, lwd = 2)

  # Plot points
  points(theoretical, sample_quantiles,
    col = cols[1], pch = 19, cex = 0.6
  )

  # Outer labels
  add_outer_labels(P, main = P[["main"]], xlab = P[["xlab"]], ylab = P[["ylab"]])

  invisible(NULL)
}
