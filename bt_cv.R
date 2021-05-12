# Boosted tree cross validation ----

# Load package(s) ----
library(tidyverse)
library(tidymodels)

# load required objects ----
load(file = "data/diabetes_folds.rda")
load(file = "model_info/bt_tune.rda")

# update workflow with optimal value(s) for hyperparameter(s) ----
bt_workflow <- bt_workflow %>% 
  finalize_workflow(parameters = select_best(bt_tune, metric = "roc_auc"))

# apply updated workflow to resamples ----
bt_cv <- fit_resamples(bt_workflow, resamples = diabetes_folds)

# Write out results & workflow ----
save(bt_cv, bt_workflow, file = "model_info/bt_cv.rda")