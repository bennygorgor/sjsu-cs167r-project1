# Usage: Rscript run_simulations.R (working directory = this project folder)
source("R/simulation.R")
dir.create("results", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
results <- list()
for (key in names(populations)) {
  cat("Simulating", key, "...\n")
  r <- run_population(key)
  results[[key]] <- r
  write.csv(r$diagnostics, file.path("results", paste0(key, ".csv")), row.names = FALSE, na = "")
  plot_population(r, file.path("figures", paste0(key, "-population.png")))
  plot_diagnostics(r, file.path("figures", paste0(key, "-diagnostics.png")))
  plot_convergence(r, file.path("figures", paste0(key, "-convergence.png")))
  # Keep diagnostic rows for every n, but retain raw means only at selected
  # comparison sizes. This keeps the downloadable repository compact.
  keep_n <- unique(c(1L, 30L, if (is.na(r$chosen)) 1000L else c(max(1L, r$chosen-1L), r$chosen + 0:4)))
  results[[key]]$means <- r$means[intersect(as.character(keep_n), names(r$means))]
  cat("Selected n:", r$chosen, "\n")
}
cat("Alternate-seed exponential experiment (5534) ...\n")
alternate <- run_population("exponential", seed = 5534L)
alternate$means <- alternate$means[intersect(as.character(c(30L, alternate$chosen, results$exponential$chosen)), names(alternate$means))]
write.csv(alternate$diagnostics, "results/exponential-seed-5534.csv", row.names = FALSE)
summary_rows <- lapply(results, function(r) {
  n <- if (is.na(r$chosen)) max(r$diagnostics$n) else r$chosen
  row <- r$diagnostics[r$diagnostics$n == n, ]
  row$selected_n <- r$chosen
  row
})
summary <- do.call(rbind, summary_rows)
rownames(summary) <- NULL
write.csv(summary, "results/summary.csv", row.names = FALSE, na = "")
saveRDS(list(primary = results, alternate = alternate), "results/experiments.rds", compress = "gzip")
capture.output(sessionInfo(), file = "results/session-info.txt")
cat("Alternate-seed selected n:", alternate$chosen, "\n")
print(summary[, c("population", "selected_n", "simulated_mean", "simulated_se", "skewness", "excess_kurtosis", "cdf_distance")])
