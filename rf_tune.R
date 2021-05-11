# Random forest tuning ----

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
rf_model <- rand_forest(mtry = tune(), min_n = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("ranger")


# set-up tuning grid ----

## save tuning parameters and ranges
rf_param <- parameters(rf_model) 

## defines tuning grid
rf_grid <- grid_regular(rf_param, levels = 10)


# build workflow ----
rf_workflow <- workflow() %>% 
  add_model(rf_model) %>% 
  add_recipe(diabetes_recipe)


# Tuning/fitting ----
rf_tune <- rf_workflow %>% 
  tune_grid(
    resamples = diabetes_folds,
    grid = rf_grid
  )

# Write out results & workflow
save(rf_tune, rf_workflow, file = "model_info/rf_tune.rda")