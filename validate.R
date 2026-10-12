source("R/simulation.R")
e <- readRDS("results/experiments.rds")
checks <- character()
check <- function(ok, message) {
  if (!isTRUE(ok)) stop(message)
  checks <<- c(checks, paste("PASS:", message))
}
for (key in names(populations)) {
  set.seed(5533)
  slow <- replicate(23, mean(populations[[key]]$draw(7)))
  fast <- simulate_means(key, 7, B = 23)
  check(isTRUE(all.equal(slow, fast, tolerance = 1e-12)),
        paste(key, "matrix sample means agree with replicate()"))
  r <- e$primary[[key]]
  check(all(r$diagnostics$B == 30000) && all(r$diagnostics$seed == 5533),
        paste(key, "recorded B and seed are correct"))
  check(isTRUE(all.equal(simulate_means(key, 30), r$means[['30']])),
        paste(key, "n=30 reproduces the saved run exactly"))
  if (key != "cauchy") {
    check(identical(stable_candidate(r$diagnostics), r$chosen),
          paste(key, "selected n follows the five-consecutive-pass rule"))
    d <- r$diagnostics
    mcse <- d$theoretical_se/sqrt(d$B)
    check(all(abs(d$simulated_mean - d$theoretical_mean) < 6*mcse),
          paste(key, "simulated means agree with theory within 6 Monte Carlo SEs"))
    check(all(d$relative_se_error < 0.04),
          paste(key, "empirical SE agrees with theory within 4% across tested n"))
  } else {
    check(all(is.na(r$diagnostics$theoretical_se)) && all(!r$diagnostics$pass),
          "Cauchy: undefined theoretical SE is never treated as a finite-variance case")
    check(all(abs(r$diagnostics$IQR - 2) < 0.12),
          "Cauchy sample-mean IQR stays near its exact value 2")
  }
}
check(abs(normal_cdf_distance(c(-1, 0, 0, 1)) - 0.25) < 1e-12,
      "CDF distance handles ties and both sides of each jump")
check(e$alternate$seed == 5534 && identical(stable_candidate(e$alternate$diagnostics), e$alternate$chosen),
      "alternate-seed experiment uses 5534 and the same selection rule")
writeLines(c(checks, "", capture.output(sessionInfo())), "results/validation.txt")
cat(paste(checks, collapse = "\n"), "\n")
