# K-nearest neighbors cross validation ----

# Load package(s) ----
library(tidyverse)
library(tidymodels)

# load required objects ----
load(file = "data/diabetes_folds.rda")
load(file = "model_info/knn_tune.rda")

# update workflow with optimal value(s) for hyperparameter(s) ----
knn_workflow <- knn_workflow %>% 
  finalize_workflow(parameters = select_best(knn_tune, metric = "roc_auc"))

# apply updated workflow to resamples ----
knn_cv <- fit_resamples(knn_workflow, resamples = diabetes_folds)

# Write out results & workflow ----
save(knn_cv, knn_workflow, file = "model_info/knn_cv.rda")