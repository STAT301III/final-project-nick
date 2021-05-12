# Boosted tree tuning ----

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
bt_model <- boost_tree(mtry = tune(), min_n = tune(), learn_rate = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("xgboost")


# set-up tuning grid ----

## save tuning parameters and ranges
bt_param <- parameters(bt_model) %>% 
  update(mtry = mtry(range = c(2L, 4L)))

## defines tuning grid
bt_grid <- grid_regular(bt_param, levels = 5)


# build workflow ----
bt_workflow <- workflow() %>% 
  add_model(bt_model) %>% 
  add_recipe(diabetes_recipe)


# Tuning/fitting ----
bt_tune <- bt_workflow %>% 
  tune_grid(
    resamples = diabetes_folds,
    grid = bt_grid
  )

# Write out results & workflow
save(bt_tune, bt_workflow, file = "model_info/bt_tune.rda")