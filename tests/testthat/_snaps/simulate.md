# print.simulate_affectOU snapshot (1D) [plain]

    Code
      print(sim)
    Message
      
      -- 1D Ornstein-Uhlenbeck Simulation --------------------------------------------
      Time: 0 → 10.000; dt: 0.100; save_at: 0.100
      Seed: 42
      
        time dim sim value
      1  0.0   1   1 1.371
      2  0.1   1   1 1.124
      3  0.2   1   1 1.182
      4  0.3   1   1 1.323
      5  0.4   1   1 1.385
      6  0.5   1   1 1.282

# print.simulate_affectOU snapshot (1D) [ansi]

    Code
      print(sim)
    Message
      
      [36m--[39m [1m1D Ornstein-Uhlenbeck Simulation[22m [36m--------------------------------------------[39m
      Time: 0 → 10.000; dt: 0.100; save_at: 0.100
      Seed: 42
      
        time dim sim value
      1  0.0   1   1 1.371
      2  0.1   1   1 1.124
      3  0.2   1   1 1.182
      4  0.3   1   1 1.323
      5  0.4   1   1 1.385
      6  0.5   1   1 1.282

# print.simulate_affectOU snapshot (2D, nsim=3) [plain]

    Code
      print(sim)
    Message
      
      -- 2D Ornstein-Uhlenbeck Simulation (3 replications) ---------------------------
      Time: 0 → 10.000; dt: 0.100; save_at: 0.100
      Seed: 123
      
        time dim sim  value
      1  0.0   1   1 -0.560
      2  0.1   1   1 -0.040
      3  0.2   1   1  0.003
      4  0.3   1   1  0.149
      5  0.4   1   1 -0.076
      6  0.5   1   1  0.315

# print.simulate_affectOU snapshot (2D, nsim=3) [ansi]

    Code
      print(sim)
    Message
      
      [36m--[39m [1m2D Ornstein-Uhlenbeck Simulation (3 replications)[22m [36m---------------------------[39m
      Time: 0 → 10.000; dt: 0.100; save_at: 0.100
      Seed: 123
      
        time dim sim  value
      1  0.0   1   1 -0.560
      2  0.1   1   1 -0.040
      3  0.2   1   1  0.003
      4  0.3   1   1  0.149
      5  0.4   1   1 -0.076
      6  0.5   1   1  0.315

# print.summary_simulate_affectOU snapshot (1D stationary) [plain]

    Code
      print(s)
    Message
      
      -- 1D Ornstein-Uhlenbeck Simulation Summary (5 replications) -------------------
      
      -- Simulation settings --
      
      Time: 10.000 → 100.000 (first 10.000 discarded)
      Time points: 901; dt: 0.1; save_at: 0.1
      Seed: 123
      
      -- Comparison to theoretical distribution --
      
           Simulated Theoretical
      Mean    -0.002           0
      SD       0.957           1

# print.summary_simulate_affectOU snapshot (1D stationary) [ansi]

    Code
      print(s)
    Message
      
      [36m--[39m [1m1D Ornstein-Uhlenbeck Simulation Summary (5 replications)[22m [36m-------------------[39m
      
      -- [1m[1mSimulation settings[1m[22m --
      
      Time: 10.000 → 100.000 (first 10.000 discarded)
      Time points: 901; dt: 0.1; save_at: 0.1
      Seed: 123
      
      -- [1m[1mComparison to theoretical distribution[1m[22m --
      
           Simulated Theoretical
      Mean    -0.002           0
      SD       0.957           1

# print.summary_simulate_affectOU respects digits [plain]

    Code
      print(s, digits = 2)
    Message
      
      -- 1D Ornstein-Uhlenbeck Simulation Summary (5 replications) -------------------
      
      -- Simulation settings --
      
      Time: 10.00 → 100.00 (first 10.00 discarded)
      Time points: 901; dt: 0.1; save_at: 0.1
      Seed: 123
      
      -- Comparison to theoretical distribution --
      
           Simulated Theoretical
      Mean      0.00           0
      SD        0.96           1

# print.summary_simulate_affectOU respects digits [ansi]

    Code
      print(s, digits = 2)
    Message
      
      [36m--[39m [1m1D Ornstein-Uhlenbeck Simulation Summary (5 replications)[22m [36m-------------------[39m
      
      -- [1m[1mSimulation settings[1m[22m --
      
      Time: 10.00 → 100.00 (first 10.00 discarded)
      Time points: 901; dt: 0.1; save_at: 0.1
      Seed: 123
      
      -- [1m[1mComparison to theoretical distribution[1m[22m --
      
           Simulated Theoretical
      Mean      0.00           0
      SD        0.96           1

# print.summary_simulate_affectOU snapshot (2D stationary) [plain]

    Code
      print(s)
    Message
      
      -- 2D Ornstein-Uhlenbeck Simulation Summary (3 replications) -------------------
      
      -- Simulation settings --
      
      Time: 20.000 → 100.000 (first 20.000 discarded)
      Time points: 801; dt: 0.1; save_at: 0.1
      Seed: 456
      
      -- Comparison to theoretical distribution --
      
      Mean:
                   dim1   dim2
      Simulated   1.217 -0.658
      Theoretical 1.000 -1.000
      
      SD:
                   dim1  dim2
      Simulated   0.894 1.227
      Theoretical 1.000 1.291
      
      Covariance (simulated):
            [,1]  [,2]
      [1,] 0.800 0.045
      [2,] 0.045 1.505
      
      Covariance (theoretical):
           [,1]  [,2]
      [1,]    1 0.000
      [2,]    0 1.667
      
      Correlation (simulated):
            [,1]  [,2]
      [1,] 1.000 0.041
      [2,] 0.041 1.000
      
      Correlation (theoretical):
           [,1] [,2]
      [1,]    1    0
      [2,]    0    1

# print.summary_simulate_affectOU snapshot (2D stationary) [ansi]

    Code
      print(s)
    Message
      
      [36m--[39m [1m2D Ornstein-Uhlenbeck Simulation Summary (3 replications)[22m [36m-------------------[39m
      
      -- [1m[1mSimulation settings[1m[22m --
      
      Time: 20.000 → 100.000 (first 20.000 discarded)
      Time points: 801; dt: 0.1; save_at: 0.1
      Seed: 456
      
      -- [1m[1mComparison to theoretical distribution[1m[22m --
      
      Mean:
                   dim1   dim2
      Simulated   1.217 -0.658
      Theoretical 1.000 -1.000
      
      SD:
                   dim1  dim2
      Simulated   0.894 1.227
      Theoretical 1.000 1.291
      
      Covariance (simulated):
            [,1]  [,2]
      [1,] 0.800 0.045
      [2,] 0.045 1.505
      
      Covariance (theoretical):
           [,1]  [,2]
      [1,]    1 0.000
      [2,]    0 1.667
      
      Correlation (simulated):
            [,1]  [,2]
      [1,] 1.000 0.041
      [2,] 0.041 1.000
      
      Correlation (theoretical):
           [,1] [,2]
      [1,]    1    0
      [2,]    0    1

# print.summary_simulate_affectOU snapshot (non-stationary) [plain]

    Code
      print(s)
    Message
      
      -- 1D Ornstein-Uhlenbeck Simulation Summary ------------------------------------
      
      -- Simulation settings --
      
      Time: 0 → 10.000
      Time points: 101; dt: 0.1; save_at: 0.1
      Seed: 789
      
      -- Simulated statistics --
      
      Mean: -41.081
      SD: 50.454
      
      i Model is not stationary; theoretical comparison not available.

# print.summary_simulate_affectOU snapshot (non-stationary) [ansi]

    Code
      print(s)
    Message
      
      [36m--[39m [1m1D Ornstein-Uhlenbeck Simulation Summary[22m [36m------------------------------------[39m
      
      -- [1m[1mSimulation settings[1m[22m --
      
      Time: 0 → 10.000
      Time points: 101; dt: 0.1; save_at: 0.1
      Seed: 789
      
      -- [1m[1mSimulated statistics[1m[22m --
      
      Mean: -41.081
      SD: 50.454
      
      [36mi[39m Model is not stationary; theoretical comparison not available.

# print.summary_simulate_affectOU snapshot (high-dimensional stationary) [plain]

    Code
      print(s)
    Message
      
      -- 25D Ornstein-Uhlenbeck Simulation Summary (2 replications) ------------------
      
      -- Simulation settings --
      
      Time: 10.000 → 50.000 (first 10.000 discarded)
      Time points: 401; dt: 0.1; save_at: 0.1
      Seed: 101
      
      -- Statistics --
      
      i High-dimensional model (25D). Full statistics not shown.
      Access statistics via `$statistics`.

# print.summary_simulate_affectOU snapshot (high-dimensional stationary) [ansi]

    Code
      print(s)
    Message
      
      [36m--[39m [1m25D Ornstein-Uhlenbeck Simulation Summary (2 replications)[22m [36m------------------[39m
      
      -- [1m[1mSimulation settings[1m[22m --
      
      Time: 10.000 → 50.000 (first 10.000 discarded)
      Time points: 401; dt: 0.1; save_at: 0.1
      Seed: 101
      
      -- [1m[1mStatistics[1m[22m --
      
      [36mi[39m High-dimensional model (25D). Full statistics not shown.
      Access statistics via `$statistics`.

# print.summary_simulate_affectOU snapshot (high-dimensional non-stationary) [plain]

    Code
      print(s)
    Message
      
      -- 25D Ornstein-Uhlenbeck Simulation Summary -----------------------------------
      
      -- Simulation settings --
      
      Time: 0 → 10.000
      Time points: 101; dt: 0.1; save_at: 0.1
      Seed: 102
      
      -- Statistics --
      
      i High-dimensional model (25D). Full statistics not shown.
      Access statistics via `$statistics`.
      
      i Model is not stationary; theoretical comparison not available.

# print.summary_simulate_affectOU snapshot (high-dimensional non-stationary) [ansi]

    Code
      print(s)
    Message
      
      [36m--[39m [1m25D Ornstein-Uhlenbeck Simulation Summary[22m [36m-----------------------------------[39m
      
      -- [1m[1mSimulation settings[1m[22m --
      
      Time: 0 → 10.000
      Time points: 101; dt: 0.1; save_at: 0.1
      Seed: 102
      
      -- [1m[1mStatistics[1m[22m --
      
      [36mi[39m High-dimensional model (25D). Full statistics not shown.
      Access statistics via `$statistics`.
      
      [36mi[39m Model is not stationary; theoretical comparison not available.

