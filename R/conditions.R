# Helpers for input validation --------------------------------------
#
# Every exported function uses input validation and passes its own `call`
# so the error names the function the user typed.
# Internal helpers assume valid input and carry `.internal = TRUE` assertions.


#' Psychological meaning of a model or simulation argument
#'
#' The psychological meaning of each argument is defined in the glossary.
#' The `i` bullets of error messages read it directly; the corresponding roxygen
#' `@param` entries open with the same clause, so the help page and the error
#' message correspond. Any clause should be changed in both places.
#' matches it.
#'
#' @param arg Argument name.
#' @return A clause suitable for continuing "`arg` is ...", or `NULL`.
#' @noRd
param_gloss <- function(arg) {
  gloss <- c(
    theta = "how quickly affect returns to baseline \u2014 low values mean feelings linger (inertia or rumination)",
    mu = "the baseline affect the process returns to \u2014 a person's typical mood",
    gamma = "how strongly affect responds to ongoing random fluctuation",
    sigma = "how much random fluctuation drives each affect dimension, and how those fluctuations move together",
    ndim = "the number of affect dimensions modelled",
    dt = "the time step the simulation advances by",
    stop = "how long the simulated period lasts",
    save_at = "the time interval at which simulated data is saved, so the output is not too large",
    nsim = "how many independent trajectories to simulate",
    discard_initial_time = "how much time to discard from the beginning of the simulation, so the process has settled",
    initial = "the affect value each trajectory starts from",
    seed = "the random seed, so a simulation can be reproduced"
  )

  if (arg %in% names(gloss)) unname(gloss[[arg]]) else NULL
}


# Describing the value which is causing the error ---------------------------------------------

#' Describe the shape of a numeric object, in the register of the messages
#'
#' `rlang::stop_input_type()` reports the *type* of an object ("a double
#' matrix"), never its shape. Dimension mismatches need the shape on both sides
#' of "not", so they are written by hand on top of this.
#'
#' @noRd
obj_shape_friendly <- function(x) {
  if (is.matrix(x)) {
    return(paste0("a ", nrow(x), "x", ncol(x), " matrix"))
  }
  if (is.array(x) && length(dim(x)) > 2L) {
    return(paste0("a ", length(dim(x)), "-dimensional array"))
  }
  if (length(x) == 1L) {
    return("a single number")
  }
  paste0("a vector of length ", length(x))
}


#' The forms an `ndim`-dimensional matrix parameter may be given in
#' @noRd
matrix_forms <- function(ndim) {
  if (ndim == 1L) {
    "a single number"
  } else {
    paste0(
      "a single number, a vector of length ", ndim,
      ", or a ", ndim, "x", ndim, " matrix"
    )
  }
}


#' The forms an `ndim`-dimensional vector parameter may be given in
#' @noRd
vector_forms <- function(ndim) {
  if (ndim == 1L) {
    "a single number"
  } else {
    paste0("a single number or a vector of length ", ndim)
  }
}


#' `i` bullet stating what an argument means, from the glossary
#' @noRd
gloss_bullet <- function(arg) {
  gloss <- param_gloss(arg)
  if (is.null(gloss)) {
    return(NULL)
  }
  c("i" = paste0("{.arg ", arg, "} is ", gloss, "."))
}


#' `i` bullet explaining where the dimension requirement comes from
#' @noRd
ndim_bullet <- function(ndim) {
  c("i" = paste0(
    "{.arg ndim} is ", ndim, ", so every parameter must describe ",
    ndim, " affect ", if (ndim == 1L) "dimension." else "dimensions."
  ))
}


# Shared checks --------------------------------------------------------------

#' Which kinds of non-finite value are present
#'
#' @noRd
non_finite_kinds <- function(x) {
  bad <- character()
  if (any(is.na(x) & !is.nan(x))) bad <- c(bad, "NA")
  if (any(is.nan(x))) bad <- c(bad, "NaN")
  if (any(is.infinite(x))) bad <- c(bad, "Inf")
  bad
}


#' Require that every element is finite
#' @noRd
check_all_finite <- function(x, arg, call = rlang::caller_env()) {
  if (all(is.finite(x))) {
    return(invisible(NULL))
  }

  cli::cli_abort(
    c(
      "{.arg {arg}} must contain only finite values.",
      "x" = "It contains {.code {non_finite_kinds(x)}} values."
    ),
    call = call,
    class = "affectOU_error_not_finite"
  )
}


#' Require a confidence level strictly inside (0, 1)
#' @noRd
check_level <- function(level, call = rlang::caller_env()) {
  rlang::check_number_decimal(level, min = 0, max = 1, arg = "level", call = call)

  if (level <= 0 || level >= 1) {
    cli::cli_abort(
      "{.arg level} must be a number between 0 and 1, not the number {level}.",
      call = call,
      class = "affectOU_error_bad_level"
    )
  }

  invisible(NULL)
}


#' Require a number strictly greater than zero
#'
#' `rlang::check_number_decimal()` has inclusive bounds only, so strict
#' positivity needs a second line. Only one of the two can ever be triggered.
#'
#' @noRd
check_positive_number <- function(x, arg, call = rlang::caller_env()) {
  rlang::check_number_decimal(x, min = 0, arg = arg, call = call)

  if (x <= 0) {
    cli::cli_abort(
      "{.arg {arg}} must be a number larger than 0, not the number {x}.",
      call = call,
      class = "affectOU_error_not_positive"
    )
  }

  invisible(NULL)
}


#' Require a whole number strictly greater than zero
#' @noRd
check_positive_whole <- function(x, arg, call = rlang::caller_env()) {
  rlang::check_number_whole(x, min = 1, arg = arg, call = call)
  invisible(NULL)
}


#' Require one subtitle per plotted dimension
#'
#' @noRd
check_sub_length <- function(sub, n_dim, call = rlang::caller_env()) {
  if (length(sub) == n_dim) {
    return(invisible(NULL))
  }

  cli::cli_abort(
    c(
      "{.arg sub} must have one element per dimension plotted.",
      "x" = "{.arg sub} has {length(sub)} element{?s} and {n_dim} dimension{?s} {?is/are} plotted."
    ),
    call = call,
    class = "affectOU_error_sub_length"
  )
}


#' Require an object of the given S3 class
#'
#' `what` is spelled out by the caller ("an <affectOU> model") so the message
#' does not use the class string.
#'
#' @noRd
check_model_class <- function(x, cls, what, arg, call = rlang::caller_env()) {
  if (inherits(x, cls)) {
    return(invisible(NULL))
  }

  rlang::stop_input_type(x, what, arg = arg, call = call)
}
