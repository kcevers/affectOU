#' Check eigenvalue stability of drift matrix
#' @inheritParams affectOU
#' @inheritParams stability.affectOU
#' @noRd
check_stability <- function(theta, tol = 1e-10) {
  eigenvalues <- get_eigenvalues(theta)
  is_stable <- all(Re(eigenvalues) > tol)

  list(
    eigenvalues = eigenvalues,
    is_stable = is_stable
  )
}

#' Get eigenvalues of drift matrix
#' @inheritParams affectOU
#' @noRd
get_eigenvalues <- function(theta) {
  eig <- eigen(theta, symmetric = FALSE, only.values = TRUE)
  eig$values
}


#' Solve Lyapunov equation for stationary covariance
#'
#' @inheritParams affectOU
#'
#' @return Stationary covariance matrix (i.e., `sigma_inf`)
#' @noRd
#'
solve_lyapunov <- function(theta, sigma) {
  n <- nrow(theta)
  I <- diag(n)
  A <- kronecker(I, theta) + kronecker(theta, I)
  sigma_inf <- matrix(solve(A, as.vector(sigma)), n, n)

  # Verify solution
  residual <- max(abs(theta %*% sigma_inf + sigma_inf %*% t(theta) - sigma))
  if (residual > 1e-10) {
    cli::cli_warn(c(
      "!" = "The stationary covariance may be inaccurate.",
      "x" = "The Lyapunov solution has residual {signif(residual, 1)}.",
      "i" = "This usually means {.arg theta} is close to non-stationary."
    ))
  }

  sigma_inf
}
