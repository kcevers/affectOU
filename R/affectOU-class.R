# User-facing constructor ----------------------------------------------------

#' Create Ornstein-Uhlenbeck affect model
#'
#' Create a model object representing an Ornstein-Uhlenbeck (OU) process for
#' affect dynamics. Both unidimensional and multidimensional models are supported.
#'
#' The OU is a continuous-time stochastic differential equation model that, in
#' its multivariate variant, can be written down as follows:
#'
#' \deqn{d\mathbf{X}(t) = \mathbf{\Theta} (\mathbf{\mu} - \mathbf{X}(t))dt + \mathbf{\Gamma} d\mathbf{W}(t)}
#'
#' which can be simplified in the one-dimensional case to:
#'
#' \deqn{dX(t) = \theta (\mu - X(t))dt + \gamma dW(t)}
#'
#' where:
#' - \eqn{\mathbf{X}(t)} represents the affective state at time \eqn{t};
#' - \eqn{\mathbf{\Theta}} (theta) represents the drift matrix, governing the
#' rate at which affect returns to its baseline;
#' - \eqn{\mathbf{\mu}} (mu) represents the location of the baseline or attractor;
#' - \eqn{\mathbf{\Gamma}} (gamma) is a lower-triangular matrix governing the
#' size of the stochastic diffusion;
#' - \eqn{\mathbf{W}(t)} represents the Wiener process, adding randomness to the
#' system.
#'
#' Using the matrix \eqn{\mathbf{\Gamma}}, one can derive the stationary
#' covariance matrix \eqn{\mathbf{\Sigma}} for the system through using
#' \eqn{\mathbf{\Gamma}} as the basis for the Cholesky decomposition and solving
#' the Lyapunov equation, namely:
#'
#' \deqn{\mathbf{\Gamma} \mathbf{\Gamma}^T = \mathbf{\Theta} \mathbf{\Sigma} + \mathbf{\Sigma} \mathbf{\Theta}^T}
#'
#' In the multidimensional case, the off-diagonal elements of the drift matrix
#' \eqn{\mathbf{\Theta}} determine the temporal coupling between the different
#' variables contained in \eqn{\mathbf{X}}, specifying how these variables
#' co-evolve over time.
#'
#' @references
#' Oravecz, Z., Tuerlinckx, F., & Vandekerckhove, J. (2011).
#' A hierarchical latent stochastic differential equation model for
#' affective dynamics. Psychological Methods, 16(4), 468-490.
#'
#' @param ndim The number of affect dimensions modelled. Defaults to 1
#'   (univariate). Only needs to be specified if it cannot be inferred from the
#'   dimensions of the other parameters. Must be a whole number of at least 1.
#' @param theta How quickly affect returns to baseline -- low values mean
#'   feelings linger (inertia or rumination). Formally the attractor strength,
#'   or drift matrix. For 1D: a single number. For multidimensional: a square
#'   matrix, whose off-diagonal elements set the temporal coupling between
#'   dimensions. When `theta < 0`, the model is non-stationary: the process is
#'   repelled from `mu` rather than toward it; when `theta \approx 0`, the
#'   model is a random walk and `mu` has no meaningful influence on the
#'   trajectory.
#' @param mu The baseline affect the process returns to -- a person's typical
#'   mood. Formally the attractor location. For 1D: a single number. For
#'   multidimensional: a vector with one element per dimension.
#' @param gamma How strongly affect responds to ongoing random fluctuation.
#'   Formally the diffusion coefficient (multiplies \eqn{dW(t)} in the SDE).
#'   For 1D: a single number. For multidimensional: a lower triangular matrix
#'   (the Cholesky factor of \eqn{\Sigma}); it must be lower triangular because
#'   it is the square root of a covariance matrix. Specify either `gamma` or
#'   `sigma`, not both: each determines the other. Most users should prefer
#'   specifying `sigma` directly; `gamma` is available for advanced users who
#'   want explicit control over the Cholesky factorisation.
#' @param sigma How much random fluctuation drives each affect dimension, and
#'   how those fluctuations are correlated. Formally the noise covariance matrix
#'   (\eqn{\Sigma = \Gamma\Gamma^\top}). For 1D: a single number, the variance,
#'   which cannot be negative. For multidimensional: a symmetric, positive
#'   semi-definite matrix -- symmetric because the covariance between two
#'   dimensions is the same in either direction, and positive semi-definite
#'   because otherwise some combination of dimensions would have a negative
#'   variance. Off-diagonal elements represent correlated noise between
#'   dimensions. This is the recommended way to specify noise structure.
#'   Specify either `gamma` or `sigma`, not both.
#'
#' @return
#' An object of class [`affectOU`], representing a univariate or multivariate
#' Ornstein–Uhlenbeck affect regulation model. The object is a list with the
#' following components:
#'
#' \describe{
#'
#'   \item{`parameters`}{
#'     A named list of model parameters:
#'     \describe{
#'       \item{`theta`}{Numeric matrix.}
#'       \item{`mu`}{Numeric vector.}
#'       \item{`gamma`}{Numeric matrix.}
#'       \item{`sigma`}{Numeric matrix.}
#'     }
#'   }
#'
#'   \item{`stationary`}{
#'     A named list with the stationary distribution properties, precomputed at
#'     construction: `is_stable` (logical), `mean` (numeric vector or `NULL`
#'     if unstable),
#'     `sd` (numeric vector or `NULL` if unstable), `cov` (matrix or `NULL`),
#'     `cor` (matrix or `NULL`), `ndim` (integer).
#'   }
#'
#'   \item{`ndim`}{
#'     Integer.
#'   }
#'
#' }
#'
#' @seealso
#' * [simulate.affectOU()] to generate trajectories.
#' * [plot.simulate_affectOU()] to visualize simulations
#'   (`type = "time"`, `"histogram"`, `"acf"`, `"phase"`).
#' * [summary.affectOU()] for stability and the stationary distribution.
#' * [fit.affectOU()] to estimate parameters from observed data.
#' * [update.affectOU()] to modify parameters without recreating the model.
#'
#' @export
#' @concept config
#'
#' @examples
#' # 1D model
#' model_1d <- affectOU(theta = 0.5, mu = 0, sigma = 1)
#' summary(model_1d)
#'
#' # Simulate trajectory
#' sim <- simulate(model_1d)
#' plot(sim)
#'
#' # Simulate from a different initial state and a shorter period
#' sim <- simulate(model_1d, initial = 1, stop = 10)
#' plot(sim)
#'
#' # 2D model (uncoupled)
#' model_2d <- affectOU(
#'   theta = diag(c(0.5, 0.3)), mu = 0,
#'   sigma = 1
#' )
#' summary(model_2d)
#'
#' # Simulate trajectory
#' sim <- simulate(model_2d, stop = 100, save_at = 0.1)
#' plot(sim)
#'
#' # 3D model (coupled)
#' theta_3d <- matrix(c(
#'   0.5, 0.1, 0,
#'   0.1, 0.3, 0.05,
#'   0, 0.05, 0.4
#' ), nrow = 3)
#' model_3d <- affectOU(
#'   theta = theta_3d,
#'   mu = 0, sigma = 1
#' )
#' summary(model_3d)
#'
#' # Simulate trajectory
#' sim_3d <- simulate(model_3d, stop = 100, save_at = 0.1)
#' plot(sim_3d)
#'
affectOU <- function(ndim = 1,
                     theta = 0.5,
                     mu = 0,
                     sigma = 1,
                     gamma = t(chol(sigma))) {
  # --- Input validation and coercion ---

  call <- rlang::current_env()

  # Check gamma/sigma mutual exclusivity
  if (!missing(sigma) && !missing(gamma) &&
    !is.null(sigma) && !is.null(gamma)) {
    abort_gamma_sigma_both(call)
  }

  if (missing(gamma) && !missing(sigma)) {
    gamma <- NULL
  }

  args <- validate_model_args(
    ndim = if (missing(ndim)) NULL else ndim,
    theta = theta,
    mu = mu,
    gamma = gamma,
    sigma = sigma,
    call = call
  )

  ndim <- args$ndim
  theta <- args$theta
  mu <- args$mu
  gamma <- args$gamma
  sigma <- args$sigma

  # Precompute stationary distribution
  is_stable <- check_stability(theta)$is_stable
  if (is_stable) {
    stat_cov <- solve_lyapunov(theta, sigma)
    if (ndim == 1) {
      stat_sd <- sqrt(stat_cov[1, 1])
      stat_cov_out <- NULL
      stat_cor <- NULL
    } else {
      stat_sd <- sqrt(diag(stat_cov))
      d <- diag(stat_cov)
      if (all(d > 0)) {
        stat_cor <- stats::cov2cor(stat_cov)
      } else {
        stat_cor <- diag(ndim)
        nonzero <- which(d > 0)
        if (length(nonzero) > 1) {
          stat_cor[nonzero, nonzero] <- stats::cov2cor(stat_cov[nonzero, nonzero])
        }
      }
      stat_cov_out <- stat_cov
    }
    stationary_info <- list(
      is_stable = TRUE, mean = mu, sd = stat_sd,
      cov = stat_cov_out, cor = stat_cor, ndim = ndim
    )
  } else {
    stationary_info <- list(
      is_stable = FALSE, mean = NULL, sd = NULL,
      cov = NULL, cor = NULL, ndim = ndim
    )
  }

  # Create the object
  model <- new_affectOU(
    ndim = ndim,
    theta = theta,
    mu = mu,
    gamma = gamma,
    sigma = sigma,
    stationary = stationary_info
  )

  # Final structural validation
  validate_affectOU(model, call = call)

  model
}


# Low-level constructor ------------------------------------------------------

#' Low-level constructor for affectOU objects
#'
#' Creates an affectOU object. This is a developer
#' function that performs minimal checks for performance. Users should use
#' [affectOU()] instead.
#'
#' @param ndim Integer. Dimensionality of the process.
#' @param theta Numeric matrix. Drift/mean-reversion matrix.
#' @param mu Numeric vector. Attractor location.
#' @param gamma Numeric matrix. Diffusion coefficient.
#' @param sigma Numeric matrix. Noise covariance.
#' @param stationary List. Precomputed stationary distribution properties.
#'
#' @return An object of class [`affectOU`][affectOU()].
#' @noRd
new_affectOU <- function(ndim, theta, mu, gamma, sigma, stationary) {
  structure(
    list(
      parameters = list(
        theta = theta,
        mu = mu,
        gamma = gamma,
        sigma = sigma
      ),
      stationary = stationary,
      ndim = ndim
    ),
    class = "affectOU"
  )
}


# Validator ------------------------------------------------------------------

#' Validate affectOU object structure
#'
#' Checks that the affectOU object has the correct class, required fields, and that
#' fields are of the correct type.
#'
#' @param x Object to validate.
#' @return The object, invisibly (if valid). Throws an error if invalid.
#' @noRd
validate_affectOU <- function(x, call = rlang::caller_env()) {
  # Check class
  if (!inherits(x, "affectOU")) {
    cli::cli_abort(
      "Object must be of class {.cls affectOU}.",
      call = call, .internal = TRUE
    )
  }

  # Check top-level structure
  required_fields <- c("parameters", "stationary", "ndim")
  missing_fields <- setdiff(required_fields, names(x))
  if (length(missing_fields) > 0) {
    cli::cli_abort(
      "Missing required fields: {.field {missing_fields}}.",
      call = call, .internal = TRUE
    )
  }

  # Check ndim
  ndim <- x[["ndim"]]
  if (!is.integer(ndim) || length(ndim) != 1 || ndim < 1L) {
    cli::cli_abort(
      "{.field ndim} must be a positive integer.",
      call = call, .internal = TRUE
    )
  }

  # Check parameters exist
  required_params <- c("theta", "mu", "gamma", "sigma")
  missing_params <- setdiff(required_params, names(x[["parameters"]]))
  if (length(missing_params) > 0) {
    cli::cli_abort(
      "Missing required parameters: {.field {missing_params}}.",
      call = call, .internal = TRUE
    )
  }

  # Check superfluous parameters
  superfluous_params <- setdiff(
    names(x[["parameters"]]),
    required_params
  )
  if (length(superfluous_params) > 0) {
    cli::cli_abort(
      "Unexpected parameters in the model: {.val {superfluous_params}}.",
      call = call, .internal = TRUE
    )
  }

  # Check parameter types and dimensions
  theta <- x[["parameters"]][["theta"]]
  mu <- x[["parameters"]][["mu"]]
  gamma <- x[["parameters"]][["gamma"]]
  sigma <- x[["parameters"]][["sigma"]]

  # theta: numeric matrix, ndim x ndim
  if (!is.numeric(theta) || !is.matrix(theta)) {
    cli::cli_abort(
      "{.field theta} must be a numeric matrix.",
      call = call, .internal = TRUE
    )
  }
  if (!all(dim(theta) == c(ndim, ndim))) {
    cli::cli_abort(
      "{.field theta} must be a {ndim}x{ndim} matrix.",
      call = call, .internal = TRUE
    )
  }

  # mu: numeric vector, length ndim
  if (!is.numeric(mu) || !is.vector(mu) || length(mu) != ndim) {
    cli::cli_abort(
      "{.field mu} must be a numeric vector of length {ndim}.",
      call = call, .internal = TRUE
    )
  }

  # gamma: numeric matrix, ndim x ndim, lower triangular
  if (!is.numeric(gamma) || !is.matrix(gamma)) {
    cli::cli_abort(
      "{.field gamma} must be a numeric matrix.",
      call = call, .internal = TRUE
    )
  }
  if (!all(dim(gamma) == c(ndim, ndim))) {
    cli::cli_abort(
      "{.field gamma} must be a {ndim}x{ndim} matrix.",
      call = call, .internal = TRUE
    )
  }
  if (!is_lower_triangular(gamma)) {
    cli::cli_abort(
      "{.field gamma} must be a lower triangular matrix.",
      call = call, .internal = TRUE
    )
  }

  # sigma: numeric matrix, ndim x ndim
  if (!is.numeric(sigma) || !is.matrix(sigma)) {
    cli::cli_abort(
      "{.field sigma} must be a numeric matrix.",
      call = call, .internal = TRUE
    )
  }
  if (!all(dim(sigma) == c(ndim, ndim))) {
    cli::cli_abort(
      "{.field sigma} must be a {ndim}x{ndim} matrix.",
      call = call, .internal = TRUE
    )
  }

  invisible(x)
}


# Helper functions for input processing --------------------------------------

#' `gamma` and `sigma` both supplied
#'
#' Shared by [affectOU()] and [update.affectOU()], which each pass their own
#' `call` so the error names the function the user typed.
#'
#' @noRd
abort_gamma_sigma_both <- function(call) {
  cli::cli_abort(
    c(
      "Specify either {.arg gamma} or {.arg sigma}, not both.",
      "i" = paste(
        "{.arg sigma} is the noise covariance matrix and {.arg gamma} is its",
        "lower triangular square root, so supplying one determines the other."
      )
    ),
    call = call,
    class = "affectOU_error_gamma_sigma_both"
  )
}


#' Validate and coerce the model parameters
#'
#' The single validation boundary for model parameters, shared by [affectOU()]
#' and [update.affectOU()]. Returns the coerced parameters; everything
#' downstream may assume they are valid.
#'
#' @param ndim `NULL` to infer from the other parameters.
#' @param gamma,sigma Exactly one may be non-`NULL`; the other is derived.
#' @param call Environment of the function the user called.
#' @return A list with elements `ndim`, `theta`, `mu`, `gamma`, `sigma`.
#' @noRd
validate_model_args <- function(ndim, theta, mu, gamma, sigma, call) {
  if (is.null(ndim)) {
    ndim <- infer_ndim(
      theta = theta, mu = mu, gamma = gamma, sigma = sigma, call = call
    )
  }
  check_positive_whole(ndim, "ndim", call = call)
  ndim <- as.integer(ndim)

  # Set defaults for parameters if NULL
  if (is.null(theta)) theta <- diag(0.5, ndim)
  if (is.null(mu)) mu <- rep(0, ndim)
  if (is.null(gamma) && is.null(sigma)) gamma <- diag(1, ndim)

  theta <- coerce_to_matrix(theta, ndim, "theta", call = call)
  mu <- coerce_to_vector(mu, ndim, "mu", call = call)

  # Handle gamma/sigma: infer one from the other
  if (!is.null(gamma)) {
    gamma <- coerce_to_matrix(gamma, ndim, "gamma", call = call)
    if (!is_lower_triangular(gamma)) {
      cli::cli_abort(
        c(
          "{.arg gamma} must be a lower triangular matrix.",
          "i" = paste(
            "Supply {.arg sigma} (the noise covariance matrix) instead to have",
            "{.arg gamma} derived from it?"
          )
        ),
        call = call,
        class = "affectOU_error_gamma_not_lower_triangular"
      )
    }
    # Sigma derived this way is symmetric and positive semi-definite by
    # construction, so it needs no further checking.
    sigma <- gamma %*% t(gamma)
  } else {
    sigma <- coerce_to_matrix(sigma, ndim, "sigma", call = call)
    check_sigma_values(sigma, ndim, call = call)
    gamma <- compute_gamma_from_sigma(sigma, ndim)
  }

  list(ndim = ndim, theta = theta, mu = mu, gamma = gamma, sigma = sigma)
}


#' Infer ndim from parameters
#'
#' Tracks which parameter implied which dimension, so a conflict can name the
#' two parameters that disagree.
#'
#' @noRd
infer_ndim <- function(theta = NULL, mu = NULL, gamma = NULL,
                       sigma = NULL, call = rlang::caller_env()) {
  # Collect dimensions from all non-NULL parameters
  dims <- c()

  if (!is.null(theta)) dims <- c(dims, theta = NROW(theta))
  if (!is.null(mu)) dims <- c(dims, mu = length(mu))
  if (!is.null(gamma)) dims <- c(dims, gamma = NROW(gamma))
  if (!is.null(sigma)) dims <- c(dims, sigma = NROW(sigma))

  if (length(dims) == 0) {
    return(1L)
  }

  dims <- dims[dims > 1]
  unique_dims <- unique(unname(dims))

  if (length(unique_dims) == 0) {
    return(1L)
  }
  if (length(unique_dims) == 1) {
    return(as.integer(unique_dims))
  }

  # Name the first two parameters that disagree, in argument order.
  first <- names(dims)[[1]]
  second <- names(dims)[dims != dims[[1]]][[1]]

  cli::cli_abort(
    c(
      "Model parameters must all describe the same number of affect dimensions.",
      "x" = paste0(
        "{.arg ", first, "} implies {dims[[first]]} dimensions and ",
        "{.arg ", second, "} implies {dims[[second]]}."
      ),
      "i" = "Set {.arg ndim} explicitly to choose one?"
    ),
    call = call,
    class = "affectOU_error_inconsistent_ndim"
  )
}


#' Coerce input to matrix of correct dimension
#'
#' Accepts a single number (expanded to a diagonal matrix), a vector of length
#' `ndim` (the diagonal), or an `ndim` x `ndim` matrix.
#'
#' @noRd
coerce_to_matrix <- function(x, ndim, name, call = rlang::caller_env(),
                             bullet = ndim_bullet(ndim)) {
  forms <- matrix_forms(ndim)

  if (!is.numeric(x)) {
    rlang::stop_input_type(x, forms, arg = name, call = call)
  }

  check_all_finite(x, name, call = call)

  # A single number, including a 1x1 matrix, becomes a diagonal matrix
  if (length(x) == 1) {
    return(diag(as.numeric(x), ndim))
  }

  # Vector of length ndim -> diagonal matrix
  if (is.vector(x) && length(x) == ndim) {
    return(diag(as.numeric(x), ndim))
  }

  if (is.matrix(x) && all(dim(x) == ndim)) {
    return(x)
  }

  cli::cli_abort(
    c(
      paste0(
        "{.arg {name}} must be ",
        if (is.matrix(x)) paste0("a ", ndim, "x", ndim, " matrix") else forms,
        ", not {obj_shape_friendly(x)}."
      ),
      bullet
    ),
    call = call,
    class = "affectOU_error_wrong_shape"
  )
}


#' Coerce input to vector of correct length
#'
#' Accepts a single number (recycled) or a vector of length `ndim`.
#'
#' @noRd
coerce_to_vector <- function(x, ndim, name, call = rlang::caller_env(),
                             bullet = ndim_bullet(ndim)) {
  forms <- vector_forms(ndim)

  if (!is.numeric(x)) {
    rlang::stop_input_type(x, forms, arg = name, call = call)
  }

  check_all_finite(x, name, call = call)

  # Scalar -> repeat
  if (length(x) == 1) {
    return(rep(as.numeric(x), ndim))
  }

  if (length(x) == ndim && !is.matrix(x)) {
    return(as.numeric(x))
  }

  cli::cli_abort(
    c(
      "{.arg {name}} must be {forms}, not {obj_shape_friendly(x)}.",
      bullet
    ),
    call = call,
    class = "affectOU_error_wrong_shape"
  )
}


#' Compute gamma from sigma via Cholesky decomposition
#'
#' Assumes `sigma` has already been checked by `check_sigma_values()`.
#'
#' @noRd
compute_gamma_from_sigma <- function(sigma, ndim) {
  if (ndim == 1) {
    if (sigma[1, 1] == 0) {
      return(matrix(0, nrow = 1, ncol = 1))
    }

    # gamma is the square root of sigma (standard deviation; the Cholesky factor)
    return(sqrt(sigma))
  }

  if (all(sigma == 0)) {
    return(matrix(0, nrow = ndim, ncol = ndim))
  }

  cholesky_psd(sigma)
}


#' Lower-triangular factor for positive semi-definite matrices
#'
#' A pure numeric routine. Its positive semi-definiteness precondition is the
#' caller's to check, so a failure here is a package bug, not a user error.
#'
#' @noRd
cholesky_psd <- function(sigma, tol = 1e-10, call = rlang::caller_env()) {
  n <- nrow(sigma)
  L <- matrix(0, nrow = n, ncol = n)

  for (j in seq_len(n)) {
    previous <- if (j > 1L) seq_len(j - 1L) else integer(0)
    previous_sum <- if (length(previous) > 0L) sum(L[j, previous]^2) else 0
    diag_value <- sigma[j, j] - previous_sum

    if (diag_value < -tol) {
      abort_not_psd(call)
    }

    if (diag_value <= tol) {
      L[j, j] <- 0

      if (j < n) {
        for (i in seq.int(j + 1L, n)) {
          previous_cross <- if (length(previous) > 0L) {
            sum(L[i, previous] * L[j, previous])
          } else {
            0
          }
          off_value <- sigma[i, j] - previous_cross
          if (abs(off_value) > sqrt(tol)) {
            abort_not_psd(call)
          }
        }
      }
    } else {
      L[j, j] <- sqrt(diag_value)

      if (j < n) {
        for (i in seq.int(j + 1L, n)) {
          previous_cross <- if (length(previous) > 0L) {
            sum(L[i, previous] * L[j, previous])
          } else {
            0
          }
          L[i, j] <- (sigma[i, j] - previous_cross) / L[j, j]
        }
      }
    }
  }

  L[abs(L) < tol] <- 0
  L
}


#' @noRd
abort_not_psd <- function(call) {
  cli::cli_abort(
    "Matrix must be positive semi-definite.",
    call = call,
    .internal = TRUE
  )
}


#' Check if a matrix is lower triangular
#' @noRd
is_lower_triangular <- function(x, tol = sqrt(.Machine$double.eps)) {
  if (nrow(x) <= 1L) {
    return(TRUE)
  }
  upper_idx <- upper.tri(x)
  all(abs(x[upper_idx]) <= tol)
}


#' Check sigma is a valid noise covariance matrix
#'
#' @param call Environment of the function the user called.
#' @noRd
check_sigma_values <- function(sigma, ndim, tol = 1e-10,
                               call = rlang::caller_env()) {
  if (!isTRUE(isSymmetric(sigma, tol = tol))) {
    cli::cli_abort(
      c(
        "{.arg sigma} must be a symmetric matrix.",
        "i" = paste(
          "{.arg sigma} is a covariance matrix: the covariance between two",
          "affect dimensions is the same in either direction."
        )
      ),
      call = call,
      class = "affectOU_error_sigma_not_symmetric"
    )
  }

  sigma_sym <- (sigma + t(sigma)) / 2
  eig <- eigen(sigma_sym, symmetric = TRUE, only.values = TRUE)$values

  if (!any(eig < -tol)) {
    return(invisible(NULL))
  }

  if (ndim == 1) {
    cli::cli_abort(
      c(
        paste(
          "{.arg sigma} must be a number larger than or equal to 0,",
          "not the number {sigma[1, 1]}."
        ),
        "i" = paste(
          "{.arg sigma} is the variance of the random fluctuation driving",
          "affect, so it cannot be negative."
        )
      ),
      call = call,
      class = "affectOU_error_sigma_not_psd"
    )
  }

  cli::cli_abort(
    c(
      "{.arg sigma} must be positive semi-definite.",
      "x" = "Its smallest eigenvalue is {signif(min(eig), 2)}.",
      "i" = paste(
        "{.arg sigma} is the covariance matrix of the random fluctuation",
        "driving affect; a negative eigenvalue would give some combination of",
        "affect dimensions a negative variance."
      )
    ),
    call = call,
    class = "affectOU_error_sigma_not_psd"
  )
}
