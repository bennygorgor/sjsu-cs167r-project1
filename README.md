# How Fast Does Normal Happen?

**An R Monte Carlo investigation of the Central Limit Theorem.**

The project studies how the sampling distribution of a mean changes as sample size grows. It follows the revised five-population assignment and retains unchanged original requirements. Every primary experiment uses seed **5533** and **30,000 repetitions**. Three extra-credit processes are outside this project's scope.

## Findings and final table

There is **no universal n=30 rule**. Normal means are exactly normal from n=1; other finite-variance populations improve at different rates; Cauchy means never approach a normal distribution.

| Population | Selected n | Empirical mean | Empirical SE | Theoretical SE | Skewness | Excess kurtosis | CDF distance |
|---|---:|---:|---:|---:|---:|---:|---:|
| Standard Normal | 1 | -0.0071 | 0.9949 | 1.0000 | 0.0239 | 0.0199 | 0.007284 |
| Six-Sided Die | 6 | 3.5000 | 0.7008 | 0.6972 | 0.0072 | -0.2125 | 0.049965 |
| Exponential (rate 1) | 51 | 0.9993 | 0.1398 | 0.1400 | 0.2958 | 0.1967 | 0.021036 |
| Binomial (size 5, p 0.10) | 63 | 0.4997 | 0.0846 | 0.0845 | 0.1579 | 0.0374 | 0.048375 |
| Standard Cauchy | None | — | — | — | — | — | — |

The selected n is the smallest tested integer beginning **five consecutive passing sample sizes**, followed by graphical review. It is an empirical selection under these stated tolerances, not an exact mathematical cutoff:

- Absolute skewness ≤0.30.
- Absolute **excess** kurtosis ≤0.50 (normal reference = 0).
- Maximum empirical CDF distance from the theoretical normal ≤0.05.
- Relative empirical-SE error ≤5%.

The initial finite-variance grid was 1, 2, 3, 5, 10, 20, 30, 50, 75, 100, 150, 200. Integer refinement evaluated every n from 1 through the first coarse passing value plus four, extending if necessary. Histograms and full Q–Q plots show both improvements and remaining tail/discreteness effects. These criteria concern moderate global approximation accuracy, not exact extreme-tail probabilities.

At n=30, normal and die pass. Exponential retains excessive skewness (0.3781). Binomial passes the skewness tolerance but fails the uncorrected CDF tolerance (0.070367); its lattice jumps still matter. Cauchy has no finite mean or variance, so its sample SD is not a theoretical standard error.

**Uncertainty matters.** The separate exponential experiment with seed 5534 selects n=39, versus 51 with seed 5533; both reject n=30. The die's n=6 is also borderline (CDF distance 0.049965). The report therefore does not present these integers as universal constants. No seed was changed to obtain a preferred primary answer.

**Why the populations differ:** normality is exact for normal means; symmetry and bounded tails help the die; right skew slows the exponential case; discreteness affects the binomial case; and Cauchy violates the finite-variance assumption altogether. For Cauchy, the sample mean remains standard Cauchy for every n: its observed IQR is about 2 at both n=1 and n=1000.

## Read the analysis

After downloading the complete folder, open **[the rendered executive summary](reports/index.html)** in a browser. Preserve the entire `reports` folder, because the HTML uses accompanying assets. GitHub displays the summary on this README directly; a GitHub HTML file link may show source/download instead of a live web page.

| Analysis | Editable Quarto source | Rendered HTML |
|---|---|---|
| Normal | [Source](analyses/01-normal.qmd) | [Report](reports/analyses/01-normal.html) |
| Fair die | [Source](analyses/02-six-sided-die.qmd) | [Report](reports/analyses/02-six-sided-die.html) |
| Exponential and second seed | [Source](analyses/03-exponential.qmd) | [Report](reports/analyses/03-exponential.html) |
| Small binomial | [Source](analyses/04-binomial-small.qmd) | [Report](reports/analyses/04-binomial-small.html) |
| Cauchy | [Source](analyses/05-cauchy.qmd) | [Report](reports/analyses/05-cauchy.html) |

The [AI usage record](AI_USAGE.md) summarizes the requests, Codex-assisted work, and the checks performed before submission.

## Reproduce

Install [R](https://cran.r-project.org/) and [Quarto](https://quarto.org/docs/get-started/). Install rendering packages once from R:

```r
install.packages(c("knitr", "rmarkdown"), repos = "https://cloud.r-project.org")
```

From this repository's root, run:

```bash
Rscript run_simulations.R
Rscript validate.R
quarto render
```

The simulation itself needs **only base R**. Rendering executes the Quarto analysis code against the saved experiment object. The first command recreates every experiment and plot; the second runs numerical and reproducibility checks; the third recreates all six HTML reports.

Results were generated with R 4.6.1 and rendered with Quarto 1.10.18. RNG settings are Mersenne-Twister, Inversion, and Rejection. The R software session is recorded in [session-info.txt](results/session-info.txt). Exact last-bit results can depend on the platform and software versions.

## Files and verification

- [R/simulation.R](R/simulation.R): generators, batched means, diagnostics, search, and plotting.
- [run_simulations.R](run_simulations.R): runs all five populations and the second-seed exponential experiment.
- `results/*.csv`: full diagnostic rows for every tested sample size.
- `results/experiments.rds`: all diagnostics plus raw means at selected comparison sizes; other means are reproducible from code.
- `figures/`: population plots, histograms/Q–Q plots, and convergence diagnostics.
- [validate.R](validate.R) and [validation.txt](results/validation.txt): equivalence to `replicate()`, fixed-seed reproduction, theoretical mean/SE checks, CDF ties, selection-rule checks, and Cauchy IQR checks.
- `index.qmd` and `analyses/*.qmd`: explanatory source documents.

The distinction between n and B is essential: n is observations per sample, B is the number of repeated samples. For Binomial(5,0.10), the parameter 5 describes the trials within each individual observation; it is not the project sample size n.

## Assignment scope and submission

The revised `clt_project_1_student_guidance.qmd` supersedes the original Class 06 project instructions where they differ. The old approximately-12-files expectation is replaced by the revised five required populations. Separate analyses, initial predictions, a justified sample-size search, second-seed reproducibility, a final comparison, and AI documentation are retained.

Course sources: Greg Labmeier, *CLT Project 1: What I Am Looking For* (revised guidance), and *Project 1: How Fast Does Normal Happen?* (original Class 06 instructions), both supplied with the assignment. The Canvas screenshot lists a GitHub URL submission due October 5 at 18:00.

This folder is prepared for a GitHub repository; it has not been published or submitted. Upload the complete project contents, then submit the repository URL through Canvas. Review the analysis and code before submission, and append any actual additional AI interactions to the log.
