# AI Usage Record

This project was completed with assistance from Codex. AI was used to clarify the assignment, help develop the R simulation and written analysis, and perform a final technical review. The entries below summarize the interaction instead of reproducing the student's messages word for word.

## Summary of Requests and Follow-Ups

1. I first asked Codex to explain what the instructor required for the project, including the purpose of the investigation, the required populations, the questions to answer, and the expected submission materials.
2. I then asked Codex to follow the instructor's most recent updated guidance. Distributions removed in the update were not treated as required, while unchanged requirements from the earlier instructions were retained.
3. After confirming the project scope, the five required populations, student seed 5533, simulation design, and submission structure, I asked Codex to begin working on the project.
4. After the project was completed, I asked Codex to use the R and RStudio environment on my computer to check as thoroughly as possible whether the simulations, explanations, results, and rendered reports satisfied the instructor's requirements.

## Work Assisted by Codex

- Developed analyses for the five required populations: Standard Normal, Six-Sided Die, Exponential, Binomial(5, 0.10), and Standard Cauchy.
- Created reusable R functions for simulation, diagnostics, plotting, sample-size selection, and result summaries.
- Used student seed 5533 and 30,000 repeated sample means for each primary experiment.
- Kept the sample size `n` separate from the number of repetitions `B`.
- Organized each analysis around a prediction, theoretical quantities, graphical and numerical evidence, interpretation, and limitations.
- Used histograms, full Q-Q plots, skewness, excess kurtosis, empirical CDF distance, and standard-error agreement to define and evaluate “normal enough.”
- Repeated the Exponential analysis with seed 5534 to examine the sensitivity of the selected sample size to Monte Carlo variation.
- Treated the Cauchy distribution separately because it has no finite mean or variance, and did not present its finite-run SD as a theoretical standard error.
- Generated the executive summary, five individual analyses, figures, CSV results, and reproduction instructions.

## Verification and Corrections

- Compared the batched matrix simulation with a direct `replicate()` implementation for all five populations.
- Confirmed that every primary experiment used seed 5533 and 30,000 repetitions.
- Regenerated the `n=30` results and verified exact fixed-seed reproduction.
- Checked simulated means against theoretical means and empirical standard errors against `sigma/sqrt(n)` for the finite-variance populations.
- Verified that sample-size selection followed the rule requiring five consecutive passing integer values beginning at the selected `n`.
- Checked that the empirical CDF distance handled ties and both sides of jumps for discrete distributions.
- Verified that the Cauchy sample-mean IQR remained near its theoretical value of 2 and that finite-variance formulas were not applied to it.
- Reran `run_simulations.R` and `validate.R` with the R 4.6.1 installation used by RStudio. All automated validation checks passed.
- Rendered the executive summary and all five analyses with RStudio's bundled Quarto installation. All six HTML pages were generated successfully.
- Checked the local links, figures, and supporting resources in the rendered reports and found no broken references.
- Reviewed all five final PDFs for predictions, theoretical comparisons, graphical evidence, interpretation, limitations, and page rendering. No statistical errors requiring correction were found.

## Final Note

This record describes the role of AI in the project. Codex assisted with the simulation code, written analysis, and verification process. Before submission, I reviewed the instructor's guidance, the executive summary, and the five population analyses. The selected sample sizes are empirical results under the stated practical criteria, not universal mathematical constants.
