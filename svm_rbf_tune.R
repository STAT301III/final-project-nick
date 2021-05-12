# Radial basis function support vector machine tuning ----

# load package(s) ----
library(tidyverse)
library(tidymodels)

# load required objects ----
load(file = "data/diabetes_folds.rda")
load(file = "data/diabetes_train.rda")


# build recipe ----
diabetes_recipe <- recipe(outcome ~ ., data = diabetes_train) %>% 
  ## impute these variables using median since there are few missing values
  step_impute_median(glucose, bmi, blood_pressure) %>% 
  ## impute these variables using KNN since they are missing 30-50% of their values
  step_impute_knn(skin_thickness, insulin) %>% 
  ## puts numeric data on the same scale
  step_normalize(all_predictors()) %>% 
  ## eliminates columns with only 1 value
  step_zv(all_predictors())

# Define model ----
svm_rbf_model <- svm_rbf(cost = tune(), rbf_sigma = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("kernlab")

# set-up tuning grid ----

## save tuning parameters and ranges
svm_rbf_param <- parameters(svm_rbf_model)

## defines tuning grid
svm_rbf_grid <- grid_regular(svm_rbf_param, levels = 10)


# build workflow ----
svm_rbf_workflow <- workflow() %>% 
  add_model(svm_rbf_model) %>% 
  add_recipe(diabetes_recipe)


# Tuning/fitting ----
svm_rbf_tune <- svm_rbf_workflow %>% 
  tune_grid(
    resamples = diabetes_folds,
    grid = svm_rbf_grid
  )

# Write out results & workflow
save(svm_rbf_tune, svm_rbf_workflow, file = "model_info/svm_rbf_tune.rda")