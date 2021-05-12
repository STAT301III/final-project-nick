## Model Selection and Evaluation


## load package(s) ----
library(tidyverse)
library(tidymodels)


# Seed
set.seed(3013)


## load data ----

# vector of model abbreviations
model_names <- c("knn", "rf", "bt", "en", "svm_poly", "svm_rbf")

# appends prefix and suffix to abbreviations to create full file name
file_names <- str_c("model_info/", model_names, "_cv.rda")

# loads cross-validation results/updated workflows
for (name in file_names) {
  load(file = name)
}


## compare models using performance metrics ----
cv_results <- tibble(
  model_type = c("knn", "rf", "bt", "svm_poly", "svm_rbf", "en"),
  cv_info = list(knn_cv, rf_cv, bt_cv, svm_poly_cv, svm_rbf_cv, en_cv),
  assessment_info = map(cv_info, collect_metrics)
)

## formats results as tabble 
cv_results %>% 
  select(model_type, assessment_info) %>% 
  unnest(assessment_info) %>% 
  filter(.metric == "roc_auc") %>% 
  select(-n, -.estimator, -.config) %>% 
  mutate(lower = mean - std_err, upper = mean + std_err) %>% 
  arrange(desc(mean))
## radial basis function support vector machine had highest average roc_auc BUT it wasn't significant...we'll still go with it anyway

## saves results
save(cv_results, file = "model_info/cv_results.rda")


## fit winning model to whole training set ----

## load training set
load("data/diabetes_train.rda")

## fit winning model
svm_rbf_fit <- fit(svm_rbf_workflow, data = diabetes_train)


## evaluate model on test set ----

## load split information
load("data/diabetes_split.rda")

## create testing set
diabetes_test <- testing(diabetes_split)

## predict outcome in test set using trained model
test_pred <- predict(svm_rbf_fit, new_data = diabetes_test, type = "prob") %>% 
  bind_cols(diabetes_test %>% select(outcome)) 

## calculates performance metric
test_results <- roc_auc(data = test_pred, truth = outcome, estimate = .pred_Yes) 

## saves results
save(test_results, file = "model_info/test_results.rda")
