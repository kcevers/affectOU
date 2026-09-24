#' Get plot defaults, merging base defaults with function-specific defaults
#'
#' @param specific Named list of function-specific defaults
#' @param user Named list of user-supplied arguments (from ...)
#' @return Merged parameter list
#' @keywords internal
get_plot_params <- function(specific = list(), user = list()) {
  # Start with base, override with specific, override with user
  plot_defaults_base <- list(
    # Layout
    xlim = NULL,
    ylim = NULL,
    nrow = NULL,
    ncol = NULL,
    # bottom, left, top, right
    # oma = outer margins (for outer labels), mar = inner margins (for axes)
    oma = c(2.25, 2, 3, 2),
    mar = c(3, 3.1, 2.25, 3),
    # mgp = distance of the axis labels or titles from the axes; distance of the tick mark labels from the axes; distance of the tick mark symbols from the axes
    mgp = c(2, 0.5, 0),
    # Text sizing
    cex.main = 2,
    cex.lab = 1.5,
    cex.axis = 0.95,
    cex.sub = 1.5,

    # Style
    las = 0,
    xaxs = "r",
    yaxs = "r",
    tcl = -0.3,
    family = "serif",
    font = 1,
    col.axis = "#7f8c8d",
    col.grid = "gray90"
  )

  P <- utils::modifyList(plot_defaults_base, specific)
  utils::modifyList(P, user)
}


#' Prepare simulation object for plotting
#'
#' @param sim Simulation object
#' @inheritParams plot_time
#' @param max_ndim Maximum number of dimensions allowed
#' @param max_nsim Maximum number of simulations allowed
#'
#' @return Modified simulation object
#' @noRd
prep_sim <- function(sim, which_dim, which_sim,
                     max_ndim = NULL, max_nsim = NULL,
                     call = rlang::caller_env()) {
  check_model_class(
    sim, "simulate_affectOU", "a simulation from {.fun simulate}", "x",
    call = call
  )

  # Unpack sim object
  data <- sim[["data"]]
  times <- sim[["times"]]
  mu <- sim[["model"]][["parameters"]][["mu"]]
  theta <- sim[["model"]][["parameters"]][["theta"]]
  gamma <- sim[["model"]][["parameters"]][["gamma"]]
  sigma <- sim[["model"]][["parameters"]][["sigma"]]
  ndim <- sim[["model"]][["ndim"]]
  nsim <- sim[["nsim"]]

  # Handle dimension selection
  if (!is.numeric(which_dim)) {
    rlang::stop_input_type(
      which_dim, "a numeric vector of dimension indices",
      arg = "which_dim", call = call
    )
  }

  if (any(which_dim < 1) || any(which_dim > ndim)) {
    bad <- which_dim[which_dim < 1 | which_dim > ndim][[1]]
    cli::cli_abort(
      "{.arg which_dim} must contain values between 1 and {ndim}, not {bad}.",
      call = call,
      class = "affectOU_error_which_dim_out_of_range"
    )
  }

  if (!is.null(max_ndim) && length(which_dim) > max_ndim) {
    cli::cli_abort(
      paste0(
        "{.arg which_dim} must select at most {max_ndim} dimension{?s}, ",
        "not {length(which_dim)}."
      ),
      call = call,
      class = "affectOU_error_too_many_dims"
    )
  }

  data <- data[, which_dim, , drop = FALSE]
  mu <- mu[which_dim]
  if (ndim > 1) {
    theta <- theta[which_dim, which_dim, drop = FALSE]
    gamma <- gamma[which_dim, which_dim, drop = FALSE]
    sigma <- sigma[which_dim, which_dim, drop = FALSE]
    ndim <- length(which_dim)
  }

  # Handle simulation selection
  if (!is.numeric(which_sim)) {
    rlang::stop_input_type(
      which_sim, "a numeric vector of simulation indices",
      arg = "which_sim", call = call
    )
  }

  # Sort and deduplicate (so max_nsim reflects distinct sims)
  which_sim <- sort(unique(which_sim))

  if (any(which_sim < 1) || any(which_sim > nsim)) {
    bad <- which_sim[which_sim < 1 | which_sim > nsim][[1]]
    cli::cli_abort(
      "{.arg which_sim} must contain values between 1 and {nsim}, not {bad}.",
      call = call,
      class = "affectOU_error_which_sim_out_of_range"
    )
  }

  if (!is.null(max_nsim) && length(which_sim) > max_nsim) {
    cli::cli_abort(
      paste0(
        "{.arg which_sim} must select at most {max_nsim} simulation{?s}, ",
        "not {length(which_sim)}."
      ),
      call = call,
      class = "affectOU_error_too_many_sims"
    )
  }

  data <- data[, , which_sim, drop = FALSE]
  nsim <- length(which_sim)

  # Overwrite sim object
  sim[["data"]] <- data
  sim[["times"]] <- times
  sim[["model"]][["parameters"]][["mu"]] <- mu
  sim[["model"]][["parameters"]][["theta"]] <- theta
  sim[["model"]][["parameters"]][["gamma"]] <- gamma
  sim[["model"]][["parameters"]][["sigma"]] <- sigma
  sim[["model"]][["ndim"]] <- ndim
  sim[["nsim"]] <- nsim

  sim
}

#' Apply graphical parameters that are valid for par()
#'
#' @param P Parameter list from get_plot_params()
#' @return Previous par settings (invisibly)
#' @keywords internal
apply_par <- function(P) {
  par_params <- filter_args(P, get_valid_args(par))
  do.call(par, par_params)
}

#' Filter a list of arguments
#'
#' @param args Named list of arguments
#' @param valid_args Character vector of valid argument names
#' @return Filtered named list
#' @keywords internal
filter_args <- function(args, valid_args) {
  args[names(args) %in% valid_args]
}

#' Get valid argument names for a function
#'
#' @param fun Function or function name
#' @param include_par Logical; include graphical parameters from par()?
#' @return Character vector of valid argument names
#' @keywords internal
#'
get_valid_args <- function(fun, include_par = TRUE) {
  if (is.character(fun)) fun <- match.fun(fun)
  args <- names(formals(fun))

  if ("..." %in% args && include_par) {
    args <- c(args, names(par(no.readonly = TRUE)))
  }

  unique(setdiff(args, "..."))
}

#' Calculate layout dimensions for multi-panel plots
#'
#' @param n Number of panels needed
#' @param P Parameter list containing nrow, ncol, mfrow, or mfcol
#' @param user_args Original user arguments (to check for mfrow/mfcol)
#' @inheritParams plot_parameters
#'
#' @return List with nrow and ncol
#' @keywords internal
get_layout <- function(n, P, user_args = list(), by_dim = TRUE,
                       call = rlang::caller_env()) {
  if (!by_dim) {
    nrow <- 1
    ncol <- 1
    return(list(nrow = nrow, ncol = ncol))
  } else if ("mfrow" %in% names(user_args)) {
    nrow <- user_args[["mfrow"]][1]
    ncol <- user_args[["mfrow"]][2]
  } else if ("mfcol" %in% names(user_args)) {
    nrow <- user_args[["mfcol"]][1]
    ncol <- user_args[["mfcol"]][2]
  } else if (!is.null(P[["nrow"]]) && !is.null(P[["ncol"]])) {
    nrow <- P[["nrow"]]
    ncol <- P[["ncol"]]
  } else if (!is.null(P[["nrow"]])) {
    nrow <- P[["nrow"]]
    ncol <- ceiling(n / nrow)
  } else if (!is.null(P[["ncol"]])) {
    ncol <- P[["ncol"]]
    nrow <- ceiling(n / ncol)
  } else {
    ncol <- ceiling(sqrt(n))
    nrow <- ceiling(n / ncol)
  }

  if (nrow * ncol < n) {
    cli::cli_abort(
      c(
        "{.arg layout} must provide at least {n} panel{?s}.",
        "x" = "A {nrow} x {ncol} layout provides {nrow * ncol}."
      ),
      call = call,
      class = "affectOU_error_layout_too_small"
    )
  }

  list(nrow = nrow, ncol = ncol)
}

#' Set up axes for a plot panel
#'
#' @param xlim X-axis limits
#' @param ylim Y-axis limits
#' @param P Parameter list
#' @param main Main title (NULL to suppress)
#' @param xlab X-axis label (NULL to suppress)
#' @param ylab Y-axis label (NULL to suppress)
#' @return None (invisible)
#'
#' @keywords internal
setup_panel <- function(xlim, ylim, P, main = NULL, xlab = NULL, ylab = NULL) {
  plot.new()
  plot.window(xlim = xlim, ylim = ylim)
  axis(1)
  axis(2)
  grid(col = P[["col.grid"]], lty = 1)

  if (!is.null(main)) {
    title(
      main = main, cex.main = par("cex.sub"),
      font.main = 1
    )
  }
  if (!is.null(xlab)) {
    title(xlab = xlab, cex.lab = par("cex.lab"))
  }
  if (!is.null(ylab)) {
    title(ylab = ylab, cex.lab = par("cex.lab"))
  }
  invisible(NULL)
}


#' Add outer labels to a multi-panel plot
#'
#' @param P Parameter list
#' @param main Main title
#' @param xlab X-axis label
#' @param ylab Y-axis label
#' @keywords internal
add_outer_labels <- function(P, main = NULL, xlab = NULL, ylab = NULL) {
  # Use base graphics mtext with outer margins for robust placement
  # Assumes outer margins (oma) are set via apply_par(P)
  if (!is.null(main)) {
    mtext(
      text = main, side = 3, outer = TRUE, line = 0.7,
      cex = par("cex.main")
    )
  }
  if (!is.null(xlab)) {
    mtext(
      text = xlab, side = 1, outer = TRUE, line = 0.7,
      cex = par("cex.lab")
    )
  }
  if (!is.null(ylab)) {
    mtext(
      text = ylab, side = 2, outer = TRUE, line = 0.7,
      cex = par("cex.lab")
    )
  }
  invisible(NULL)
}

#' Add legend inside a specific panel
#'
#' @param position Legend position within the panel (e.g., "topright")
#' @param xlim X-axis limits for the target panel
#' @param ylim Y-axis limits for the target panel
#' @param panel_row Panel row index (1-based)
#' @param panel_col Panel column index (1-based)
#' @param inset Inset distance from margins as fraction of plot region
#' @param bg Background colour for the legend box
#' @param ... Additional arguments passed to \code{\link[graphics]{legend}}
#' @keywords internal
add_panel_legend <- function(position = "topright",
                             xlim, ylim,
                             panel_row = 1, panel_col = 1,
                             inset = c(0.02, 0.02), bg = "white", ...) {
  # "none" hides the legend
  if (identical(position, "none")) {
    return(invisible(NULL))
  }

  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par), add = TRUE)

  # Switch to requested panel without clearing its contents
  par(mfg = c(panel_row, panel_col))
  par(xpd = NA)

  par(usr = c(xlim[1], xlim[2], ylim[1], ylim[2]))

  legend(position, inset = inset, bg = bg, ...)
}

#' Calculate axis limits for multiple panels
#'
#' @param data Data array
#' @param ndim Number of dimensions
#' @param nsim Number of simulations
#' @param lim User-supplied lim (NULL, vector, or list)
#' @param share_axis Logical; share axis across panels?
#' @return List of lim vectors
#' @keywords internal
get_lims <- function(data, ndim, nsim, lim = NULL,
                     share_axis = FALSE, include = NULL,
                     call = rlang::caller_env()) {
  # If user provided lim, use it (replicated if single vector)
  if (!is.null(lim)) {
    if (is.list(lim)) {
      if (length(lim) != ndim) {
        cli::cli_abort(
          c(
            "{.arg lim} must have one element per dimension.",
            "x" = "{.arg lim} has {length(lim)} element{?s} and the model has {ndim} dimension{?s}."
          ),
          call = call,
          class = "affectOU_error_lim_length"
        )
      }

      res <- lim
    } else {
      res <- replicate(ndim, lim, simplify = FALSE)
    }
    return(check_lims(res))
  }

  # If share_axis, compute global limits across all data (and include if provided)
  if (share_axis) {
    if (is.list(data)) {
      base_vals <- unlist(data)
    } else {
      base_vals <- as.vector(data)
    }
    # Merge include values into global computation
    if (!is.null(include)) {
      if (is.list(include)) {
        base_vals <- c(base_vals, unlist(include))
      } else {
        base_vals <- c(base_vals, include)
      }
    }
    global_lim <- range(base_vals, na.rm = TRUE)
    res <- replicate(ndim, global_lim, simplify = FALSE)
    return(check_lims(res))
  }


  # Compute limits separately for each dimension (and include if provided)
  if (is.list(data)) {
    res <- lapply(data, range, na.rm = TRUE)
  } else {
    res <- lapply(seq_len(ndim), function(d) {
      range(data[, d, ], na.rm = TRUE)
    })
  }

  # Incorporate include values per panel if provided
  if (!is.null(include)) {
    if (is.list(include) && length(include) == length(res)) {
      res <- lapply(seq_along(res), function(i) {
        range(c(res[[i]], include[[i]]), na.rm = TRUE)
      })
    } else {
      # Single vector/value applied to all panels
      res <- lapply(res, function(r) range(c(r, include), na.rm = TRUE))
    }
  }

  check_lims(res)
}


#' Check that limits are finite and non-degenerate, replacing if necessary
#'
#' @param lims List of limit vectors
#' @return List of checked limit vectors
#' @keywords internal
#' @noRd
check_lims <- function(lims) {
  # Before returning res, ensure all limits are finite and non-degenerate
  lapply(lims, function(r) {
    if (!all(is.finite(r))) r <- c(-1, 1)
    if (r[1] == r[2]) r <- r + c(-0.5, 0.5)
    r
  })
}

#' Generate shades of a colour
#'
#' @param color Base colour
#' @param n Number of shades
#' @param min_alpha Minimum alpha (transparency)
#' @param max_alpha Maximum alpha (transparency)
#'
#' @return Character vector of colours
#' @keywords internal
generate_shades <- function(color, n, min_alpha = 0.3, max_alpha = 1) {
  alpha_seq <- seq(min_alpha, max_alpha, length.out = n)
  vapply(alpha_seq, function(a) {
    grDevices::adjustcolor(color, alpha.f = a)
  }, FUN.VALUE = character(1))
}

#' Assign line types to simulations in contiguous groups
#'
#' Divides \code{nsim} simulations into up to \code{n_lty} equal-sized
#' contiguous blocks and returns a vector of line-type indices (integers 1 to
#' \code{n_lty}) of length \code{nsim}. When \code{nsim <= n_lty} each
#' simulation gets its own unique line type.
#'
#' @param nsim  Number of simulations.
#' @param n_lty Number of distinct line types available (default 5).
#' @return Integer vector of length \code{nsim}.
#' @keywords internal
assign_sim_lty <- function(nsim, n_lty = 5L) {
  if (nsim <= n_lty) {
    return(seq_len(nsim))
  }
  group_size <- ceiling(nsim / n_lty)
  pmin(ceiling(seq_len(nsim) / group_size), n_lty)
}

#' Build legend entries for multiple simulations
#'
#' Uses the lty assignment from \code{assign_sim_lty()} to produce one legend
#' entry per occupied line-type group, labelled with the simulation range
#' (e.g. "Sim 1-4", "Sim 5-8").
#'
#' @param nsim    Number of simulations.
#' @param lty_vec Integer vector of length nsim from \code{assign_sim_lty()}.
#' @param col_sim Character vector of colours (length nsim) from
#'   \code{generate_shades()}.
#' @param lwd     Line width for legend entries.
#' @return Named list with \code{text}, \code{lty}, \code{lwd}, \code{col}, or
#'   \code{NULL} when \code{nsim <= 1}.
#' @keywords internal
sim_legend_entries <- function(nsim, lty_vec, col_sim, lwd = 2,
                               sim_ids = seq_len(nsim)) {
  if (nsim <= 1L) {
    return(NULL)
  }
  groups <- sort(unique(lty_vec))
  labels <- vapply(groups, function(k) {
    pos <- which(lty_vec == k)
    ids <- sim_ids[pos]
    if (length(ids) == 1L) {
      paste0("Sim ", ids)
    } else {
      paste0("Sim ", min(ids), "\u2013", max(ids))
    }
  }, character(1L))
  # Representative colour: most opaque (last) sim in each group
  rep_cols <- vapply(groups, function(k) {
    col_sim[max(which(lty_vec == k))]
  }, character(1L))
  list(
    text = labels,
    lty  = groups,
    lwd  = rep(lwd, length(groups)),
    col  = rep_cols
  )
}

#' Replace NA values in a vector with a specified replacement
#'
#' @param x Numeric vector with potential NA values
#' @param replacement Value to replace NA values with (default: 0)
#' @return Numeric vector with NA values replaced
#' @keywords internal
#' @noRd
replace_na <- function(x, replacement = 0) {
  x[is.na(x)] <- replacement
  x
}
