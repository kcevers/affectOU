# Simulate from Ornstein-Uhlenbeck process

Generates a trajectory from the Ornstein-Uhlenbeck process using
Euler-Maruyama discretization. Handles both univariate and multivariate
models.

## Usage

``` r
# S3 method for class 'affectOU'
simulate(
  object,
  nsim = 1,
  seed = NULL,
  initial = NULL,
  dt = 0.01,
  stop = 100,
  save_at = dt,
  ...
)
```

## Arguments

- object:

  An `affectOU` model object.

- nsim:

  How many independent trajectories to simulate. A whole number of at
  least 1.

- seed:

  The random seed, so a simulation can be reproduced. A whole number, or
  `NULL` to leave the random state alone.

- initial:

  The affect value each trajectory starts from. A single number, or a
  vector with one element per dimension. If `NULL`, defaults to a draw
  from the stationary distribution (for stable systems) or the attractor
  location `mu` (for non-stable systems).

- dt:

  The time step the simulation advances by, for the Euler-Maruyama
  discretization (smaller = more accurate). Must be larger than 0.

- stop:

  How long the simulated period lasts, in time units. Must be larger
  than 0.

- save_at:

  The time interval at which simulated data is saved, in time units;
  used to linearly interpolate results. Useful for reducing output size.
  Must be at least `dt`, because states are only computed every `dt`
  time units, and at most `stop`, or nothing would be recorded.

- ...:

  Additional arguments (unused).

## Value

A model object of class `simulate_affectOU` containing:

- model:

  The original `affectOU` model object used for simulation.

- data:

  A 3D array with dimensions (time x ndim x nsim) containing the
  simulated trajectories.

- times:

  A vector of time points corresponding to the rows of the `data` array.

- nsim:

  The number of simulations performed.

- dt:

  The time step used for the Euler-Maruyama discretization.

- stop:

  The total simulation time.

- save_at:

  The time interval at which simulated data was saved.

- seed:

  The random seed used for simulation (if any).

## Examples

``` r
model <- affectOU(ndim = 2)
sim <- simulate(model, nsim = 2)
plot(sim)

summary(sim)
#> 
#> ── 2D Ornstein-Uhlenbeck Simulation Summary (2 replications) ───────────────────
#> 
#> ── Simulation settings ──
#> 
#> Time: 0 → 100.000
#> Time points: 10001; dt: 0.01; save_at: 0.01
#> 
#> ── Comparison to theoretical distribution ──
#> 
#> Mean:
#>              dim1   dim2
#> Simulated   0.438 -0.021
#> Theoretical 0.000  0.000
#> 
#> SD:
#>              dim1  dim2
#> Simulated   0.934 0.913
#> Theoretical 1.000 1.000
#> 
#> Covariance (simulated):
#>       [,1]  [,2]
#> [1,] 0.872 0.022
#> [2,] 0.022 0.833
#> 
#> Covariance (theoretical):
#>      [,1] [,2]
#> [1,]    1    0
#> [2,]    0    1
#> 
#> Correlation (simulated):
#>       [,1]  [,2]
#> [1,] 1.000 0.026
#> [2,] 0.026 1.000
#> 
#> Correlation (theoretical):
#>      [,1] [,2]
#> [1,]    1    0
#> [2,]    0    1
head(sim)
#>   time dim sim     value
#> 1 0.00   1   1 0.3688494
#> 2 0.01   1   1 0.4684450
#> 3 0.02   1   1 0.6321258
#> 4 0.03   1   1 0.6038426
#> 5 0.04   1   1 0.6625987
#> 6 0.05   1   1 0.4958355

# Specify initial state
sim <- simulate(model, initial = c(1, -1))
plot(sim)


# Simulate for a longer time with coarser saving interval
sim <- simulate(model, stop = 500, save_at = 10)
plot(sim)

```
