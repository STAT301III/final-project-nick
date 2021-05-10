## Final Project Setup

## load package(s) ----
library(tidyverse)
library(tidymodels)
library(naniar)

## set seed
set.seed(2021)

## load data ----
diabetes_data <- read_csv("data/processed/diabetes.csv") %>% 
  janitor::clean_names() %>% 
  mutate(outcome = factor(outcome, levels = c("1", "0"), labels = c("Yes", "No")))

## dimensions
dim(diabetes_data)
## 768 observations, 8 predictor variables, and 1 target variable

## quick look at missingness
## missing values in some variables indicated by 0 not NA (except for pregnancies - can assume 0 pregnancies is possible)
## replaces values of 0 with NA
diabetes_data$insulin[diabetes_data$insulin == 0] <- NA
diabetes_data$skin_thickness[diabetes_data$skin_thickness == 0] <- NA
diabetes_data$bmi[diabetes_data$bmi == 0] <- NA
diabetes_data$blood_pressure[diabetes_data$blood_pressure == 0] <- NA
diabetes_data$glucose[diabetes_data$glucose == 0] <- NA

gg_miss_var(diabetes_data)

miss_var_summary(diabetes_data)
## blood pressure, bmi, & glucose each missing < 5% of their values - easy to impute missing values
## insulin and skin thickness missing over 20% of their values - problematic because we already don't have that many predictors and insulin is probably a very important predictor

miss_case_summary(diabetes_data) %>% 
  count(n_miss)
## majority of observations aren't missing more than 2 variables


## quick look at target variable distribution
ggplot(diabetes_data, aes(outcome)) + 
  geom_bar(fill = "#add8e6") + 
  theme_minimal() + 
  labs(
    x = "Diagnosed with diabetes?",
    y = "Count",
    title = "Target Variable Distribution"
  ) 

diabetes_data %>% 
  count(outcome) %>% 
  mutate(prop_total = n/sum(n))
## there's a large class imbalance (35% of people were diagnosed with diabetes while 65% were not)

## splitting data ----
diabetes_split <- initial_split(diabetes_data, prop = 0.75, strata = outcome)
diabetes_train <- training(diabetes_split)
diabetes_folds <- vfold_cv(diabetes_train, v = 5, repeats = 3)

## save split info/training set as .rda objects
save(diabetes_train, file = "data/diabetes_train.rda")
save(diabetes_split, file = "data/diabetes_split.rda")
save(diabetes_folds, file = "data/diabetes_folds.rda")

## set up folds ----

## continued EDA
bmi_avg <- diabetes_train %>% 
  group_by(outcome) %>% 
  summarise(avg_bmi = mean(bmi, na.rm = TRUE))
ggplot(bmi_avg, aes(outcome, avg_bmi, fill = outcome)) + 
  geom_bar(stat = "identity", color = "black") + 
  theme_minimal() + 
  labs(x = "Diabetes", y = "Average body mass index (BMI)") + 
  theme(legend.position = "none")
## higher body mass index (bmi) appears to be correlated with diabetes

ggplot(diabetes_train, aes(age, fill = outcome)) + 
  geom_histogram(binwidth = 10, color = "black") +
  theme_minimal() +
  labs(x = "Age", y = "Count", fill = "Diabetes")
## higher proportion of middle age people with diabetes (30 - 60 years old) - obviously younger people are healthier but older people appear to have lower proportions of diabetes maybe because of better diet?
## age is also right-skewed

glucose_avg <- diabetes_train %>% 
  group_by(outcome) %>% 
  summarise(avg_glucose = mean(glucose, na.rm = TRUE))
ggplot(glucose_avg, aes(outcome, avg_glucose, fill = outcome)) + 
  geom_bar(stat = "identity", color = "black") + 
  theme_minimal() + 
  labs(x = "Diabetes", y = "Average blood glucose") + 
  theme(legend.position = "none")
## 2 hours post glucose tolerance test, those with diabetes had elevated blood glucose levels compared to those without it - probably related to insulin insensitivity

insulin_avg <- diabetes_train %>% 
  group_by(outcome) %>% 
  summarise(avg_insulin = mean(insulin, na.rm = TRUE))
ggplot(insulin_avg, aes(outcome, avg_insulin, fill = outcome)) + 
  geom_bar(stat = "identity", color = "black") + 
  theme_minimal() + 
  labs(x = "Diabetes", y = "Average insulin")
## average 2 hour serum insulin level is much higher in patients with diabetes

ggplot(diabetes_train, aes(pregnancies)) + 
  geom_histogram(binwidth = 1, color = "black") + 
  theme_minimal()
## pregnancy is highly right-skewed - should normalize data

ggplot(diabetes_train, aes(bmi, skin_thickness)) + 
  geom_point(color = "#fa8072") + 
  theme_minimal() + 
  labs(x = "Body Mass Index (BMI)", y = "Skin Thickness")
## BMI and skin thickness are highly correlated - both are a measure of body fat levels

ggplot(diabetes_train, aes(insulin, glucose)) + 
  geom_point(color = "#30D5C8") + 
  theme_minimal() +
  labs(x = "Serum Insulin", y = "Blood Glucose")
## higher 2 hour serum insulin levels appear to be correlated with higher blood glucose levels during the glucose tolerance test 

ggplot(diabetes_data, aes(pregnancies, glucose, color = outcome)) + 
  geom_jitter() + 
  theme_minimal() + 
  labs(x = "Number of Pregnancies", y = "Blood Glucose", color = "Diabetes")
## not a huge correlation between number of pregnancies and blood glucose levels during the glucose tolerance test - maybe it's not a great predictor of diabetes



