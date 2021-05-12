# Radial basis function support vector machine cross validation ----

# Load package(s) ----
library(tidyverse)
library(tidymodels)

# load required objects ----
load(file = "data/diabetes_folds.rda")
load(file = "model_info/svm_rbf_tune.rda")

# update workflow with optimal value(s) for hyperparameter(s) ----
svm_rbf_workflow <- svm_rbf_workflow %>% 
  finalize_workflow(parameters = select_best(svm_rbf_tune, metric = "roc_auc"))

# apply updated workflow to resamples ----
svm_rbf_cv <- fit_resamples(svm_rbf_workflow, resamples = diabetes_folds)

# Write out results & workflow ----
save(svm_rbf_cv, svm_rbf_workflow, file = "model_info/svm_rbf_cv.rda")