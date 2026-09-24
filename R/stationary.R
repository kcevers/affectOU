#' Compute stationary distribution
#'
#' Generic function to compute the stationary (long-run equilibrium)
#' distribution of a model. The stationary distribution describes
#' where the process spends its time after transient effects have died out.
#'
#' @param object A model object
#' @param ... Additional arguments
#' @export
#' @concept theory
stationary <- function(object, ...) {
  UseMethod("stationary")
}


#' Compute stationary distribution for Ornstein-Uhlenbeck model
#'
#' Compute the stationary (long-run equilibrium) distribution of the
#' Ornstein-Uhlenbeck process, including its mean, standard deviation,
#' and (for multivariate models) the full covariance and correlation
#' structure.
#'
#' A stationary distribution exists only when the system is stable
#' (see [`stability()`][stability.affectOU()]). For non-stable systems,
#' the function returns `is_stable = FALSE` with `NULL` distribution
#' properties.
#'
#' @inheritParams simulate.affectOU
#'
#' @section Stationary distribution:
#' When \eqn{\theta > 0} (1D) or all eigenvalues of \eqn{\Theta} have positive
#' real parts (multivariate), the process converges to a stationary
#' distribution:
#' \deqn{X_\infty \sim N\!\left(\mu,\; \frac{\gamma^2}{2\theta}\right)}
#' The stationary variance \eqn{\gamma^2/(2\theta)} depends on both
#' \eqn{\gamma} and \eqn{\theta}. Different parameter combinations can produce
#' the same long-run spread but very different dynamics (see examples).
#'
#' @section Stationary covariance (multivariate):
#' For multivariate models, the stationary covariance matrix
#' \eqn{\Sigma_\infty} solves the Lyapunov equation:
#' \deqn{\Theta \Sigma_\infty + \Sigma_\infty \Theta^\top = \Gamma \Gamma^T}
#'
#' Off-diagonal elements in \eqn{\Theta} (coupling between dimensions) can induce
#' correlation at equilibrium even when the noise is independent.
#'
#' @section Formula reference:
#' Key theoretical quantities for the 1D case:
#' \tabular{lll}{
#'   \strong{Quantity}          \tab \strong{Formula}                                      \tab \strong{Interpretation}           \cr
#'   Stationary mean            \tab \eqn{\mu}                                             \tab Long-run center                  \cr
#'   Stationary variance        \tab \eqn{\gamma^2 / (2\theta)}                            \tab Long-run spread                  \cr
#'   Half-life                  \tab \eqn{\log(2) / \theta}                                \tab Persistence of perturbations     \cr
#'   ACF at lag \eqn{\tau}      \tab \eqn{e^{-\theta\tau}}                                 \tab Predictability over time          \cr
#'   Conditional mean           \tab \eqn{\mu + (x - \mu) e^{-\theta \Delta t}}            \tab Expected next value given current
#' }
#' Stationary properties depend on both \eqn{\gamma} and \eqn{\theta};
#' temporal dynamics depend mainly on \eqn{\theta}. Two processes can share
#' stationary distributions but differ in dynamics, or vice versa.
#'
#' @return A list of class [`stationary_affectOU`][stationary.affectOU()] containing:
#'   \describe{
#'     \item{is_stable}{Logical, `TRUE` if a stationary distribution exists}
#'     \item{mean}{Stationary (long-run) mean, or `NULL` if non-stable}
#'     \item{sd}{Stationary standard deviations, or `NULL` if non-stable}
#'     \item{cov}{Stationary covariance matrix (`NULL` for 1D or
#'       non-stable)}
#'     \item{cor}{Stationary correlation matrix (`NULL` for 1D or
#'       non-stable)}
#'     \item{ndim}{Dimensionality of the process}
#'   }
#'
#' @seealso [`stability()`][stability.affectOU()] for stability assessment,
#'   [`summary()`][summary.affectOU()] for the full model summary.
#'
#' @export
#' @concept theory
#' @examples
#' # 1D model
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' stationary(model)
#'
#' # All components
#' unclass(stationary(model))
#'
#' # Different dynamics, same stationary distribution
#' model_slow <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' model_fast <- affectOU(theta = 2.0, mu = 0, gamma = 2)
#' stationary(model_slow)$sd
#' stationary(model_fast)$sd
#'
#' # Non-stable model
#' model_rw <- affectOU(theta = 0)
#' stationary(model_rw)
#'
#' # 2D: coupling induces stationary correlation
#' theta_2d <- matrix(c(0.5, 0.0, 0.3, 0.5), nrow = 2, byrow = TRUE)
#' model_2d <- affectOU(ndim = 2, theta = theta_2d, mu = 0, gamma = 1)
#' stationary(model_2d)$cor # non-zero off-diagonal
#'
stationary.affectOU <- function(object, ...) {
  out <- object[["stationary"]]
  class(out) <- "stationary_affectOU"
  out
}


#' Print stationary distribution
#'
#' @param x A `stationary_affectOU` object from [`stationary()`][stationary.affectOU()]
#' @param digits Number of digits to display
#' @param ... Additional arguments (unused)
#'
#' @return Returns `x` invisibly.
#' @export
#' @concept theory
#' @method print stationary_affectOU
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' print(stationary(model))
print.stationary_affectOU <- function(x, digits = 3, ...) {
  ndim <- x$ndim

  cli::cli_h2("Stationary distribution of {ndim}D Ornstein-Uhlenbeck Model")

  if (!x$is_stable) {
    cli::cli_text("Does not exist (system is not stable).")
    return(invisible(x))
  }


  if (ndim == 1) {
    cli::cli_text("Mean: {round(x$mean, digits)}")
    cli::cli_text("SD: {round(x$sd, digits)}")
    cli::cli_text("95% interval: [{round(x$mean - 2 * x$sd, digits)}, {round(x$mean + 2 * x$sd, digits)}]")
  } else {
    cli::cli_text("Mean: [{paste(round(x$mean, digits), collapse = ', ')}]")
    cli::cli_text("SD: [{paste(round(x$sd, digits), collapse = ', ')}]")

    cli::cli_text("")
    cli::cli_text("95% intervals:")
    cli::cli_ul()
    for (i in seq_len(ndim)) {
      lo <- round(x$mean[i] - 2 * x$sd[i], digits)
      hi <- round(x$mean[i] + 2 * x$sd[i], digits)
      cli::cli_li("Dim. {i}: [{lo}, {hi}]")
    }
    cli::cli_end()

    if (!is.null(x$cor)) {
      # Report off-diagonal correlations
      cor_mat <- x$cor
      upper <- which(upper.tri(cor_mat) & abs(cor_mat) > 0, arr.ind = TRUE)
      if (nrow(upper) > 0) {
        cli::cli_text("")
        cli::cli_text("Stationary correlations:")
        cli::cli_ul()
        for (k in seq_len(nrow(upper))) {
          i <- upper[k, 1]
          j <- upper[k, 2]
          cli::cli_li("Dims {i} & {j}: {round(cor_mat[i, j], digits)}")
        }
        cli::cli_end()
      }
    }
  }

  invisible(x)
}
