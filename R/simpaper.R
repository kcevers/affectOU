#' Simulation in Evers & Vanhasbroeck (2026)
#'
#' An uncoupled two-dimensional Ornstein-Uhlenbeck process simulated with `affectOU`.
#'
#' The process is defined by the stochastic differential equation:
#' \deqn{d\mathbf{X}_t = \mathbf{\Theta}(\mathbf{\mu} - \mathbf{X}_t)dt + \mathbf{\Gamma}d\mathbf{W}_t}
#'
#' where:
#' \itemize{
#'   \item \eqn{\mathbf{\Theta} = \begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix}} is the drift matrix
#'   \item \eqn{\mathbf{\mu} = \begin{pmatrix} 0 \\ 0 \end{pmatrix}} is the equilibrium mean vector
#'   \item \eqn{\mathbf{\Gamma} = \begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix}} is the diffusion matrix
#'   \item \eqn{\mathbf{W}_t} is a two-dimensional Wiener process
#' }
#' @concept simulate
#' @format An object of class [`simulate_affectOU`][simulate.affectOU()] containing simulated trajectories from the specified Ornstein-Uhlenbeck process.
"simpaper"
