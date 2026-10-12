source("R/simulation.R")
options(knitr.kable.NA = "Not applicable")
experiments <- readRDS("results/experiments.rds")
fmt <- function(x, digits = 4) formatC(x, format = "f", digits = digits)
result_for <- function(key) experiments$primary[[key]]
row_at <- function(result, n) result$diagnostics[result$diagnostics$n == n, ]
show_table <- function(d, digits = 4) {
  print(knitr::kable(d, digits = digits, row.names = FALSE))
}
decision_table <- function(result) {
  d <- result$diagnostics
  ns <- if (is.na(result$chosen)) d$n else
    sort(unique(c(1, 30, max(1, result$chosen - 1), result$chosen + 0:4, 100, 200)))
  cols <- c("n", "simulated_mean", "simulated_se", "theoretical_se",
            "skewness", "excess_kurtosis", "cdf_distance", "pass")
  if (result$key == "cauchy") cols <- c("n", "simulated_mean", "simulated_se", "median", "IQR", "max_abs_mean")
  x <- d[d$n %in% ns, cols, drop = FALSE]
  names(x) <- gsub("_", " ", names(x))
  show_table(x)
}
summary_table <- function() {
  rows <- lapply(experiments$primary, function(r) {
    if (is.na(r$chosen)) return(data.frame(Population = populations[[r$key]]$name,
      `Selected n` = "None", Mean = "Not applicable", `Empirical SE` = "Not applicable",
      `Theoretical SE` = "Not applicable", Skewness = "Not applicable",
      `Excess kurtosis` = "Not applicable", `CDF distance` = "Not applicable",
      check.names = FALSE))
    a <- row_at(r, r$chosen)
    data.frame(Population = populations[[r$key]]$name, `Selected n` = as.character(r$chosen),
      Mean = fmt(a$simulated_mean), `Empirical SE` = fmt(a$simulated_se),
      `Theoretical SE` = fmt(a$theoretical_se), Skewness = fmt(a$skewness),
      `Excess kurtosis` = fmt(a$excess_kurtosis), `CDF distance` = fmt(a$cdf_distance),
      check.names = FALSE)
  })
  print(knitr::kable(do.call(rbind, rows), row.names = FALSE))
}
