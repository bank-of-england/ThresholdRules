source("model.R") 
source("utils.R")

# The model uses only a few packages.
# Users need to install 'plyr' and either 'lpSolveAPI' or 'Rglpk', depending which
# solver for the mixed integer program is used. The 'glpk' solver is expected to be faster.
packages <- c("plyr", "lpSolveAPI")
lapply(packages, install.packages)

# Creating an artificial toy data set.
# The first column contains the outcome variable, the remaining columns contain
# the metrics for which the threshold should be calibrated.
toy_data <- data.frame(
            failure = c(1, 1, 1, 0, 0, 1, 1),
            metric1 = c(2,7,3,4,7, 7,9),
            metric2 = c(9, 8, 4, 4, 1, 2, 7)
)


# The model assumes that lower values on a metric mean a higher risk of failure.
# Metrics for which higher values mean lower risks need to be recoded:
toy_data$metric2 <- - toy_data$metric2 

# Calibrate thresholds at a minimum hit rate of 50%:
rule <- optimiseRule(toy_data, minimum_hit_rate = .5, solver = "lpsolve") 

# Apply the rule to obtain predictions 
predictRule(rule, toy_data[,-1])




