## Model Selection and Evaluation

## load package(s) ----
library(tidyverse)
library(tidymodels)

## load data ----

# vector of model abbreviations
model_names <- c("knn", "rf", "bt", "en", "svm_poly", "svm_rbf")

model_names <- str_c("model_info/", model_names, "_cv.rda")

model_names %>% 
  map(load)
