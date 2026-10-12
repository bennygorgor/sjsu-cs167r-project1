# All simulation and diagnostics use base R. Run from the project root.
STUDENT_SEED <- 5533L
REPLICATIONS <- 30000L
RNGkind("Mersenne-Twister", "Inversion", "Rejection")

populations <- list(
  normal = list(name = "Standard Normal", mu = 0, sigma = 1,
                draw = function(m) rnorm(m)),
  die = list(name = "Six-Sided Die", mu = 3.5, sigma = sqrt(35/12),
             draw = function(m) sample.int(6L, m, replace = TRUE)),
  exponential = list(name = "Exponential (rate 1)", mu = 1, sigma = 1,
                     draw = function(m) rexp(m, rate = 1)),
  binomial = list(name = "Binomial (size 5, p 0.10)", mu = 0.5,
                  sigma = sqrt(0.45),
                  draw = function(m) rbinom(m, size = 5, prob = 0.10)),
  cauchy = list(name = "Standard Cauchy", mu = NA_real_, sigma = NA_real_,
                draw = function(m) rcauchy(m, location = 0, scale = 1))
)

# Each row is one independent sample, and its mean is one Monte Carlo result.
# B controls Monte Carlo precision; n controls the sampling distribution.
simulate_means <- function(key, n, B = REPLICATIONS, seed = STUDENT_SEED) {
  stopifnot(key %in% names(populations), n >= 1, B >= 2)
  set.seed(seed)
  ans <- numeric(B)
  for (start in seq.int(1L, B, by = 1000L)) {
    idx <- start:min(start + 999L, B)
    samples <- matrix(populations[[key]]$draw(length(idx) * n),
                      nrow = length(idx), ncol = n, byrow = TRUE)
    ans[idx] <- rowMeans(samples)
  }
  ans
}

# Both sides of ECDF jumps are checked, including ties for discrete data.
normal_cdf_distance <- function(z) {
  z <- sort(z)
  B <- length(z)
  F <- pnorm(z)
  max(abs(seq_len(B)/B - F), abs((seq_len(B)-1)/B - F))
}

diagnose <- function(key, n, x, seed = STUDENT_SEED) {
  p <- populations[[key]]
  centered <- x - mean(x)
  m2 <- mean(centered^2)
  finite <- is.finite(p$sigma)
  se <- if (finite) p$sigma / sqrt(n) else NA_real_
  skew <- mean(centered^3) / m2^1.5
  excess <- mean(centered^4) / m2^2 - 3
  D <- if (finite) normal_cdf_distance((x - p$mu)/se) else NA_real_
  se_error <- if (finite) abs(sd(x)/se - 1) else NA_real_
  # These thresholds are declared before the simulation. They are a working
  # definition of an approximation, not a theorem or a formal normality test.
  pass <- finite && abs(skew) <= 0.30 && abs(excess) <= 0.50 &&
    D <= 0.05 && se_error <= 0.05
  data.frame(population = key, n = n, B = length(x), seed = seed,
             simulated_mean = mean(x), simulated_se = sd(x),
             theoretical_mean = p$mu, theoretical_se = se,
             skewness = skew, excess_kurtosis = excess, cdf_distance = D,
             relative_se_error = se_error, median = median(x), IQR = IQR(x),
             max_abs_mean = max(abs(x)), pass = pass)
}

coarse_grid <- c(1L, 2L, 3L, 5L, 10L, 20L, 30L, 50L, 75L, 100L, 150L, 200L)

# A stable candidate must pass at n, n+1, ..., n+4. This reduces reliance on
# one lucky estimate without claiming an exact mathematical cutoff.
stable_candidate <- function(d) {
  d <- d[order(d$n), ]
  for (n in d$n) {
    idx <- match(n + 0:4, d$n)
    if (all(!is.na(idx)) && all(d$pass[idx])) return(n)
  }
  NA_integer_
}

run_population <- function(key, seed = STUDENT_SEED) {
  grid <- if (key == "cauchy") c(1L, 2L, 5L, 10L, 30L, 100L, 300L, 1000L) else coarse_grid
  values <- list()
  rows <- list()
  add <- function(n) {
    x <- simulate_means(key, n, seed = seed)
    values[[as.character(n)]] <<- x
    rows[[as.character(n)]] <<- diagnose(key, n, x, seed)
  }
  for (n in grid) add(n)
  coarse <- do.call(rbind, rows)
  chosen <- NA_integer_
  if (key != "cauchy") {
    passing <- coarse$n[coarse$pass]
    if (!length(passing)) stop("Extend coarse search for ", key)
    upper <- min(passing) + 4L
    for (n in setdiff(seq_len(upper), grid)) add(n)
    chosen <- stable_candidate(do.call(rbind, rows))
    while (is.na(chosen) && upper < 250L) {
      upper <- upper + 5L
      for (n in setdiff(seq_len(upper), as.integer(names(rows)))) add(n)
      chosen <- stable_candidate(do.call(rbind, rows))
    }
    if (is.na(chosen)) stop("No stable candidate for ", key)
  }
  d <- do.call(rbind, rows)
  d <- d[order(d$n), ]
  rownames(d) <- NULL
  list(key = key, seed = seed, diagnostics = d, chosen = chosen,
       coarse_grid = grid, means = values)
}

plot_population <- function(result, file) {
  key <- result$key
  set.seed(STUDENT_SEED)
  x <- populations[[key]]$draw(REPLICATIONS)
  png(file, width = 1500, height = 760, res = 150)
  par(mar = c(4.2, 4.5, 3.5, 1.2), col.axis = "#35445a", col.lab = "#20324a")
  if (key == "cauchy") {
    hist(x, breaks = c(-Inf, seq(-15, 15, by = 0.3), Inf), freq = FALSE,
         xlim = c(-15, 15), col = "#a9cbdc", border = "white",
         main = "Cauchy population: central window only", xlab = "Observation")
    curve(dcauchy(x), add = TRUE, col = "#b34c38", lwd = 2)
    mtext(sprintf("%d of %d observations fall outside [-15, 15]; tails are not removed from calculations",
                  sum(abs(x) > 15), length(x)), side = 3, line = 0.3, cex = 0.7)
  } else {
    breaks <- if (key == "die") seq(0.5, 6.5, 1) else if (key == "binomial") seq(-0.5, 5.5, 1) else 55
    hist(x, breaks = breaks, freq = FALSE, col = "#a9cbdc", border = "white",
         main = paste(populations[[key]]$name, "population"), xlab = "Observation")
  }
  dev.off()
}

plot_diagnostics <- function(result, file) {
  key <- result$key
  ns <- if (key == "cauchy") c(1, 30, 1000) else
    unique(c(1L, max(1L, result$chosen - 1L), result$chosen, 30L))
  png(file, width = 1800, height = 520 * length(ns), res = 160)
  par(mfrow = c(length(ns), 2), mar = c(4, 4, 3, 1), cex = 0.9)
  for (n in ns) {
    x <- result$means[[as.character(n)]]
    if (key == "cauchy") {
      hist(x, breaks = c(-Inf, seq(-15, 15, by = 0.3), Inf), freq = FALSE,
           xlim = c(-15, 15), col = "#a9cbdc", border = "white",
           main = sprintf("n = %d: central window [-15,15]", n), xlab = "Sample mean")
      curve(dcauchy(x), add = TRUE, col = "#b34c38", lwd = 2)
      mtext(sprintf("Outside window: %d / %d", sum(abs(x) > 15), length(x)), cex = 0.7)
    } else {
      se <- populations[[key]]$sigma/sqrt(n)
      mu <- populations[[key]]$mu
      br <- if (key %in% c("die", "binomial"))
        seq(min(x) - 0.5/n, max(x) + 0.51/n, by = 1/n) else 55
      hist(x, breaks = br, freq = FALSE, col = "#a9cbdc", border = "white",
           main = sprintf("n = %d: sampling distribution", n), xlab = "Sample mean")
      curve(dnorm(x, mu, se), add = TRUE, col = "#b34c38", lwd = 2)
    }
    qqnorm(x, pch = 16, cex = 0.22, col = "#28758b",
           main = sprintf("n = %d: normal Q-Q plot (all values)", n))
    qqline(x, col = "#b34c38", lwd = 2)
  }
  dev.off()
}

plot_convergence <- function(result, file) {
  d <- result$diagnostics
  png(file, width = 1600, height = 1100, res = 150)
  par(mfrow = c(2, 2), mar = c(4, 4, 3, 1))
  if (result$key == "cauchy") {
    for (metric in c("simulated_mean", "simulated_se", "IQR", "max_abs_mean")) {
      plot(d$n, d[[metric]], type = "b", log = "x", pch = 19,
           col = "#28758b", xlab = "n (log scale)", ylab = metric,
           main = paste("Cauchy:", metric))
      if (metric == "IQR") abline(h = 2, col = "#b34c38", lty = 2)
    }
  } else {
    metrics <- c("skewness", "excess_kurtosis", "cdf_distance", "relative_se_error")
    bounds <- c(0.30, 0.50, 0.05, 0.05)
    for (i in seq_along(metrics)) {
      plot(d$n, abs(d[[metrics[i]]]), type = "b", log = "x", pch = 19, cex = 0.5,
           col = "#28758b", xlab = "n (log scale)", ylab = paste("Absolute", metrics[i]),
           main = metrics[i])
      abline(h = bounds[i], col = "#b34c38", lty = 2)
      abline(v = result$chosen, col = "#3b885b", lty = 3)
    }
  }
  dev.off()
}
