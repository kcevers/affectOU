#' Assess stability
#'
#' Generic function to assess the stability of a dynamical system. Stability
#' determines whether the system converges to an equilibrium or diverges,
#' and what type of dynamics it exhibits.
#'
#' @param object A model object
#' @param ... Additional arguments
#' @export
#' @concept theory
stability <- function(object, ...) {
  UseMethod("stability")
}


#' Assess stability for Ornstein-Uhlenbeck model
#'
#' Classify the dynamics and stability of an Ornstein-Uhlenbeck model
#' based on eigenvalue analysis of the drift matrix \eqn{\Theta}.
#'
#' Note that although typically, a system is stable if all its eigenvalues have
#' negative real parts, due to the parameterization of the OU process, stability
#' is determined by *positive* real parts:
#'
#' \deqn{dX(t) = \Theta(\mu - X(t))dt + \Gamma dW(t)}
#'
#' As \eqn{\Theta} is multiplied by the negative of the state variable, positive
#' eigenvalues indicate that deviations from the attractor decay over time,
#' leading to a stable system. Conversely, negative eigenvalues indicate that
#' deviations grow over time, leading to an unstable system.
#'
#'
#' @inheritParams simulate.affectOU
#' @param tol Tolerance for comparing eigenvalues to zero.
#'
#' @section Stability via eigenvalues:
#' A stationary distribution exists if and only if all eigenvalues of
#' \eqn{\Theta} have positive real parts. This is a system-level
#' property, not a per-dimension property:
#'
#' \enumerate{
#'   \item Positive diagonal elements (\eqn{\Theta_{ii} > 0}) alone do
#'     not guarantee stability. Strong off-diagonal coupling can push
#'     eigenvalues toward zero or negative real parts, destabilising the system.
#'   \item Conversely, coupling from other dimensions can stabilise a dimension
#'     whose diagonal element is small or even zero. A dimension that would be
#'     non-stationary in isolation may become stationary when embedded in a
#'     coupled system.
#' }
#'
#' @section Oscillatory dynamics:
#' Complex eigenvalues (arising from asymmetric coupling) produce oscillatory
#' dynamics, where dimensions cycle around each other. When all eigenvalues
#' have positive real parts, these oscillations are damped and the system still
#' converges to \eqn{\mu}. When any eigenvalue has a non-positive real part,
#' the oscillations grow and the system diverges.
#'
#' @section Terminology:
#' System-level dynamics are classified using dynamical systems terms: a
#' node converges or diverges without oscillation, a spiral exhibits
#' damped or growing oscillations, and a saddle point has mixed
#' convergence/divergence across directions. Per-dimension dynamics describe
#' the behavior of each dimension in isolation based on its diagonal element
#' in \eqn{\Theta} ("stable node" if positive, "random walk" if zero,
#' "unstable node" if negative). A dimension classified as "stable node" in
#' isolation may still belong to an unstable coupled system due to
#' coupling between dimensions.
#'
#' @return A list of class [`stability_affectOU`][stability.affectOU()] containing:
#'   \describe{
#'     \item{is_stable}{Logical, `TRUE` if the system is stable (all
#'       eigenvalues have positive real parts)}
#'     \item{dynamics}{Character string describing the dynamics type using
#'       dynamical systems terminology. For 1D: `"stable node"`,
#'       `"random walk"`, or `"unstable node"`. For multivariate:
#'       `"stable node"`, `"stable spiral"`, `"unstable node"`,
#'       `"unstable spiral"`, `"marginally stable"`, `"saddle point"`,
#'       or `"saddle spiral"`.}
#'     \item{per_dimension}{Character vector with per-dimension dynamics
#'       classification (`NULL` for 1D)}
#'     \item{eigenvalues}{Eigenvalues of theta}
#'     \item{ndim}{Dimensionality of the process}
#'   }
#'
#' @seealso [`stationary()`][stationary.affectOU()] for the equilibrium
#'   distribution, [`summary()`][summary.affectOU()] for the full model summary.
#'
#' @export
#' @concept theory
#' @examples
#' # 1D stable node
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' stability(model)
#'
#' # 1D random walk (not stable)
#' model_rw <- affectOU(theta = 0)
#' stability(model_rw)
#'
#' # Positive diagonals with oscillatory coupling: stable
#' theta_osc <- matrix(c(0.5, -0.4, 0.4, 0.5), nrow = 2)
#' stability(affectOU(theta = theta_osc, mu = 0, gamma = 1))
#'
#' # Strong coupling still stable if real parts stay positive
#' theta_strong <- matrix(c(0.5, -1.5, 1.5, 0.5), nrow = 2)
#' stability(affectOU(theta = theta_strong, mu = 0, gamma = 1))
#'
#' # All diagonals positive, but coupling destabilises the system
#' theta_destab <- matrix(c(0.5, 1.0, 1.0, 0.5), nrow = 2)
#' stability(affectOU(theta = theta_destab, mu = 0, gamma = 1))
#'
#' # One negative diagonal element makes the system non-stationary
#' theta_unstable <- matrix(c(0.5, 0, 0, -0.3), nrow = 2)
#' stability(affectOU(theta = theta_unstable, mu = 0, gamma = 1))
#'
stability.affectOU <- function(object, tol = 1e-10, ...) {
  ndim <- object[["ndim"]]
  theta <- object[["parameters"]][["theta"]]

  # Eigenvalues of theta
  eigenvalues <- get_eigenvalues(theta)

  # Classify dynamics
  dynamics_result <- classify_dynamics(theta, eigenvalues, ndim, tol = tol)

  # Check stability (all eigenvalues have positive real parts)
  is_stable <- check_stability(theta, tol = tol)$is_stable

  # Build output
  if (ndim == 1) {
    out <- list(
      is_stable = is_stable,
      dynamics = dynamics_result,
      per_dimension = NULL,
      eigenvalues = eigenvalues,
      ndim = ndim
    )
  } else {
    out <- list(
      is_stable = is_stable,
      dynamics = dynamics_result$system,
      per_dimension = dynamics_result$per_dimension,
      eigenvalues = eigenvalues,
      ndim = ndim
    )
  }

  class(out) <- "stability_affectOU"
  out
}


#' Print stability analysis
#'
#' @param x A `stability_affectOU` object from [`stability()`][stability.affectOU()]
#'
#' @param digits Number of digits to display
#' @param ... Additional arguments (unused)
#'
#' @return Returns `x` invisibly.
#' @export
#' @concept theory
#' @method print stability_affectOU
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' print(stability(model))
print.stability_affectOU <- function(x, digits = 3, ...) {
  ndim <- x$ndim

  cli::cli_h2("Stability analysis of {ndim}D Ornstein-Uhlenbeck Model")

  dynamics_explanation <- function(dynamics) {
    switch(dynamics,
      "stable node" = "Deviations from the attractor decay exponentially.",
      "random walk" = "No attractor; the process drifts freely.",
      "unstable node" = "Deviations from the attractor grow exponentially.",
      "stable spiral" = "The system spirals toward the attractor with damped oscillations.",
      "unstable spiral" = "The system spirals away from the attractor with growing oscillations.",
      "marginally stable" = "The system neither converges nor diverges.",
      "saddle point" = "Some directions converge while others diverge.",
      "saddle spiral" = "Mixed convergence and divergence with oscillatory dynamics.",
      NULL
    )
  }

  # Strip "stable "/"unstable " prefix to get geometry qualifier
  dynamics_qualifier <- function(dynamics) {
    switch(dynamics,
      "stable node" = ,
      "unstable node" = "node",
      "stable spiral" = ,
      "unstable spiral" = "spiral",
      dynamics
    )
  }

  stable_label <- if (x$is_stable) "Stable" else "Not stable"
  qualifier <- dynamics_qualifier(x$dynamics)
  explanation <- dynamics_explanation(x$dynamics)

  if (!is.null(explanation)) {
    cli::cli_text("{stable_label} ({qualifier}). {explanation}")
  } else {
    cli::cli_text("{stable_label} ({qualifier}).")
  }

  # Per-dimension dynamics for multivariate (only if they differ)
  if (ndim > 1 && length(unique(x$per_dimension)) > 1) {
    cli::cli_text("")
    cli::cli_ul()
    for (i in seq_len(ndim)) {
      cli::cli_li("Dim. {i}: {x$per_dimension[i]}")
    }
    cli::cli_end()
  }

  # Eigenvalues
  format_eigenvalue <- function(ev, digits) {
    re <- round(Re(ev), digits)
    im <- round(Im(ev), digits)
    if (im == 0) {
      as.character(re)
    } else if (im > 0) {
      paste0(re, " + ", im, "i")
    } else {
      paste0(re, " - ", abs(im), "i")
    }
  }

  has_complex <- any(abs(Im(x$eigenvalues)) > .Machine$double.eps^0.5)
  ev_note <- if (has_complex) "complex" else "all real"

  cli::cli_text("")
  cli::cli_text("Eigenvalues ({ev_note}):")
  cli::cli_ul()
  for (k in seq_along(x$eigenvalues)) {
    cli::cli_li("\u03bb{k}: {format_eigenvalue(x$eigenvalues[k], digits)}")
  }
  cli::cli_end()

  invisible(x)
}


#' Classify dynamics type based on theta (1D case)
#'
#' For a single dimension, classifies the dynamics as "stable node",
#' "random walk", or "unstable node" based on the value of theta compared to a numerical
#' tolerance.
#'
#' @param theta_val The value of theta for the dimension
#' @param tol Tolerance for comparing theta to zero
#' @return A character string indicating the dynamics type
#' @keywords internal
classify_single <- function(theta_val, tol) {
  if (theta_val > tol) {
    "stable node"
  } else if (abs(theta_val) < tol) {
    "random walk"
  } else {
    "unstable node"
  }
}

#' Classify dynamics type based on theta
#'
#' For 1D models, returns a single character string.
#' For multivariate models, returns a character vector with one entry per dimension,
#' based on the diagonal elements of theta. Also includes an overall system-level
#' classification based on eigenvalues.
#'
#' @param theta Drift matrix
#' @param eigenvalues Pre-computed eigenvalues of theta
#' @param ndim Dimensionality
#' @param tol Tolerance for comparing values to zero (default 1e-10)
#'
#' @return For 1D: a character string. For multivariate: a list with
#'   `per_dimension` (character vector) and `system` (character string).
#' @noRd
classify_dynamics <- function(theta, eigenvalues, ndim, tol = 1e-10) {
  if (ndim == 1) {
    return(classify_single(theta[1, 1], tol))
  }

  # Multivariate: per-dimension classification based on diagonal
  per_dim <- vapply(diag(theta), classify_single, character(1), tol = tol)

  # System-level classification based on eigenvalues
  real_parts <- Re(eigenvalues)
  has_complex <- any(abs(Im(eigenvalues)) > tol)

  all_positive <- all(real_parts > tol)
  all_negative <- all(real_parts < -tol)
  all_zero <- all(abs(real_parts) < tol)

  if (all_positive) {
    system <- if (has_complex) "stable spiral" else "stable node"
  } else if (all_zero) {
    system <- "marginally stable"
  } else if (all_negative) {
    system <- if (has_complex) "unstable spiral" else "unstable node"
  } else {
    system <- if (has_complex) "saddle spiral" else "saddle point"
  }

  list(
    per_dimension = per_dim,
    system = system
  )
}
