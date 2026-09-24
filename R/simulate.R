#' Simulate from Ornstein-Uhlenbeck process
#'
#' Generates a trajectory from the Ornstein-Uhlenbeck process using
#' Euler-Maruyama discretization. Handles both univariate and multivariate models.
#'
#' @param object An `affectOU` model object.
#' @param nsim How many independent trajectories to simulate. A whole number of
#'   at least 1.
#' @param seed The random seed, so a simulation can be reproduced. A whole
#'   number, or `NULL` to leave the random state alone.
#' @param initial The affect value each trajectory starts from. A single
#'   number, or a vector with one element per dimension. If `NULL`, defaults
#'   to a draw from the stationary distribution (for stable systems) or the
#'   attractor location `mu` (for non-stable systems).
#' @param dt The time step the simulation advances by, for the Euler-Maruyama
#'   discretization (smaller = more accurate). Must be larger than 0.
#' @param stop How long the simulated period lasts, in time units. Must be
#'   larger than 0.
#' @param save_at The time interval at which simulated data is saved, in time units; used to
#'   linearly interpolate results. Useful for reducing output size. Must be at
#'   least `dt`, because states are only computed every `dt` time units, and at
#'   most `stop`, or nothing would be recorded.
#' @param ... Additional arguments (unused).
#'
#' @importFrom stats simulate
#' @return A model object of class [`simulate_affectOU`][simulate.affectOU()] containing:
#' \describe{
#'   \item{model}{The original `affectOU` model object used for simulation.}
#'   \item{data}{A 3D array with dimensions (time x ndim x nsim) containing the simulated trajectories.}
#'   \item{times}{A vector of time points corresponding to the rows of the `data` array.}
#'  \item{nsim}{The number of simulations performed.}
#'  \item{dt}{The time step used for the Euler-Maruyama discretization.}
#'  \item{stop}{The total simulation time.}
#'  \item{save_at}{The time interval at which simulated data was saved.}
#'  \item{seed}{The random seed used for simulation (if any).}
#' }
#'
#' @export
#' @concept simulate
#' @examples
#' model <- affectOU(ndim = 2)
#' sim <- simulate(model, nsim = 2)
#' plot(sim)
#' summary(sim)
#' head(sim)
#'
#' # Specify initial state
#' sim <- simulate(model, initial = c(1, -1))
#' plot(sim)
#'
#' # Simulate for a longer time with coarser saving interval
#' sim <- simulate(model, stop = 500, save_at = 10)
#' plot(sim)
#'
simulate.affectOU <- function(object,
                              nsim = 1,
                              seed = NULL,
                              initial = NULL,
                              dt = 0.01,
                              stop = 100,
                              save_at = dt,
                              ...) {
  # --- Input validation ---
  # Every argument is checked here, at the boundary, before any work is done.

  call <- rlang::current_env()

  check_model_class(object, "affectOU", "an <affectOU> model", "object", call = call)

  check_positive_number(dt, "dt", call = call)
  check_positive_number(stop, "stop", call = call)
  check_positive_number(save_at, "save_at", call = call)

  if (save_at > stop) {
    cli::cli_abort(
      c(
        "{.arg save_at} must be less than or equal to {.arg stop}.",
        "x" = "{.arg save_at} is {save_at} and {.arg stop} is {stop}.",
        "i" = "Otherwise no time points are saved."
      ),
      call = call,
      class = "affectOU_error_save_at_above_stop"
    )
  }

  if (save_at < dt) {
    cli::cli_abort(
      c(
        "{.arg save_at} must be greater than or equal to {.arg dt}.",
        "x" = "{.arg save_at} is {save_at} and {.arg dt} is {dt}.",
        "i" = paste(
          "States are only computed every {.arg dt} time units, so they cannot",
          "be recorded more often than that."
        )
      ),
      call = call,
      class = "affectOU_error_save_at_below_dt"
    )
  }

  check_positive_whole(nsim, "nsim", call = call)

  if (!is.null(seed)) {
    rlang::check_number_whole(seed, arg = "seed", call = call)
  }

  if (!is.null(initial)) {
    initial <- coerce_to_vector(
      initial, object[["ndim"]], "initial",
      call = call,
      bullet = gloss_bullet("initial")
    )
  }

  # Set seed for reproducibility
  if (!is.null(seed)) {
    # https://stat.ethz.ch/pipermail/r-package-devel/2022q3/008447.html
    genv <- globalenv()

    # Make sure to leave '.Random.seed' as-is on exit
    old_seed <- genv$.Random.seed
    on.exit(suspendInterrupts({
      if (is.null(old_seed)) {
        rm(".Random.seed", envir = genv, inherits = FALSE)
      } else {
        assign(".Random.seed",
          value = old_seed,
          envir = genv, inherits = FALSE
        )
      }
    }))
    set.seed(seed)
  }

  # Extract parameters
  ndim <- object[["ndim"]]
  theta <- object[["parameters"]][["theta"]]
  mu <- object[["parameters"]][["mu"]]
  gamma <- object[["parameters"]][["gamma"]]

  # Ensure parameters are in correct format
  if (ndim == 1) {
    theta <- as.numeric(theta)
    gamma <- as.numeric(gamma)
  }

  # Determine how to draw initial state for each simulation
  stat <- object[["stationary"]]
  if (is.null(initial)) {
    if (!stat[["is_stable"]]) {
      cli::cli_warn(c(
        "!" = "The system is not stable, so no stationary distribution exists.",
        "i" = "{.arg initial} defaults to {.arg mu}."
      ))
      x0_fixed <- mu
      draw_x0 <- function() x0_fixed
    } else if (ndim == 1) {
      if (stat[["sd"]] == 0) {
        x0_fixed <- stat[["mean"]]
        draw_x0 <- function() x0_fixed
      } else {
        draw_x0 <- function() stats::rnorm(1, mean = stat[["mean"]], sd = stat[["sd"]])
      }
    } else {
      if (all(stat[["sd"]] == 0)) {
        x0_fixed <- stat[["mean"]]
        draw_x0 <- function() x0_fixed
      } else {
        L <- cholesky_psd(stat[["cov"]])
        draw_x0 <- function() stat[["mean"]] + L %*% stats::rnorm(ndim)
      }
    }
  } else {
    draw_x0 <- function() initial
  }

  # Time vectors
  times <- seq(0, stop, by = dt)
  if (tail(times, 1L) < stop) {
    times <- c(times, stop)
  }
  times_output <- seq(0, stop, by = save_at)
  if (tail(times_output, 1L) < stop) {
    times_output <- c(times_output, stop)
  }
  dt_steps <- diff(times)
  n_steps <- length(dt_steps)

  # Pre-allocate 3D array: time x ndim x nsim
  simulations <- array(NA_real_, dim = c(n_steps + 1, ndim, nsim))

  # Run simulations
  for (sim_idx in seq_len(nsim)) {
    # Initialize trajectory
    x <- matrix(0, nrow = n_steps + 1, ncol = ndim)
    x[1, ] <- draw_x0()

    # Pre-compute noise for efficiency
    if (ndim == 1) {
      dW <- sqrt(dt_steps) * stats::rnorm(n_steps)
    } else {
      dW <- sweep(matrix(stats::rnorm(n_steps * ndim),
        nrow = n_steps,
        ncol = ndim,
        byrow = TRUE
      ), 1, sqrt(dt_steps), `*`)
    }

    if (ndim == 1) {
      # Univariate case (scalar operations)
      for (i in seq_len(n_steps)) {
        drift <- theta * (mu - x[i, 1]) * dt_steps[i]
        diffusion <- gamma * dW[i]
        x[i + 1, 1] <- x[i, 1] + drift + diffusion
      }
    } else {
      # Multivariate case (matrix operations)
      for (i in seq_len(n_steps)) {
        drift <- theta %*% (mu - x[i, ]) * dt_steps[i]
        diffusion <- gamma %*% dW[i, ]
        x[i + 1, ] <- x[i, ] + drift + diffusion
      }
    }

    simulations[, , sim_idx] <- x
  }

  # Linearly interpolate to save_at times if needed
  if (!isTRUE(all.equal(save_at, dt))) {
    simulations_interp <- array(NA_real_, dim = c(length(times_output), ndim, nsim))

    for (sim_idx in seq_len(nsim)) {
      for (dim_idx in seq_len(ndim)) {
        simulations_interp[, dim_idx, sim_idx] <- stats::approx(
          x = times,
          y = simulations[, dim_idx, sim_idx],
          xout = times_output
        )$y
      }
    }

    simulations <- simulations_interp
    times <- times_output
  }

  # Create output object
  out <- new_simulate_affectOU(
    model = object,
    data = simulations,
    times = times,
    nsim = nsim,
    dt = dt,
    stop = stop,
    save_at = save_at,
    seed = seed
  )

  validate_simulate_affectOU(out, call = call)

  out
}

#' Create simulate_affectOU object
#'
#' Internal function to create a simulate_affectOU object.
#' @keywords internal
#' @noRd
new_simulate_affectOU <- function(model, data, times, nsim, dt, stop, save_at, seed) {
  structure(
    list(
      model = model,
      data = data,
      times = times,
      nsim = nsim,
      dt = dt,
      stop = stop,
      save_at = save_at,
      seed = seed
    ),
    class = "simulate_affectOU"
  )
}


#' Validate simulate_affectOU object
#'
#' Internal function to validate the structure and contents of a simulate_affectOU object.
#' @keywords internal
#' @noRd
validate_simulate_affectOU <- function(x, call = rlang::caller_env()) {
  if (!inherits(x, "simulate_affectOU")) {
    cli::cli_abort(
      "Object must be of class {.cls simulate_affectOU}.",
      call = call, .internal = TRUE
    )
  }

  # Check required components
  required_components <- c("model", "data", "times", "nsim", "dt", "stop", "save_at", "seed")
  missing_components <- setdiff(required_components, names(x))
  if (length(missing_components) > 0) {
    cli::cli_abort(
      "Missing components in {.cls simulate_affectOU} object: {paste(missing_components, collapse = ', ')}.",
      call = call, .internal = TRUE
    )
  }

  # Check components types
  if (!inherits(x[["model"]], "affectOU")) {
    cli::cli_abort(
      "Component {.var model} must be of class {.cls affectOU}.",
      call = call, .internal = TRUE
    )
  }
  if (!is.array(x[["data"]]) || length(dim(x[["data"]])) != 3) {
    cli::cli_abort(
      "Component {.var data} must be a 3-dimensional array.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x[["times"]]) || !is.vector(x[["times"]])) {
    cli::cli_abort(
      "Component {.var times} must be a numeric vector.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x[["nsim"]]) || length(x[["nsim"]]) != 1 || x[["nsim"]] <= 0 || x[["nsim"]] != floor(x[["nsim"]])) {
    cli::cli_abort(
      "Component {.var nsim} must be a whole number larger than 0.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x[["dt"]]) || length(x[["dt"]]) != 1 || x[["dt"]] <= 0) {
    cli::cli_abort(
      "Component {.var dt} must be a single number larger than 0.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x[["stop"]]) || length(x[["stop"]]) != 1 || x[["stop"]] <= 0) {
    cli::cli_abort(
      "Component {.var stop} must be a single number larger than 0.",
      call = call, .internal = TRUE
    )
  }
  if (!is.numeric(x[["save_at"]]) || length(x[["save_at"]]) != 1 || x[["save_at"]] <= 0) {
    cli::cli_abort(
      "Component {.var save_at} must be a single number larger than 0.",
      call = call, .internal = TRUE
    )
  }
  if (!is.null(x[["seed"]]) && (!is.numeric(x[["seed"]]) || length(x[["seed"]]) != 1 || x[["seed"]] != floor(x[["seed"]]))) {
    cli::cli_abort(
      "Component {.var seed} must be a single integer value or NULL.",
      call = call, .internal = TRUE
    )
  }

  # Check data dimensions
  ndim <- x[["model"]][["ndim"]]
  data_dims <- dim(x[["data"]])
  if (data_dims[1] != length(x[["times"]])) {
    cli::cli_abort(
      "First dimension of {.var data} must match length of {.var times}.",
      call = call, .internal = TRUE
    )
  }
  if (data_dims[2] != ndim) {
    cli::cli_abort(
      "Second dimension of {.var data} must match model {.var ndim}.",
      call = call, .internal = TRUE
    )
  }
  if (data_dims[3] != x[["nsim"]]) {
    cli::cli_abort(
      "Third dimension of {.var data} must match {.var nsim}.",
      call = call, .internal = TRUE
    )
  }

  invisible(x)
}


#' Head of simulation results
#'
#' Returns the first `n` time points from a `simulate_affectOU` object.
#'
#' @param x A `simulate_affectOU` simulation object
#' @param n Number of time points to keep from the start (default 6)
#' @param ... Additional arguments passed to `utils::head()`
#' @return A simulation data.frame truncated to the first `n` time points.
#' @export
#' @concept simulate
#' @importFrom utils head
#' @examples
#' model <- affectOU()
#' sim <- simulate(model)
#' head(sim)
head.simulate_affectOU <- function(x, n = 6L, ...) {
  call <- rlang::current_env()
  check_model_class(
    x, "simulate_affectOU", "a simulation from {.fun simulate}", "x",
    call = call
  )
  check_positive_whole(n, "n", call = call)
  n <- as.integer(n)

  head(as.data.frame(x), n = n, ...)
}

#' Tail of simulation results
#'
#' Returns the last `n` time points from a `simulate_affectOU` object.
#'
#' @param x A `simulate_affectOU` simulation object
#' @param n Number of time points to keep from the end (default 6)
#' @param ... Additional arguments passed to `utils::tail()`
#' @return A simulation data.frame truncated to the last `n` time points.
#' @export
#' @concept simulate
#' @importFrom utils tail
#' @examples
#' model <- affectOU()
#' sim <- simulate(model)
#' tail(sim)
tail.simulate_affectOU <- function(x, n = 6L, ...) {
  call <- rlang::current_env()
  check_model_class(
    x, "simulate_affectOU", "a simulation from {.fun simulate}", "x",
    call = call
  )
  check_positive_whole(n, "n", call = call)
  n <- as.integer(n)

  tail(as.data.frame(x), n = n, ...)
}

#' Convert simulation results to list
#'
#' Returns the simulation data as a list with one data frame per simulation.
#'
#' @param x A `simulate_affectOU` object
#' @param direction Character string specifying the output format: `"wide"` (default)
#'   returns one column per dimension, `"long"` returns a single value column
#'   with a dimension indicator.
#' @param ... Additional arguments (unused)
#'
#' @return A list of data frames, one per simulation. Each data frame contains:
#'   \describe{
#'     \item{time}{Time points}
#'     \item{dim1, dim2, ...}{(wide format) Values for each dimension}
#'     \item{dim}{(long format) Dimension indicator}
#'     \item{value}{(long format) Simulated values}
#'   }
#' @export
#' @concept simulate
#' @method as.list simulate_affectOU
#'
#' @examples
#' model <- affectOU(ndim = 2)
#' sim <- simulate(model, nsim = 3)
#'
#' # Wide format (default): one column per dimension
#' lst_wide <- as.list(sim)
#' head(lst_wide[[1]])
#'
#' # Long format: single value column with dimension indicator
#' lst_long <- as.list(sim, direction = "long")
#' head(lst_long[[1]])
as.list.simulate_affectOU <- function(x, direction = c("wide", "long"), ...) {
  direction <- match.arg(direction)

  data <- x[["data"]]
  times <- x[["times"]]
  ndim <- x[["model"]][["ndim"]]
  nsim <- x[["nsim"]]

  dim_names <- paste0("dim", seq_len(ndim))

  result <- lapply(seq_len(nsim), function(i) {
    sim_data <- data[, , i, drop = FALSE]

    if (direction == "wide") {
      df <- data.frame(
        time = times,
        as.data.frame(matrix(sim_data, ncol = ndim))
      )
      names(df) <- c("time", dim_names)
    } else {
      df <- data.frame(
        time = rep(times, ndim),
        dim = factor(rep(dim_names, each = length(times)), levels = dim_names),
        value = as.vector(sim_data)
      )
    }

    df
  })

  names(result) <- paste0("sim", seq_len(nsim))
  result
}

#' Convert simulation results to array
#'
#' Returns the raw simulation data as a 3-dimensional array with
#' dimensions (time × ndim × nsim).
#'
#' @param x A `simulate_affectOU` object
#' @param ... Additional arguments (unused)
#'
#' @return A 3-dimensional array with dimensions:
#'   \describe{
#'     \item{time}{Time points (named by time values)}
#'     \item{dim}{Dimension index}
#'     \item{sim}{Simulation index}
#'   }
#' @export
#' @concept simulate
#' @method as.array simulate_affectOU
#'
#' @examples
#' model <- affectOU(ndim = 2)
#' sim <- simulate(model, nsim = 3)
#' arr <- as.array(sim)
#' dim(arr)
#'
#' # Access first time point across all dimensions and simulations:
#' arr[1, , ]
as.array.simulate_affectOU <- function(x, ...) {
  data <- x[["data"]]
  times <- x[["times"]]
  ndim <- x[["model"]][["ndim"]]
  nsim <- x[["nsim"]]

  dimnames(data) <- list(
    time = times,
    dim = paste0("dim", seq_len(ndim)),
    sim = paste0("sim", seq_len(nsim))
  )

  data
}


#' Convert simulation results to matrix
#'
#' Returns the simulation data as a 2-dimensional matrix in either long or
#' wide format.
#'
#' @param x A `simulate_affectOU` object
#' @param direction Character, either `"long"` (default) or `"wide"`.
#'   Long format has one row per observation with columns for
#'   time, dim, sim, and value. Wide format has time as rows and
#'   dimension-simulation combinations as columns.
#' @param ... Additional arguments (unused)
#'
#' @return For `direction = "long"`, a matrix with columns
#'   `time`, `dim`, `sim`, `value`. For `direction = "wide"`, a matrix with dimensions
#'   (ntime x ndim*nsim). Columns iterate over dimensions first, then
#'   simulations. Column names are `dim1`, `dim2`, ... when `nsim = 1`, or
#'   `dim1.sim1`, `dim2.sim1`, ..., `dim1.sim2`, ... when `nsim > 1`.
#' @export
#' @concept simulate
#' @method as.matrix simulate_affectOU
#'
#' @examples
#' model <- affectOU(ndim = 2)
#' sim <- simulate(model, nsim = 3)
#'
#' # Long format (default)
#' mat_long <- as.matrix(sim)
#' head(mat_long)
#'
#' # Wide format
#' mat_wide <- as.matrix(sim, direction = "wide")
#' head(mat_wide)
as.matrix.simulate_affectOU <- function(x, direction = c("long", "wide"), ...) {
  direction <- match.arg(direction)

  data <- x[["data"]]
  times <- x[["times"]]
  ndim <- x[["model"]][["ndim"]]
  nsim <- x[["nsim"]]
  ntime <- length(times)

  if (direction == "long") {
    mat <- cbind(
      time = rep(times, times = ndim * nsim),
      dim = rep(seq_len(ndim), each = ntime, times = nsim),
      sim = rep(seq_len(nsim), each = ntime * ndim),
      value = as.vector(data)
    )
  } else {
    mat <- matrix(data, nrow = ntime, ncol = ndim * nsim)

    if (nsim == 1) {
      colnames(mat) <- paste0("dim", seq_len(ndim))
    } else {
      colnames(mat) <- paste0(
        "dim", rep(seq_len(ndim), nsim),
        ".sim", rep(seq_len(nsim), each = ndim)
      )
    }

    rownames(mat) <- times
  }

  mat
}


#' Convert simulation results to data frame
#'
#' Converts an `simulate_affectOU` object to a data frame in either long or
#' wide format.
#'
#' @param x A `simulate_affectOU` object
#' @param row.names NULL or a character vector giving the row names for the
#'   data frame. Missing values are not allowed.
#' @param optional Logical. If TRUE, setting row names and converting column
#'   names is optional. Included for compatibility with the generic.
#' @param direction Character, either `"long"` (default) or `"wide"`.
#'   Long format has one row per time-dimension-simulation combination.
#'   Wide format has one row per time point with dimensions and simulations
#'   spread across columns.
#' @param ... Additional arguments (unused)
#'
#' @return For `direction = "long"`, a data frame with columns:
#'   \describe{
#'     \item{time}{Observation time}
#'     \item{dim}{Dimension index}
#'     \item{sim}{Simulation index}
#'     \item{value}{Simulated value}
#'   }
#'   For `direction = "wide"`, a data frame with `time` as the first column
#'   and subsequent columns named `dim{d}` when `nsim = 1`, or
#'   `dim{d}.sim{s}` when `nsim > 1`.
#' @export
#' @concept simulate
#' @method as.data.frame simulate_affectOU
#'
#' @examples
#' model <- affectOU(ndim = 2)
#' sim <- simulate(model, nsim = 3)
#'
#' # Long format (default) - one row per timepoint, dimension, and simulation
#' df_long <- as.data.frame(sim)
#' head(df_long)
#'
#' # Wide format - one row per time point
#' df_wide <- as.data.frame(sim, direction = "wide")
#' head(df_wide)
as.data.frame.simulate_affectOU <- function(x, row.names = NULL, optional = FALSE,
                                            direction = c("long", "wide"), ...) {
  direction <- match.arg(direction)

  if (direction == "wide") {
    mat <- as.matrix(x, direction = direction)
    df <- data.frame(
      time = x[["times"]],
      mat,
      row.names = row.names,
      check.names = !optional
    )
  } else {
    data <- x[["data"]]
    times <- x[["times"]]
    ndim <- x[["model"]][["ndim"]]
    nsim <- x[["nsim"]]
    ntime <- length(times)

    # as.vector() iterates: time (fastest), dim, sim (slowest)
    df <- data.frame(
      time = rep(times, times = ndim * nsim),
      dim = rep(seq_len(ndim), each = ntime, times = nsim),
      sim = rep(seq_len(nsim), each = ntime * ndim),
      value = as.vector(data),
      row.names = row.names,
      check.names = !optional
    )
  }

  df
}


#' Print simulation object
#'
#' Display overview of an `simulate_affectOU` object without printing
#' the full data array.
#'
#' @param x A `simulate_affectOU` object
#' @param digits Number of digits for numeric display
#' @param ... Additional arguments (unused)
#' @export
#' @concept simulate
#' @method print simulate_affectOU
print.simulate_affectOU <- function(x, digits = 3, ...) {
  ndim <- x[["model"]][["ndim"]]
  nsim <- x[["nsim"]]
  dt <- x[["dt"]]
  save_at <- x[["save_at"]]
  stop <- x[["stop"]]
  seed <- x[["seed"]]

  cli::cli_h1(sprintf(
    "%dD Ornstein-Uhlenbeck Simulation%s", ndim,
    ifelse(nsim == 1, "", paste0(" (", nsim, " replications)"))
  ))
  cli::cli_text(sprintf(
    "Time: 0 \u2192 %.*f; dt: %.*f; save_at: %.*f",
    digits, stop, digits, dt, digits, save_at
  ))
  if (!is.null(seed)) {
    cli::cli_text(sprintf("Seed: %d", as.integer(seed)))
  }

  # Preview: head of simulation as data frame with digits applied
  df_head <- utils::head(as.data.frame(x), n = 6L)
  num_cols <- vapply(df_head, is.numeric, logical(1))
  df_head[num_cols] <- lapply(df_head[num_cols], function(col) round(col, digits))

  cli::cli_text("")
  cli::cli_verbatim(paste(utils::capture.output(df_head), collapse = "\n"))

  invisible(x)
}


#' Summarize simulation results
#'
#' Computes summary statistics of simulated data, pooled across all
#' simulations. Optionally compares to theoretical stationary distribution
#' when the model is stationary.
#'
#' @param object A `simulate_affectOU` object
#' @param discard_initial_time How much of the start to discard, so the
#'   process has settled before it is summarised. Measured in time units,
#'   like `stop`, and must be less than the simulated period, or no time points
#'   would remain. Default is 0 to retain all time points.
#' @param ... Additional arguments (unused)
#'
#' @return An object of class `summary_simulate_affectOU` containing:
#'   \describe{
#'     \item{ndim}{Number of dimensions}
#'     \item{nsim}{Number of simulations}
#'     \item{n_timepoints}{Number of time points used after discarding}
#'     \item{discard_initial_time}{Amount of time discarded from the start}
#'     \item{dt}{Simulation time step}
#'     \item{stop}{Total simulation time}
#'     \item{save_at}{Time interval at which data was saved}
#'     \item{seed}{Random seed used (or NULL)}
#'     \item{statistics}{List with summary statistics of simulated data:
#'       \describe{
#'         \item{mean}{Mean for each dimension}
#'         \item{sd}{Standard deviation for each dimension}
#'         \item{cov}{Covariance matrix (NULL for 1D)}
#'         \item{cor}{Correlation matrix (NULL for 1D)}
#'       }
#'     }
#'     \item{theoretical}{List with theoretical stationary quantities (NULL if
#'       model is not stationary):
#'       \describe{
#'         \item{mean}{Stationary mean for each dimension}
#'         \item{sd}{Stationary standard deviation for each dimension}
#'         \item{cov}{Stationary covariance matrix (NULL for 1D)}
#'         \item{cor}{Stationary correlation matrix (NULL for 1D)}
#'       }
#'     }
#'   }
#'
#' @export
#' @concept simulate
#' @method summary simulate_affectOU
#'
#' @examples
#' # 1D stationary model
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, stop = 100, dt = 0.1, nsim = 10, seed = 123)
#' summary(sim)
#'
#' # Discard the initial transient before summarising
#' summary(sim, discard_initial_time = 10)
#'
#' # 2D stationary model
#' model <- affectOU(ndim = 2, theta = diag(c(0.5, 0.3)), mu = c(1, -1))
#' sim <- simulate(model, stop = 100, dt = 0.1, nsim = 5, seed = 456)
#' summary(sim, discard_initial_time = 20)
summary.simulate_affectOU <- function(object, discard_initial_time = 0, ...) {
  # Validate arguments
  call <- rlang::current_env()
  check_model_class(
    object, "simulate_affectOU", "a simulation from {.fun simulate}", "object",
    call = call
  )
  rlang::check_number_decimal(
    discard_initial_time,
    min = 0, arg = "discard_initial_time", call = call
  )

  stop_time <- object[["stop"]]
  if (discard_initial_time >= stop_time) {
    cli::cli_abort(
      c(
        "{.arg discard_initial_time} must be less than the simulated period.",
        "x" = paste(
          "{.arg discard_initial_time} is {discard_initial_time} and the simulation",
          "stops at {stop_time}."
        ),
        "i" = "No time points would remain to summarise."
      ),
      call = call,
      class = "affectOU_error_discard_above_stop"
    )
  }

  # Extract data and metadata
  data <- object[["data"]]
  times <- object[["times"]]
  ndim <- object[["model"]][["ndim"]]
  nsim <- object[["nsim"]]

  # Discard the start, so only the settled part is summarised
  keep_idx <- times >= discard_initial_time
  data_filtered <- data[keep_idx, , , drop = FALSE]
  n_timepoints <- sum(keep_idx)

  # Compute per-dimension statistics pooled across simulations.
  data_pooled <- matrix(aperm(data_filtered, c(1, 3, 2)), ncol = ndim)

  sim_mean <- colMeans(data_pooled)
  sim_sd <- apply(data_pooled, 2, stats::sd)

  if (ndim > 1) {
    sim_cov <- stats::cov(data_pooled)
    if (all(sim_sd > 0)) {
      sim_cor <- stats::cor(data_pooled)
    } else {
      sim_cor <- diag(ndim)
      nonzero <- which(sim_sd > 0)
      if (length(nonzero) > 1) {
        sim_cor[nonzero, nonzero] <- stats::cor(data_pooled[, nonzero])
      }
    }
  } else {
    sim_cov <- NULL
    sim_cor <- NULL
  }

  # Get theoretical quantities from model summary
  model_summary <- summary(object[["model"]])
  stat <- model_summary[["stationary"]]

  if (stat[["is_stable"]]) {
    theoretical <- list(
      mean = stat[["mean"]],
      sd = stat[["sd"]],
      cov = stat[["cov"]],
      cor = stat[["cor"]]
    )
  } else {
    theoretical <- NULL
  }

  # Build output object (flat structure)
  out <- list(
    ndim = ndim,
    nsim = nsim,
    n_timepoints = n_timepoints,
    discard_initial_time = discard_initial_time,
    dt = object[["dt"]],
    stop = stop_time,
    save_at = object[["save_at"]],
    seed = object[["seed"]],
    statistics = list(
      mean = sim_mean,
      sd = sim_sd,
      cov = sim_cov,
      cor = sim_cor
    ),
    theoretical = theoretical
  )

  class(out) <- "summary_simulate_affectOU"
  out
}


#' Print summary of simulation results
#'
#' @param x An object of class `summary_simulate_affectOU`
#' @param digits Number of digits for numeric display
#' @param max_dim Maximum number of dimensions to display full details for.
#'   For higher dimensions, only summary information is shown.
#' @param ... Additional arguments (unused)
#' @return Invisibly returns the input object `x` after printing the summary.
#'
#' @export
#' @concept simulate
#' @method print summary_simulate_affectOU
#' @examples
#' model <- affectOU(theta = 0.5, mu = 0, gamma = 1)
#' sim <- simulate(model, nsim = 3)
#' print(summary(sim))
print.summary_simulate_affectOU <- function(x, digits = 3, max_dim = 10, ...) {
  ndim <- x[["ndim"]]
  nsim <- x[["nsim"]]

  # Header
  cli::cli_h1(sprintf(
    "%dD Ornstein-Uhlenbeck Simulation Summary%s",
    ndim,
    if (nsim == 1) "" else sprintf(" (%d replications)", nsim)
  ))

  # --- Simulation settings ---
  cli::cli_h2("Simulation settings")

  time_range <- if (x[["discard_initial_time"]] > 0) {
    sprintf(
      "%.*f \u2192 %.*f (first %.*f discarded)",
      digits, x[["discard_initial_time"]], digits, x[["stop"]], digits, x[["discard_initial_time"]]
    )
  } else {
    sprintf("0 \u2192 %.*f", digits, x[["stop"]])
  }

  cli::cli_text(paste0("Time: ", time_range))
  cli::cli_text("Time points: {x$n_timepoints}; dt: {round(x$dt, digits)}; save_at: {round(x$save_at, digits)}")

  if (!is.null(x[["seed"]])) {
    cli::cli_text("Seed: {x$seed}")
  }

  stats <- x[["statistics"]]
  theo <- x[["theoretical"]]
  is_stationary <- !is.null(theo)

  # --- High-dimensional case: show abbreviated output ---
  if (ndim > max_dim) {
    cli::cli_h2("Statistics")
    cli::cli_alert_info(
      "High-dimensional model ({ndim}D). Full statistics not shown."
    )
    cli::cli_text("Access statistics via {.code $statistics}.")

    if (!is_stationary) {
      cli::cli_text("")
      cli::cli_alert_info("Model is not stationary; theoretical comparison not available.")
    }

    return(invisible(x))
  }

  # --- Statistics display depends on stationarity ---
  if (!is_stationary) {
    # Non-stationary: show statistics only
    cli::cli_h2("Simulated statistics")

    if (ndim == 1) {
      cli::cli_text("Mean: {round(stats$mean, digits)}")
      cli::cli_text("SD: {round(stats$sd, digits)}")
    } else {
      cli::cli_text("Mean: [{paste(round(stats$mean, digits), collapse = ', ')}]")
      cli::cli_text("SD: [{paste(round(stats$sd, digits), collapse = ', ')}]")
      cli::cli_text("")
      cli::cli_text("Covariance:")
      cli::cli_verbatim(format_matrix_plain(round(stats$cov, digits)))
      cli::cli_text("")
      cli::cli_text("Correlation:")
      cli::cli_verbatim(format_matrix_plain(round(stats$cor, digits)))
    }

    cli::cli_text("")
    cli::cli_alert_info("Model is not stationary; theoretical comparison not available.")
  } else {
    # Stationary: show comparison to theoretical
    cli::cli_h2("Comparison to theoretical distribution")

    if (ndim == 1) {
      # Simple table for 1D
      comparison <- data.frame(
        Simulated = c(round(stats$mean, digits), round(stats$sd, digits)),
        Theoretical = c(round(theo$mean, digits), round(theo$sd, digits)),
        row.names = c("Mean", "SD")
      )
      cli::cli_verbatim(paste(utils::capture.output(comparison), collapse = "\n"))
    } else {
      # Comparison table for mean and sd
      comparison_mean <- rbind(
        Simulated = round(stats$mean, digits),
        Theoretical = round(theo$mean, digits)
      )
      colnames(comparison_mean) <- paste0("dim", seq_len(ndim))

      comparison_sd <- rbind(
        Simulated = round(stats$sd, digits),
        Theoretical = round(theo$sd, digits)
      )
      colnames(comparison_sd) <- paste0("dim", seq_len(ndim))

      cli::cli_text("Mean:")
      cli::cli_verbatim(format_matrix_plain(comparison_mean))
      cli::cli_text("")
      cli::cli_text("SD:")
      cli::cli_verbatim(format_matrix_plain(comparison_sd))
      cli::cli_text("")

      # Covariance comparison
      cli::cli_text("Covariance (simulated):")
      cli::cli_verbatim(format_matrix_plain(round(stats$cov, digits)))
      cli::cli_text("")
      cli::cli_text("Covariance (theoretical):")
      cli::cli_verbatim(format_matrix_plain(round(theo$cov, digits)))
      cli::cli_text("")

      # Correlation comparison
      cli::cli_text("Correlation (simulated):")
      cli::cli_verbatim(format_matrix_plain(round(stats$cor, digits)))
      cli::cli_text("")
      cli::cli_text("Correlation (theoretical):")
      cli::cli_verbatim(format_matrix_plain(round(theo$cor, digits)))
    }
  }

  invisible(x)
}
