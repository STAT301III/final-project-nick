# Elastic net cross validation ----

# Load package(s) ----
library(tidyverse)
library(tidymodels)

# load required objects ----
load(file = "data/diabetes_folds.rda")
load(file = "model_info/en_tune.rda")

# update workflow with optimal value(s) for hyperparameter(s) ----
en_workflow <- en_workflow %>% 
  finalize_workflow(parameters = select_best(en_tune, metric = "roc_auc"))

# apply updated workflow to resamples ----
en_cv <- fit_resamples(en_workflow, resamples = diabetes_folds)

# Write out results & workflow ----
save(en_cv, en_workflow, file = "model_info/en_cv.rda")