# Random forest cross validation ----

# Load package(s) ----
library(tidyverse)
library(tidymodels)

# load required objects ----
load(file = "data/diabetes_folds.rda")
load(file = "model_info/rf_tune.rda")

# update workflow with optimal value(s) for hyperparameter(s) ----
rf_workflow <- rf_workflow %>% 
  finalize_workflow(parameters = select_best(rf_tune, metric = "roc_auc"))

# apply updated workflow to resamples ----
rf_cv <- fit_resamples(rf_workflow, resamples = diabetes_folds)

# Write out results & workflow ----
save(rf_cv, rf_workflow, file = "model_info/rf_cv.rda")