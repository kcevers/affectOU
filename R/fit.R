# Fit generic ----------------------------------------------------------------

#' @importFrom generics fit
#' @export
#' @concept fit
generics::fit

# Fit method -----------------------------------------------------------------

#' Fit Ornstein-Uhlenbeck model to data
#'
#' Estimates OU parameters using the exact discrete-time transition density
#' via maximum likelihood. Currently limited to univariate (1D) models.
#'
#' @param object An object of class [`affectOU`][affectOU()].
#' @param data A numeric vector of observed affect values. Must contain at
#'   least 2 finite observations.
#' @param times A numeric vector of observation times, the same length as
#'   `data` and strictly increasing, since observations are ordered in time
#'   with no repeated time points. If `NULL`, unit spacing is assumed.
#'   If `NULL`, defaults to equally spaced times: 0, 1, 2, …
#' @param method A single string naming the estimation method.
#'   Currently only `"mle"` (i.e., maximum likelihood estimation)
#'   is supported.
#' @param start Optional named vector of starting values for parameters:
#'  `theta`, `mu`, and `gamma`. If `NULL`, reasonable defaults are chosen
#'  based on the data. Specifically, `theta` is initialized using the
#'  empirical lag-1 autocorrelation, `mu` is initialized to the sample mean,
#'  and `gamma` is initialized based on the stationary variance estimate.
#'
#' @param ... Additional arguments (unused)
#'
#' @return An object of class [`fit_affectOU`][fit.affectOU()], containing:
#' \describe{
#'   \item{parameters}{Named list of fitted parameter estimates.}
#'   \item{se}{Named list of standard errors for parameters.}
#'   \item{fitted_values}{Conditional means under the fitted model.}
#'   \item{residuals}{Vector of residuals (`data - fitted_values`).}
#'   \item{log_likelihood}{Maximized log-likelihood value.}
#'   \item{rmse}{Root Mean Squared Error of the fitted values.}
#'   \item{convergence}{Optimizer convergence code.}
#'   \item{start}{List of starting values used by the optimizer.}
#'   \item{nobs}{Number of observations.}
#'   \item{data}{The observed data used for fitting.}
#'   \item{times}{The observation times used.}
#'   \item{method}{Estimation method used (e.g., `"mle"`).}
#'   \item{model}{The original `affectOU` model used for fitting.}
#' }
#'
#' @export
#' @concept fit
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 1000, dt = 0.01, save_at = 0.01)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' print(fitted)
#' plot(fitted)
fit.affectOU <- function(object,
                         data,
                         times = NULL,
                         method = "mle",
                         start = NULL,
                         ...) {
  # --- Input validation ---
  call <- rlang::current_env()

  check_model_class(object, "affectOU", "an <affectOU> model", "object", call = call)

  ndim <- object[["ndim"]]

  # Only support 1D models
  if (ndim != 1) {
    cli::cli_abort(
      c(
        "{.fun fit} currently supports one-dimensional models only.",
        "x" = "{.arg object} has {ndim} dimensions."
      ),
      call = call,
      class = "affectOU_error_fit_multivariate"
    )
  }

  rlang::check_string(method, arg = "method", call = call)
  if (!identical(method, "mle")) {
    cli::cli_abort(
      '{.arg method} must be "mle", not {.val {method}}.',
      call = call,
      class = "affectOU_error_unsupported_method"
    )
  }

  # Handle data format
  if (is.matrix(data) && ncol(data) == 1) {
    data <- as.vector(data)
  }
  if (!is.numeric(data) || !is.vector(data)) {
    rlang::stop_input_type(data, "a numeric vector", arg = "data", call = call)
  }
  if (length(data) < 2) {
    cli::cli_abort(
      "{.arg data} must contain at least 2 observations, not {length(data)}.",
      call = call,
      class = "affectOU_error_too_few_observations"
    )
  }
  if (!all(is.finite(data))) {
    cli::cli_abort(
      c(
        "{.arg data} must contain only finite values.",
        "x" = "It contains {.code {non_finite_kinds(data)}} values.",
        "i" = "Remove or impute missing observations before fitting."
      ),
      call = call,
      class = "affectOU_error_not_finite"
    )
  }

  # Default times: unit spacing
  if (is.null(times)) {
    times <- seq(0, length(data) - 1)
    cli::cli_warn(c(
      "!" = "{.arg times} was not supplied; assuming unit spacing (0, 1, 2, ...).",
      "i" = "Supply {.arg times} if the observations are unevenly spaced?"
    ))
  }

  # Type before length: a character `times` is a type problem, not a length one.
  if (!is.numeric(times) || !is.vector(times)) {
    rlang::stop_input_type(times, "a numeric vector", arg = "times", call = call)
  }
  check_all_finite(times, "times", call = call)

  n_obs <- length(data)
  if (n_obs != length(times)) {
    cli::cli_abort(
      c(
        "{.arg data} and {.arg times} must be the same length.",
        "x" = "{.arg data} has {n_obs} value{?s} and {.arg times} has {length(times)}."
      ),
      call = call,
      class = "affectOU_error_length_mismatch"
    )
  }

  if (any(diff(times) <= 0)) {
    bad <- which(diff(times) <= 0)[[1]] + 1L
    cli::cli_abort(
      c(
        "{.arg times} must be strictly increasing.",
        "x" = "{.code times[{bad}]} is not greater than {.code times[{bad - 1L}]}.",
        "i" = "Observations must be ordered in time, with no repeated time points."
      ),
      call = call,
      class = "affectOU_error_times_not_increasing"
    )
  }

  if (!is.null(start)) {
    if (!is.numeric(start) || !is.vector(start)) {
      rlang::stop_input_type(start, "a numeric vector", arg = "start", call = call)
    }

    check_all_finite(start, "start", call = call)

    nms <- c("theta", "mu", "gamma")
    if (!all(nms %in% names(start)) || length(start) != length(nms)) {
      cli::cli_abort(
        c(
          "{.arg start} must be a named vector with names {.val {nms}}.",
          "x" = if (is.null(names(start))) {
            "It has no names."
          } else {
            "Its names are {.val {names(start)}}."
          }
        ),
        call = call,
        class = "affectOU_error_start_names"
      )
    }
  }

  # Perform MLE estimation
  fit_result <- fit_ou_mle(data, times, start = start)

  # Construct fit object
  fitted_object <- new_fit_affectOU(
    parameters = fit_result$parameters,
    fitted_values = fit_result$fitted_values,
    residuals = unname(data - fit_result$fitted_values),
    se = fit_result$se,
    log_likelihood = fit_result$log_likelihood,
    rmse = sqrt(mean((data - fit_result$fitted_values)^2)),
    convergence = fit_result$convergence,
    start = fit_result$start,
    nobs = n_obs,
    data = data,
    times = times,
    method = method,
    model = object
  )

  validate_fit_affectOU(fitted_object, call = call)

  fitted_object
}


#' Low-level constructor for fit_affectOU objects
#'
#' Users should use [fit()] instead.
#' @keywords internal
#' @noRd
new_fit_affectOU <- function(parameters, fitted_values, residuals, se,
                             log_likelihood, rmse, convergence, start,
                             nobs, data, times, method, model) {
  structure(
    list(
      parameters = parameters,
      fitted_values = fitted_values,
      residuals = residuals,
      se = se,
      log_likelihood = log_likelihood,
      rmse = rmse,
      convergence = convergence,
      start = start,
      nobs = nobs,
      data = data,
      times = times,
      method = method,
      model = model
    ),
    class = "fit_affectOU"
  )
}

#' Validate fit_affectOU object
#'
#' Check that an object of class `fit_affectOU` has the correct structure and content.
#' @keywords internal
#' @noRd
validate_fit_affectOU <- function(x, call = rlang::caller_env()) {
  if (!inherits(x, "fit_affectOU")) {
    cli::cli_abort(
      "Object must be of class {.cls fit_affectOU}.",
      call = call, .internal = TRUE
    )
  }

  # Check required components
  required_components <- c(
    "parameters", "fitted_values", "residuals", "se",
    "log_likelihood", "rmse", "convergence", "start",
    "nobs", "data", "times", "method", "model"
  )
  missing_components <- setdiff(required_components, names(x))
  if (length(missing_components) > 0) {
    cli::cli_abort(
      "Missing components in {.cls fit_affectOU} object: {.val {missing_components}}.",
      call = call, .internal = TRUE
    )
  }

  # Check components types
  if (!is.list(x$parameters) || length(x$parameters) != 3) {
    cli::cli_abort(
      "{.field parameters} must be a named list of length 3.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x$fitted_values) || !is.vector(x$fitted_values)) {
    cli::cli_abort(
      "{.field fitted_values} must be a numeric vector.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x$residuals) || !is.vector(x$residuals)) {
    cli::cli_abort(
      "{.field residuals} must be a numeric vector.",
      call = call, .internal = TRUE
    )
  }
  if (!is.list(x$se) || length(x$se) != 3) {
    cli::cli_abort(
      "{.field se} must be a named list of length 3.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x$log_likelihood) || length(x$log_likelihood) != 1) {
    cli::cli_abort(
      "{.field log_likelihood} must be a single number.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x$rmse) || length(x$rmse) != 1) {
    cli::cli_abort(
      "{.field rmse} must be a single number.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x$convergence) || length(x$convergence) != 1) {
    cli::cli_abort(
      "{.field convergence} must be a single number.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x$nobs) || length(x$nobs) != 1) {
    cli::cli_abort(
      "{.field nobs} must be a single number.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x$data) || !is.vector(x$data)) {
    cli::cli_abort(
      "{.field data} must be a numeric vector.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x$times) || !is.vector(x$times)) {
    cli::cli_abort(
      "{.field times} must be a numeric vector.",
      call = call, .internal = TRUE
    )
  }
  if (!is.character(x$method) || length(x$method) != 1) {
    cli::cli_abort(
      "{.field method} must be a single string.",
      call = call, .internal = TRUE
    )
  }
  if (!inherits(x$model, "affectOU")) {
    cli::cli_abort(
      "{.field model} must be of class {.cls affectOU}.",
      call = call, .internal = TRUE
    )
  }

  # Check consistency data, fitted, and residuals
  if (length(x$data) != length(x$fitted_values)) {
    cli::cli_abort(
      "Length of {.field data} and {.field fitted_values} must be the same.",
      call = call, .internal = TRUE
    )
  }
  if (length(x$residuals) != length(x$data)) {
    cli::cli_abort(
      "Length of {.field residuals} and {.field data} must be the same.",
      call = call, .internal = TRUE
    )
  }
  if (!isTRUE(all.equal(
    x$data,
    x$fitted_values + x$residuals,
    check.attributes = FALSE
  ))) {
    cli::cli_abort(
      "{.field data} must equal {.field fitted_values} + {.field residuals}.",
      call = call, .internal = TRUE
    )
  }

  # Check consistency nobs, data, times
  if (length(x$data) != x$nobs) {
    cli::cli_abort(
      "Length of {.field data} must equal {.field nobs}.",
      call = call, .internal = TRUE
    )
  }
  if (length(x$times) != x$nobs) {
    cli::cli_abort(
      "Length of {.field times} must equal {.field nobs}.",
      call = call, .internal = TRUE
    )
  }

  invisible(x)
}


#' MLE estimation for 1D OU process
#' @noRd
fit_ou_mle <- function(data, times, start) {
  n <- length(data)
  dt <- diff(times)

  # Standardize the data internally for numerical stability ------------------
  # The OU likelihood is affine-equivariant in the data: under y -> a*y + b,
  # theta is invariant, mu -> a*mu + b, and gamma -> a*gamma. Fitting on the
  # standardized series z = (data - center) / scale keeps mu near 0 and gamma
  # near O(1), which conditions the optimizer well regardless of the original
  # data scale. All estimates are back-transformed to the original scale below.
  center <- mean(data)
  scale <- stats::sd(data)
  if (!is.finite(scale) || scale == 0) {
    # Constant (or near-degenerate) data: fall back to the raw scale.
    scale <- 1
  }
  z <- (data - center) / scale

  # Negative log-likelihood (on the standardized series z)
  neg_log_lik <- function(params) {
    theta <- exp(params[1])
    mu <- params[2]
    gamma <- exp(params[3])

    # Numerical stability checks
    if (!is.finite(theta) || !is.finite(gamma)) {
      return(1e10)
    }
    if (theta < 1e-10 || gamma < 1e-10) {
      return(1e10)
    }
    if (theta > 1e6 || gamma > 1e6) {
      return(1e10)
    }

    # Conditional distribution parameters
    exp_theta_dt <- exp(-theta * dt)
    cond_mean <- mu + (z[-n] - mu) * exp_theta_dt

    # Variance calculation with numerical stability
    # Var = (gamma^2 / (2*theta)) * (1 - exp(-2*theta*dt))
    # For small theta*dt, use Taylor expansion to avoid numerical issues
    two_theta_dt <- 2 * theta * dt
    var_factor <- ifelse(
      two_theta_dt < 1e-4,
      dt * (1 - two_theta_dt / 2 + two_theta_dt^2 / 6), # Taylor expansion

      (1 - exp(-two_theta_dt)) / (2 * theta)
    )
    cond_var <- gamma^2 * var_factor

    # Check for valid variances
    if (any(cond_var <= 0) || any(!is.finite(cond_var))) {
      return(1e10)
    }

    # Log-likelihood
    ll <- sum(stats::dnorm(z[-1],
      mean = cond_mean, sd = sqrt(cond_var),
      log = TRUE
    ))

    if (!is.finite(ll)) {
      return(1e10)
    }

    -ll
  }

  # Estimate starting values using method of moments / empirical estimates.
  # All heuristics operate on the standardized series z, so the starting
  # values are already on the scale the optimizer works in.
  if (is.null(start)) {
    # Estimate mu from the mean of the standardized data (~ 0)
    mu_start <- mean(z)

    # Estimate theta from lag-1 autocorrelation
    # For OU: rho(dt) = exp(-theta * dt), so theta = -log(rho) / dt
    mean_dt <- mean(dt)
    centered <- z - mu_start
    autocov_0 <- mean(centered^2)
    autocov_1 <- sum(centered[-n] * centered[-1]) / n
    rho <- autocov_1 / autocov_0
    rho <- max(0.01, min(0.99, rho)) # Bound away from 0 and 1
    theta_start <- -log(rho) / mean_dt
    theta_start <- max(0.01, min(100, theta_start)) # Reasonable bounds

    # Estimate gamma from stationary variance
    # Var_stationary = gamma^2 / (2 * theta)
    # So gamma = sqrt(2 * theta * var)
    gamma_start <- sqrt(2 * theta_start * autocov_0)
    gamma_start <- max(0.01, gamma_start)

    start <- c(
      log(theta_start),
      mu_start,
      log(gamma_start)
    )
  } else {
    # User-supplied start is on the original data scale; map it to the
    # standardized scale (theta invariant, mu and gamma rescaled).
    start <- c(
      log(start["theta"]),
      (start["mu"] - center) / scale,
      log(start["gamma"] / scale)
    )
  }

  # Check for non-finite starting values
  idx <- which(!is.finite(start))
  if (length(idx) > 0) {
    cli::cli_warn(
      "Non-finite starting values for {.val {names(start)[idx]}}; using defaults instead."
    )
    start[idx] <- c(log(0.5), 0, log(1))[idx]
  }

  # Try multiple optimization methods
  opt_result <- tryCatch(
    {
      stats::optim(
        par = start,
        fn = neg_log_lik,
        method = "BFGS",
        hessian = TRUE,
        control = list(maxit = 5000)
      )
    },
    error = function(e) NULL
  )

  # Fallback to Nelder-Mead if BFGS fails
  if (is.null(opt_result) || opt_result$convergence != 0) {
    nm_start <- if (is.null(opt_result)) start else opt_result$par
    opt_result_nm <- stats::optim(
      par = nm_start,
      fn = neg_log_lik,
      method = "Nelder-Mead",
      hessian = TRUE,
      control = list(maxit = 5000)
    )
    if (is.null(opt_result) || opt_result_nm$value < opt_result$value) {
      opt_result <- opt_result_nm
    }
  }

  # Extract parameters on the standardized scale
  theta_z <- exp(opt_result$par[1])
  mu_z <- opt_result$par[2]
  gamma_z <- exp(opt_result$par[3])

  # Standard errors via delta method (still on the standardized scale)
  # If optimizing log(theta), then SE(theta) = theta * SE(log(theta))
  se <- tryCatch(
    {
      hess_inv <- solve(opt_result$hessian)
      if (any(diag(hess_inv) < 0)) {
        rep(NA_real_, 3)
      } else {
        sqrt(diag(hess_inv))
      }
    },
    error = function(e) rep(NA_real_, 3)
  )

  # Apply delta method for transformed parameters (standardized scale)
  se_theta_z <- if (is.na(se[1])) NA_real_ else se[1] * theta_z
  se_mu_z <- se[2]
  se_gamma_z <- if (is.na(se[3])) NA_real_ else se[3] * gamma_z

  # Back-transform estimates to the original data scale.
  # Under y = scale * z + center: theta invariant, mu -> scale*mu + center,
  # gamma -> scale*gamma (and the same linear factor applies to their SEs).
  theta <- theta_z
  mu <- scale * mu_z + center
  gamma <- scale * gamma_z

  se_theta <- se_theta_z
  se_mu <- if (is.na(se_mu_z)) NA_real_ else scale * se_mu_z
  se_gamma <- if (is.na(se_gamma_z)) NA_real_ else scale * se_gamma_z

  # Compute fitted values (conditional expectations) on the original scale.
  # The recursion is affine-equivariant, so using back-transformed parameters
  # on the raw data yields the original-scale fitted values directly.
  fitted <- numeric(n)
  fitted[1] <- data[1]
  for (i in 2:n) {
    fitted[i] <- mu + (data[i - 1] - mu) * exp(-theta * dt[i - 1])
  }

  # Report the log-likelihood of the original data. The optimizer maximized the
  # likelihood of z; the change of variables y = scale*z + center contributes a
  # Jacobian of -log(scale) per conditional density (n - 1 of them).
  log_likelihood <- -opt_result$value - (n - 1) * log(scale)

  list(
    parameters = list(theta = theta, mu = mu, gamma = gamma),
    se = list(theta = se_theta, mu = se_mu, gamma = se_gamma),
    fitted_values = fitted,
    log_likelihood = log_likelihood,
    convergence = opt_result$convergence,
    # Report starting values on the original data scale for transparency.
    start = list(
      theta = exp(start[1]),
      mu = scale * start[2] + center,
      gamma = scale * exp(start[3])
    )
  )
}


#' Extract log-likelihood from fitted OU affect model
#'
#' @param object An object of class [`fit_affectOU`][fit.affectOU()].
#' @param ... Additional arguments (unused).
#' @return An object of class `logLik` with `df` and `nobs` attributes.
#' @export
#' @concept fit
#'
#' @importFrom stats logLik
#'
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' logLik(fitted)
logLik.fit_affectOU <- function(object, ...) {
  structure(
    object[["log_likelihood"]],
    df = length(object[["parameters"]]),
    nobs = object[["nobs"]],
    class = "logLik"
  )
}


#' Extract coefficients from fitted OU affect model
#'
#' @param object An object of class [`fit_affectOU`][fit.affectOU()].
#' @param ... Additional arguments (unused).
#' @return Named vector of fitted parameters.
#'
#' @export
#' @concept fit
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' coef(fitted)
coef.fit_affectOU <- function(object, ...) {
  unlist(object$parameters)
}

#' Confidence intervals for fitted OU affect model
#'
#' @param object An object of class [`fit_affectOU`][fit.affectOU()].
#' @param parm Optional character vector naming parameters of the fitted
#'   model to include: any of `theta`, `mu`, and `gamma`.
#'  If missing, all parameters are included.
#' @param level Confidence level for intervals: a number between 0 and 1
#'   (default 0.95).
#' @param ... Additional arguments (unused).
#' @return Matrix of confidence intervals with columns for lower and upper bounds.
#'
#' @export
#' @concept fit
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' confint(fitted)
confint.fit_affectOU <- function(object, parm, level = 0.95, ...) {
  # Get parameters and SEs
  params <- unlist(object$parameters)
  se <- unlist(object$se)

  call <- rlang::current_env()
  check_model_class(
    object, "fit_affectOU", "a fitted model from {.fun fit}", "object",
    call = call
  )

  # Subset if parm specified
  if (!missing(parm)) {
    if (!all(parm %in% names(params))) {
      bad <- setdiff(parm, names(params))[[1]]
      cli::cli_abort(
        c(
          "{.arg parm} must name parameters of the fitted model.",
          "x" = "{.val {bad}} is not one of {.val {cli::cli_vec(names(params), list('vec-last' = ', or '))}}."
        ),
        call = call,
        class = "affectOU_error_unknown_parm"
      )
    }

    params <- params[parm]
    se <- se[parm]
  }

  # Calculate intervals
  check_level(level, call = call)

  alpha <- 1 - level
  z <- stats::qnorm(1 - alpha / 2)

  ci <- cbind(
    params - z * se,
    params + z * se
  )

  colnames(ci) <- paste0(c(alpha / 2, 1 - alpha / 2) * 100, "%")
  ci
}

#' Summarize fitted OU affect model
#'
#' Summarize the result of fitting an Ornstein-Uhlenbeck model to data. Output includes a
#' parameter table with estimates, standard errors, and confidence intervals,
#' as well as goodness-of-fit statistics.
#'
#' @param object An object of class [`fit_affectOU`][fit.affectOU()].
#' @param level Confidence level for intervals: a number between 0 and 1
#'   (default 0.95).
#' @param ... Additional arguments (unused).
#'
#' @return An object of class [`summary_fit_affectOU`][summary.fit_affectOU()] containing:
#'   \describe{
#'     \item{coefficients}{Data frame with columns `estimate`, `se`, `lower`,
#'       and `upper` for each parameter.}
#'     \item{log_likelihood}{Maximized log-likelihood value.}
#'     \item{rmse}{Root mean squared error.}
#'     \item{nobs}{Number of observations.}
#'     \item{convergence}{Optimizer convergence code (0 = success).}
#'     \item{level}{Confidence level used.}
#'     \item{method}{Estimation method used.}
#'   }
#'
#' @export
#' @concept fit
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' summary(fitted)
summary.fit_affectOU <- function(object, level = 0.95, ...) {
  call <- rlang::current_env()
  check_model_class(
    object, "fit_affectOU", "a fitted model from {.fun fit}", "object",
    call = call
  )
  check_level(level, call = call)

  params <- unlist(object$parameters)
  se <- unlist(object$se)

  alpha <- 1 - level
  z <- stats::qnorm(1 - alpha / 2)

  coef_table <- data.frame(
    estimate = params,
    se = se,
    lower = params - z * se,
    upper = params + z * se,
    row.names = names(params)
  )
  colnames(coef_table)[3:4] <- paste0(c(alpha / 2, 1 - alpha / 2) * 100, "%")

  out <- list(
    coefficients = coef_table,
    log_likelihood = object$log_likelihood,
    rmse = object$rmse,
    nobs = object$nobs,
    convergence = object$convergence,
    level = level,
    method = object$method
  )

  class(out) <- "summary_fit_affectOU"
  out
}


#' Print summary of fitted OU affect model
#'
#' @param x An object of class [`summary_fit_affectOU`][summary.fit_affectOU()].
#' @param digits Number of digits for numeric display.
#' @param ... Additional arguments (unused).
#'
#' @return Returns `x` invisibly.
#' @export
#' @concept fit
#' @method print summary_fit_affectOU
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' print(summary(fitted))
print.summary_fit_affectOU <- function(x, digits = 3, ...) {
  cli::cli_h1("Fitted Ornstein-Uhlenbeck Model Summary")

  cli::cli_text("Method: {x$method}, {x$nobs} observations")

  if (x$convergence != 0) {
    cli::cli_alert_warning("Optimizer did not converge (code {x$convergence}).")
  }

  # Parameter table
  cli::cli_h2("Coefficients")
  ci_label <- sprintf("%.0f%% CI", x$level * 100)
  coef_df <- x$coefficients
  coef_display <- data.frame(
    Estimate = round(coef_df$estimate, digits),
    SE = round(coef_df$se, digits),
    check.names = FALSE,
    row.names = rownames(coef_df)
  )
  coef_display[[ci_label]] <- sprintf(
    "[%.*f, %.*f]",
    digits, coef_df[[3]],
    digits, coef_df[[4]]
  )
  cli::cli_verbatim(paste(utils::capture.output(coef_display), collapse = "\n"))

  # Goodness of fit
  cli::cli_h2("Goodness of fit")
  cli::cli_text("Log-likelihood: {round(x$log_likelihood, digits)}")
  cli::cli_text("RMSE: {round(x$rmse, digits)}")

  invisible(x)
}


#' Print fitted OU affect model
#'
#' Provide a concise overview of a [`fit_affectOU`][fit.affectOU()] object.
#'
#' @param x An object of class [`fit_affectOU`][fit.affectOU()]
#' @param digits Number of digits for numeric display.
#' @param ... Additional arguments (unused).
#'
#' @return Returns `x` invisibly.
#'
#' @export
#' @concept fit
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 500, dt = 0.01, save_at = 0.1)
#' data <- as.data.frame(sim)
#' fitted <- fit(model, data = data$value, times = data$time)
#' print(fitted)
print.fit_affectOU <- function(x, digits = 3, ...) {
  ndim <- x[["model"]][["ndim"]]
  nobs <- x[["nobs"]]
  ntime <- length(x[["times"]])
  dt <- if (ntime > 1) round(mean(diff(x[["times"]])), digits) else NA_real_
  ll <- x[["log_likelihood"]]
  rmse <- x[["rmse"]]

  theta <- x[["parameters"]][["theta"]]
  mu <- x[["parameters"]][["mu"]]
  gamma <- x[["parameters"]][["gamma"]]

  cli::cli_h1(sprintf("Fitted %dD Ornstein-Uhlenbeck Model", ndim))
  cli::cli_text(sprintf(
    "%d data points%s",
    nobs,
    if (!is.na(dt)) sprintf(" (dt \u2248 %.*f)", digits, dt) else ""
  ))

  cli::cli_text(sprintf(
    "{.emph \u03b8} = %.*f, {.emph \u03bc} = %.*f, {.emph \u03b3} = %.*f",
    digits, theta, digits, mu, digits, gamma
  ))

  if (!is.null(ll)) {
    cli::cli_text(sprintf("Log-likelihood: %.*f", digits, ll))
  }
  if (!is.null(rmse)) {
    cli::cli_text(sprintf("RMSE: %.*f", digits, rmse))
  }

  invisible(x)
}
