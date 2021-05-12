# Polynomial support vector machine cross validation ----

# Load package(s) ----
library(tidyverse)
library(tidymodels)

# load required objects ----
load(file = "data/diabetes_folds.rda")
load(file = "model_info/svm_poly_tune.rda")

# update workflow with optimal value(s) for hyperparameter(s) ----
svm_poly_workflow <- svm_poly_workflow %>% 
  finalize_workflow(parameters = select_best(svm_poly_tune, metric = "roc_auc"))

# apply updated workflow to resamples ----
svm_poly_cv <- fit_resamples(svm_poly_workflow, resamples = diabetes_folds)

# Write out results & workflow ----
save(svm_poly_cv, svm_poly_workflow, file = "model_info/svm_poly_cv.rda")