# Affect characteristics implied by the OU process

``` r

library(affectOU)
```

Modelling affect with the Ornstein-Uhlenbeck (OU) process implies affect
dynamics are characterized by several distinct features. This vignette
demonstrates each feature visually. For further mathematical definitions
of the quantities shown here, see
[`stability()`](https://kcevers.github.io/affectOU/reference/stability.affectOU.md)
and
[`stationary()`](https://kcevers.github.io/affectOU/reference/stationary.affectOU.md).

For reference, the multivariate OU process is defined as:

\\d\mathbf{X}(t) = \mathbf{\Theta}(\mathbf{\mu} - \mathbf{X}(t))dt +
\mathbf{\Gamma} \\ d\mathbf{W}(t)\\

where \\\mathbf{\mu}\\ defines the location of the affective baseline,
\\\mathbf{\Theta}\\ defines the regulation towards this baseline (for
stable systems), and \\\mathbf{\Gamma}\\ defines the reactivity to
random perturbations.

## 1. Mean Reversion

The first main feature of the OU as a model of affect dynamics concerns
the tendency to return to its mean. For stable systems (see later
sections), when affect is perturbed, it returns toward its baseline
\\\mathbf{\mu}\\ at a rate determined by the eigenvalues of
\\\mathbf{\Theta}\\. In unidimensional systems, \\\theta\\ can simply be
interpreted as the speed of emotional regulation, where low \\\theta\\
represents emotional inertia.

Show mathematical background

It can be proven that this regulation is captured by a matrix
exponential so that, after a time step \\\Delta t\\, the deterministic
drift of the system can be described by the following equation:

\\\begin{equation} \mathbf{X}\_{t + \Delta t} = (\mathbf{I}\_d -
e^{-\mathbf{\Theta} \Delta t}) \mathbf{\mu} + e^{-\mathbf{\Theta} \Delta
t} \mathbf{X}\_t \end{equation}\\

The rate of this regulation is determined by the eigenvalues of
\\\mathbf{\Theta}\\. Decomposing:

\\\begin{equation} \mathbf{\Theta} = \mathbf{\Omega} \mathbf{\Lambda}
\mathbf{\Omega}^{-1} \end{equation}\\

where \\\mathbf{\Omega}\\ contains the eigenvectors and
\\\mathbf{\Lambda}\\ contains the eigenvalues of the drift matrix
\\\mathbf{\Theta}\\. The drift can itself be decomposed as:

\\\begin{equation} \begin{split} e^{-\mathbf{\Theta} \Delta t} &=
e^{-\mathbf{\Omega} \mathbf{\Lambda} \mathbf{\Omega}^{-1} \Delta t} \\
&= \mathbf{\Omega} e^{-\mathbf{\Lambda} \Delta t} \mathbf{\Omega}^{-1}
\end{split} \end{equation}\\

This derivation shows that the rate of the regulation is determined by
the eigenvalues \\\mathbf{\Lambda}\\ while the directionality of the
regulation is determined by the eigenvectors \\\mathbf{\Omega}\\. For
stable systems with positive real parts to the eigenvalues, higher
values of \\\lambda_i \in \mathbf{\Lambda}\\ will lead to a more rapid
regulation while lower values of \\\lambda_i\\ indicate slower
regulation.

This property is shown below, in which we simulate two independent OU
processes only differing in \\\theta\\. The process with higher
\\\theta\\ (red) stays closer to its attractor (horizontal line,
\\\mu\\) than the process with lower \\\theta\\ (green), which strays
further away. In emotion terms, the former process displays lower
affective inertia than the latter..

Show code

``` r

# For simplicity and ease of visualisation, we specify both processes in the same model.
# However, as they are uncoupled, they will evolve independently over time.
model <- affectOU(
  theta = diag(c(5.0, 0.5))
)

# Simulate and plot timeseries
sim <- simulate(
  model,
  seed = 123,
  stop = 20
)

plot(
  sim,
  by_dim = FALSE,
  main = "Mean Reversion Depends on θ",
  sub = c("Fast Regulation (θ = 5.0)", "Slow Regulation (θ = 0.5)")
)
```

![Time series plot with two lines, one for each process that is
displayed. The fast-regulating process (red, with θ = 5.0) is shown to
fluctuate closely around the attractor, typically remaining within the
bounds \[-1, 1\]. The slow-regulating process (green, with θ = 0.5),
however, fluctuates more widely around the attractor, with small
perturbations building up to large fluctuations around the attractor
state.](characteristics_files/figure-html/mean-reversion-plot-1.svg)

## 2. Perturbation Persistence

After affect is perturbed, it takes time to return to its baseline. The
speed of this return is determined by \\\mathbf{\Theta}\\, which
characterizes how long the effect of perturbations persists. The rate of
decay \\\tau\\ – sometimes referred to as the relaxation time – can be
computed through the solution of the OU, specifically:

\\\begin{equation} \mathbf{y}\_{\Delta t} = \mathbf{\mu} +
e^{-\mathbf{\Theta} \Delta t} (\mathbf{y}\_0 - \mathbf{\mu})
\end{equation}\\

We can then define the relaxation time \\\tau\\ as the time \\\Delta t\\
after which the initial condition \\\mathbf{y}\_0\\ relaxed towards the
attractor \\\mathbf{\mu}\\, retaining only a particular percentage of
its original value. For example, for unidimensional OUs, setting the
relaxation time \\\tau = \theta^{-1}\\ leads to the deviation of initial
condition from the attractor (\\\mathbf{y}\_0 - \mathbf{\mu}\\) to
shrink to \\e^{-1} \approx 0.37 = 37\\\\ of its original value.

Show mathematical background

Note that through this set of equations, we can alternatively define the
half-life \\\tau = t\_{.50} = \ln(2) \mathbf{\Theta^{-1}}\\ as the time
after which a deviation from \\\mathbf{\mu}\\ shrinks to 50%.

The relaxation time is straightforward to compute for unidimensional
OUs. To derive this, we can use the solution of the OU, which is given
by:

\\\begin{equation} y\_{\Delta t} = \mu + e^{-\theta \Delta t} (y_0 -
\mu) \end{equation}\\

where \\y\_{\Delta t}\\ represents the value of the variable after a
time step \\\Delta t\\, \\y_0\\ represents the initial condition,
\\\theta\\ is the drift parameter, and \\\mu\\ is the attractor. Now, we
are interested in finding out to what degree the initial deviation from
the attractor determines the value of \\y\_{\Delta t}\\ after a
particular time \\\tau\\ has passed. In other words, in this solution,
we are only interested in the last part of the solution scaling the
initial deviation from the attractor:

\\\begin{equation} e^{-\theta \Delta t} (y_0 - \mu) \end{equation}\\

If we denote the relaxation percentage with \\r \in \[0, 1\]\\, then we
can compute the corresponding relaxation time \\\tau\\ as follows:

\\\begin{equation} \begin{split} e^{-\theta \tau} &= r \\ -\theta \tau
&= \ln(r) \\ \tau &= -\ln(r) \theta^{-1} \end{split} \end{equation}\\

Exemplifying this equation with a unidimensional OU with drift
coefficient \\\theta = 2\\, we can compute its half-time \\\tau =
t\_{0.5}\\ as \\\tau = -\ln(0.5) 2^{-1} = -\frac{\ln(0.5)}{2} \approx
0.35\\.

The same logic extends to multivariate OUs, where if we assume the
exponential and the logarithm of the drift matrix \\\mathbf{\Theta}\\
exist, and if we assume a \\d \times d\\ matrix of relaxation
percentages \\R\\ for which the logarithm exists, then the corresponding
relaxation times \\\tau\\ can be computed as:

\\\begin{equation} \begin{split} e^{-\mathbf{\Theta} \tau} &= R \\
-\mathbf{\Theta} \tau &= \ln(R) \\ \tau &= -\mathbf{\Theta}^{-1} \ln(R)
\end{split} \end{equation}\\

Note that, in this case, \\\tau\\ is a \\d \times d\\ matrix containing
the relaxation times for each dimension separately. One may use the same
interpretation of relaxation times as before in cases where the
variables captured by the OU are independent (i.e., when
\\\mathbf{\Theta}\\ is diagonal), in which case \\\tau\\ would be a
diagonal matrix containing the relaxation times per dimension
separately. However, this same principle does not apply to coupled
multivariate OUs. Coupling between variables means that the relaxation
of one variable can affect the relaxation of others. In this case, the
relaxation time of one variable cannot be interpreted separately from
the relaxation times of the other variables.

``` r

model <- affectOU(theta = 0.5, mu = 0, sigma = 1)
```

Show code

``` r

# Simulate with more time points for accurate ACF
sim <- simulate(model, stop = 10000, dt = 0.01, save_at = 0.01)
plot(sim, type = "acf", lag.max = 10)
```

![](characteristics_files/figure-html/persistence-plot-show-1.svg)

The ACF equals \\1/e\\ at the relaxation time and \\0.5\\ at the
half-life. Slow regulation (i.e., lower \\\theta\\) means longer
persistence and higher autocorrelation.

## 3. Reactivity

The noise covariance \\\mathbf{\Sigma}\\ determines the stochastic part
of affect, and is often interpreted as affective reactivity to
environmental fluctuations. Within
[`affectOU()`](https://kcevers.github.io/affectOU/reference/affectOU.md),
you can either specify the covariance matrix \\\mathbf{\Sigma}\\ or the
diffusion matrix \\\mathbf{\Gamma}\\, where \\\mathbf{\Gamma}\\ must be
a lower triangular matrix. The noise covariance \\\mathbf{\Sigma}\\ is
the more intuitive parameter to specify when defining the reactivity of
the system, as it directly captures the variance and covariance of the
noise across dimensions.

Show mathematical background

In our implementation of the OU, the noise term is defined as
\\\mathbf{\Gamma} \\ d\mathbf{W}(t)\\, where \\\mathbf{\Gamma}\\ is the
diffusion matrix and \\d\mathbf{W}(t)\\ is a vector of independent
Wiener processes. This means that the noise covariance
\\\mathbf{\Sigma}\\ is not directly specified but is rather derived from
\\\mathbf{\Gamma}\\.

The noise covariance \\\mathbf{\Sigma}\\ is related to the diffusion
matrix \\\mathbf{\Gamma}\\ through:

\\\begin{equation} \mathbf{\Sigma} = \mathbf{\Gamma} \mathbf{\Gamma}^T
\end{equation}\\

This equality is known as the Cholesky decomposition, requiring the
diffusion matrix \\\mathbf{\Gamma}\\ to be a lower triangular matrix.
This restriction ensures that we may convert between \\\mathbf{\Sigma}\\
and \\\mathbf{\Gamma}\\ without loss of generality, meaning that any
positive semi-definite covariance matrix \\\mathbf{\Sigma}\\ can be
represented through \\\mathbf{\Gamma}\\.

In the figure shown below, we visualize how two processes that are
subject to the same perturbations may show larger fluctuations based on
their value of the variance \\\sigma\\, where higher \\\sigma\\ leads to
greater fluctuations around the attractor. In emotion terms, the former
process is more emotionally reactive to environmental fluctuations than
the latter.

Show code

``` r

# For simplicity and ease of visualisation, we specify both processes in the same model.
# However, as they are uncoupled, they will evolve independently over time.
model <- affectOU(theta = 0.5, mu = 0, sigma = diag(c(2.25, 0.09)))
sim <- simulate(model, seed = 456, stop = 20)
plot(sim,
  by_dim = FALSE,
  sub = c("High Reactivity (σ = 2.25)", "Low Reactivity (σ = 0.09)"),
  main = "Effect of Reactivity on Fluctuation Magnitude", ylim = c(-4, 4)
)
```

![](characteristics_files/figure-html/reactivity-plot-1.svg)

## 4. Multivariate Coupling

In multivariate models, off-diagonal elements of \\\mathbf{\Theta}\\
allow for coupling between dimensions, meaning that the dynamics of two
variables can be interlinked. For example, we can create a coupled
two-dimensional system with:

\<!– \\\mathbf{\Theta} = \begin{bmatrix} \theta\_{11} & \theta\_{12} \\
\theta\_{21} & \theta\_{22} \end{bmatrix} = \begin{bmatrix} 0.5 & 0.0 \\
-2.0 & 0.5 \end{bmatrix}\\

The following figure illustrates the resulting coupled dynamics.

Show background on eigenvalues and eigenvectors

\\\mathbf{\Theta}\\ is multiplied by the current state \\\mathbf{X}(t)\\
to determine the deterministic drift of the system. For example, in a
two-dimensional system without any diffusion (i.e., \\\mathbf{\Gamma} =
0\\), the change in \\\mathbf{x}\\ is given by:

\\\frac{d\mathbf{x}}{dt} = \mathbf{\Theta} (\mathbf{\mu} - \mathbf{x}) =
\begin{bmatrix} \theta\_{11} & \theta\_{12} \\ \theta\_{21} &
\theta\_{22} \end{bmatrix} \begin{bmatrix} \mu_1 - x_1 \\ \mu_2 - x_2
\end{bmatrix} = \begin{bmatrix} \theta\_{11} (\mu_1 - x_1) +
\theta\_{12} (\mu_2 - x_2) \\ \theta\_{21} (\mu_1 - x_1) + \theta\_{22}
(\mu_2 - x_2) \end{bmatrix}\\

The change in each dimension \\i\\ is determined by both its own
deviation from \\\mathbf{\mu}\\ and the deviation of the other
dimension, weighted by the corresponding elements of
\\\mathbf{\Theta}{i\cdot}\\. This means that the dynamics of one
dimension can influence the dynamics of the other dimension, creating
coupled trajectories. For example, as shown below, a negative entry
\\\theta\_{12}\\ means that when dimension 2 is above its attractor, it
pushes dimension 1 up, and when dimension 2 is below its attractor, it
pushes dimension 1 down.

Interdimensional coupling can also be analyzed using an
eigendecomposition. The eigenvectors \\\mathbf{\Omega}\\ shape the
direction along which the system moves towards its attractor
\\\mathbf{\mu}\\ (in case of a stable system). The eigenvectors of
\\\mathbf{\Theta}\\ are:

\\\mathbf{\Omega} \approx \begin{bmatrix} 1 & 1 \\ 0 & 0 \end{bmatrix}\\

Each column of \\\mathbf{\Omega}\\ represents an eigenvector, which is a
direction in the state space along which the system moves towards its
attractor. The matrix is defective, with only one linearly independent
eigenvector. The system is effectively one-dimensional, with both
dimensions moving together along the same trajectory toward the
attractor. This behaviour is similarly visible in the time-series plot
below, where both dimensions evolve in an almost identical way over
time.

Show code

``` r

# theta_12 = -2: when dimension 2 is above its attractor, it pushes dimension 1 up;
# when dimension 2 is below its attractor, it pushes dimension 1 down
theta_2d <- matrix(c(
  0.5, -2,
  0, 0.5
), nrow = 2, byrow = TRUE)

# eigen(theta_2d)

model_2d <- affectOU(theta = theta_2d, mu = 0, gamma = 1)
sim_2d <- simulate(model_2d)
plot(sim_2d, main = "Coupled Trajectories", xlim = c(0, 20))
plot(sim_2d, type = "phase", main = "Phase Portrait")
```

![Visualization of a time-series, showing two coupled affect dimensions
evolving over time. A horizontal line denoting the baseline affective
state
\$\mu\$.](characteristics_files/figure-html/multivariate-plot-1.svg)

![Phase portrait of two-dimensional Ornstein-Uhlenbeck process. The plot
has four panels, with on the diagonal the lagged phase portrait of each
affect dimension, and on the off-diagonal the contemporaneous scatter
plots between pairs of
dimensions](characteristics_files/figure-html/multivariate-plot2-1.svg)

## 5. Stability Regimes

Stability refers to the long-run qualitative behaviour of the system.
For the OU process, stability concerns whether the system will be
regulated towards the attractor \\\mathbf{\mu}\\ and, if so, in what
way. This behaviour depends largely on the drift matrix
\\\mathbf{\Theta}\\.

### Univariate

In the univariate case, the sign of \\\theta\\ determines the
qualitative behaviour of the system. Three regimes can be distinguished:

- **\\\theta \> 0\\**: Stable, mean-reverting around \\\mu\\;
- **\\\theta \approx 0\\**: Random walk without clear attractor, meaning
  the process drifts without returning to its baseline;
- **\\\theta \< 0\\**: Unstable process that diverges from \\\mu\\.

Show code

``` r

# For simplicity and ease of visualisation, we specify all processes in the same model.
# However, as they are uncoupled, they will evolve independently over time.
model <- affectOU(theta = diag(c(0.5, 0.01, -0.3)))
sim <- simulate(model, stop = 100, seed = 43)
#> Warning: ! The system is not stable, so no stationary distribution exists.
#> ℹ `initial` defaults to `mu`.
plot(sim,
  ylim = c(-10, 10), by_dim = FALSE,
  main = "Affect Dynamics of Different Stability Regimes",
  sub = c("θ > 0 (stable)", "θ ≈ 0 (random walk)", "θ < 0 (unstable)")
)
```

![Visualisation of the time-series of three Ornstein-Uhlenbeck
processes, with different stability regimes. The first process (θ \> 0,
stable) fluctuates around the attractor state \$\mu\$ in a stable way,
with small perturbations dying down over time. The second process (θ ≈
0, random walk) drifts without returning to its baseline, showing a more
erratic pattern that can stray far from the attractor state \$\mu\$. The
third process (θ \< 0, unstable) diverges from \$\mu\$, showing an
explosive pattern where perturbations grow over
time.](characteristics_files/figure-html/regimes-plot-1.svg)

### Multivariate

For multiple dimensions, stability depends on the eigenvalues of
\\\mathbf{\Theta}\\. We distinguish three cases:

- **Real positive eigenvalues:** In this case, the OU shows smooth
  exponential decay toward the attractor \\\mathbf{\mu}\\ for all
  variables;
- **Complex eigenvalues with positive real parts**: In this case, the OU
  will display damped linear oscillations around the attractor
  \\\mathbf{\mu}\\ for all variables, representing cyclical affect
  patterns;
- **Eigenvalue with zero or negative real parts**: In this case, the OU
  is non-stationary, meaning that affect will diverge over time – either
  drifting monotonically or oscillating with growing amplitude,
  depending on whether the eigenvalues are real or complex. This type of
  behaviour is usually not of theoretical interest.

Below, we demonstrate the first two cases, setting the noise covariance
\\\mathbf{\Sigma}\\ to zero to better show the dynamics implied by the
eigenvalues.

Show code

``` r

# Real eigenvalues: Smooth decay
theta_real <- matrix(
  c(0.2, 0.1, 0.1, 0.2),
  nrow = 2
)

eigen(theta_real)$values
#> [1] 0.3 0.1

# Complex eigenvalues: Oscillatory decay
theta_complex <- matrix(
  c(0.2, -1, 1, 0.2),
  nrow = 2
)

eigen(theta_complex)$values
#> [1] 0.2+1i 0.2-1i
```

``` r

# Define the two models
model_real <- affectOU(
  theta = theta_real,
  sigma = 0
)

model_complex <- affectOU(
  theta = theta_complex,
  sigma = 0
)

# Perform simulations for both systems
seed <- 123
sim_real <- simulate(
  model_real,
  stop = 50, seed = seed,
  initial = c(-3, 3)
)

sim_complex <- simulate(
  model_complex,
  stop = 50, seed = seed,
  initial = c(-3, 3)
)

# Plot the resulting time-series
plot(sim_real, main = "Real eigenvalues")
plot(sim_complex, main = "Complex eigenvalues")
```

![Visualization of the two types of behavior expected in two separate
plot panes. Each plot consists of two smooth lines displaying the
expected behavior according to the model. In the left plot, the two
lines start out at the intercepts \[-3, 3\] and then decay exponentially
towards the attractor \$\mu = (0, 0)\$. In the right plot, the two lines
start at at the same intercepts \[-3, 3\] but then oscillate around the
attractor \$\mu = (0, 0)\$. These oscillations are damped so that they
initially start out big, but die down after a
while.](characteristics_files/figure-html/regimes-2d-plot-1.svg)![Visualization
of the two types of behavior expected in two separate plot panes. Each
plot consists of two smooth lines displaying the expected behavior
according to the model. In the left plot, the two lines start out at the
intercepts \[-3, 3\] and then decay exponentially towards the attractor
\$\mu = (0, 0)\$. In the right plot, the two lines start at at the same
intercepts \[-3, 3\] but then oscillate around the attractor \$\mu = (0,
0)\$. These oscillations are damped so that they initially start out
big, but die down after a
while.](characteristics_files/figure-html/regimes-2d-plot-2.svg)

Note that the behaviour of the OU may also represent a mix of these two
types, combining exponential decay with oscillatory patterns. This is
for example the case in the following figure:

Show code

``` r

# Both complex and real eigenvalues: Combination of smooth and oscillatory
# dynamics
theta <- matrix(
  c(0.2, 1, 0, 1, 0.2, -1, 0, 1, 0.2),
  nrow = 3
)

eigen(theta)$values
#> [1] 0.2000034+0.00000e+00i 0.1999983+2.93925e-06i 0.1999983-2.93925e-06i
```

``` r

# Define the the model
model <- affectOU(
  theta = theta,
  sigma = 0
)

# Perform simulations for the system
seed <- 123
sim <- simulate(
  model,
  stop = 50,
  seed = seed,
  initial = c(-3, 3, 4)
)

# Plot the resulting time-series
plot(sim, main = "Real and complex eigenvalues")
```

![Visualization of an OU process with real and complex eigenvalues. All
dimensions show an initial overshoot of the attractor state \$\mu\$, but
then relax in an exponential
way.](characteristics_files/figure-html/regimes-3d-plot-1.svg)

## 6. Noise Coupling

Non-zero off-diagonal elements of \\\mathbf{\Gamma}\\ mean that the same
random fluctuations drive both dimensions simultaneously — the noise
sources are shared. This can lead to synchronized fluctuations even when
there is no coupling in the deterministic part of the process (i.e.,
\\\mathbf{\Theta}\\ is diagonal).

Show code

``` r

# Shared noise sources (same fluctuation drives both dims), no drift coupling
gamma_2d <- matrix(c(
  1, 0,
  0.5, 1
), nrow = 2, byrow = TRUE)
gamma_2d %*% t(gamma_2d) # implied noise covariance Σ

model_2d <- affectOU(theta = 0.5, mu = 0, gamma = gamma_2d)
sim_2d <- simulate(model_2d, seed = 105)
plot(sim_2d, main = "Shared Noise Sources", xlim = c(0, 20))
```

![Visualisation of the time-series of two Ornstein-Uhlenbeck processes
with shared noise sources. The two trajectories show coupling in their
fluctuations, with peaks and troughs occurring at similar time points,
even though there is no coupling in the deterministic part of the
process (i.e., θ is
diagonal).](characteristics_files/figure-html/noise-plot-1.svg)

## Summary

| Feature | Parameter | Effect |
|----|----|----|
| Mean reversion | \\\mathbf{\Theta}\\ | Rate and direction of return to baseline |
| Relaxation time | \\\mathbf{\Theta}\\ | Perturbation persistence |
| Reactivity | \\\mathbf{\Sigma}\\ | Magnitude of response to perturbations |
| Dimensional Coupling | Eigenvectors of \\\mathbf{\Theta}\\ | Coupled dynamics |
| Stability | Eigenvalues of \\\mathbf{\Theta}\\ | Stationary vs divergent |
| Noise coupling | Off-diagonal elements of \\\mathbf{\Sigma}\\ | Shared noise sources across dimensions |
