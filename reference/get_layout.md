# Calculate layout dimensions for multi-panel plots

Calculate layout dimensions for multi-panel plots

## Usage

``` r
get_layout(n, P, user_args = list(), by_dim = TRUE, call = rlang::caller_env())
```

## Arguments

- n:

  Number of panels needed

- P:

  Parameter list containing nrow, ncol, mfrow, or mfcol

- user_args:

  Original user arguments (to check for mfrow/mfcol)

- by_dim:

  Logical; plot each dimension in separate panel?

- call:

  Environment used to report errors. Relevant only when calling this
  function from another function, so that errors name the function the
  user called.

## Value

List with nrow and ncol
