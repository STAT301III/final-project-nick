# K-nearest neighbors tuning ----

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
knn_model <- nearest_neighbor(neighbors = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("kknn")


# set-up tuning grid ----

## save tuning parameters and ranges
knn_param <- parameters(knn_model) 

## defines tuning grid
knn_grid <- grid_regular(knn_param, levels = 10)


# build workflow ----
knn_workflow <- workflow() %>% 
  add_model(knn_model) %>% 
  add_recipe(diabetes_recipe)


# Tuning/fitting ----
knn_tune <- knn_workflow %>% 
  tune_grid(
    resamples = diabetes_folds,
    grid = knn_grid
  )

# Write out results & workflow
save(knn_tune, knn_workflow, file = "model_info/knn_tune.rda")