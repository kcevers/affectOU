# Convert simulation results to data frame

Converts an `simulate_affectOU` object to a data frame in either long or
wide format.

## Usage

``` r
# S3 method for class 'simulate_affectOU'
as.data.frame(
  x,
  row.names = NULL,
  optional = FALSE,
  direction = c("long", "wide"),
  ...
)
```

## Arguments

- x:

  A `simulate_affectOU` object

- row.names:

  NULL or a character vector giving the row names for the data frame.
  Missing values are not allowed.

- optional:

  Logical. If TRUE, setting row names and converting column names is
  optional. Included for compatibility with the generic.

- direction:

  Character, either `"long"` (default) or `"wide"`. Long format has one
  row per time-dimension-simulation combination. Wide format has one row
  per time point with dimensions and simulations spread across columns.

- ...:

  Additional arguments (unused)

## Value

For `direction = "long"`, a data frame with columns:

- time:

  Observation time

- dim:

  Dimension index

- sim:

  Simulation index

- value:

  Simulated value

For `direction = "wide"`, a data frame with `time` as the first column
and subsequent columns named `dim{d}` when `nsim = 1`, or
`dim{d}.sim{s}` when `nsim > 1`.

## Examples

``` r
model <- affectOU(ndim = 2)
sim <- simulate(model, nsim = 3)

# Long format (default) - one row per timepoint, dimension, and simulation
df_long <- as.data.frame(sim)
head(df_long)
#>   time dim sim      value
#> 1 0.00   1   1 -0.5288227
#> 2 0.01   1   1 -0.8424644
#> 3 0.02   1   1 -0.6921425
#> 4 0.03   1   1 -0.6753136
#> 5 0.04   1   1 -0.7123315
#> 6 0.05   1   1 -0.6023915

# Wide format - one row per time point
df_wide <- as.data.frame(sim, direction = "wide")
head(df_wide)
#>   time  dim1.sim1 dim2.sim1  dim1.sim2   dim2.sim2 dim1.sim3  dim2.sim3
#> 1 0.00 -0.5288227 1.2963601 -0.7256299  0.16256096 0.5342577 -0.5474628
#> 2 0.01 -0.8424644 1.3143001 -0.7105397  0.21157340 0.5746925 -0.4882770
#> 3 0.02 -0.6921425 1.2605035 -0.6366530  0.02498835 0.6923642 -0.3345983
#> 4 0.03 -0.6753136 1.2514750 -0.7756931 -0.15603317 0.6712522 -0.2569165
#> 5 0.04 -0.7123315 0.9688085 -0.6945701 -0.16985215 0.6434854 -0.3612767
#> 6 0.05 -0.6023915 1.0272213 -0.5074560 -0.11218118 0.6616012 -0.4319665
```
