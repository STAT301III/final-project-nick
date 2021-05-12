# Elastic net tuning ----

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
  ## includes all 2-way interactions
  step_interact(outcome ~ (.)^2) %>% 
  ## eliminates columns with only 1 value
  step_zv(all_predictors())

# Define model ----
en_model <- logistic_reg(penalty = tune(), mixture = tune()) %>% 
  set_engine("glmnet")


# set-up tuning grid ----

## save tuning parameters and ranges
en_param <- parameters(en_model)

## defines tuning grid
en_grid <- grid_regular(en_param, levels = 10)


# build workflow ----
en_workflow <- workflow() %>% 
  add_model(en_model) %>% 
  add_recipe(diabetes_recipe)


# Tuning/fitting ----
en_tune <- en_workflow %>% 
  tune_grid(
    resamples = diabetes_folds,
    grid = en_grid
  )

# Write out results & workflow
save(en_tune, en_workflow, file = "model_info/en_tune.rda")