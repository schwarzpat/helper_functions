library(readxl)
library(tidyverse)
library(timetk)
library(lubridate)
library(modeltime)
library(modeltime.ensemble)
library(tidymodels)
library(prophet)

# Load data
data_tbl <- read_excel("your_file.xlsx") %>%
  mutate(date = as_date(date)) %>%
  arrange(date)

# Check for regressors
regressors <- setdiff(names(data_tbl), c("date", "value"))

# Split data
splits <- time_series_split(data_tbl, assess = "12 months", cumulative = TRUE)

# Recipes
rec_arima <- recipe(value ~ date + all_of(regressors), data = training(splits))

rec_prophet <- recipe(value ~ date + all_of(regressors), data = training(splits)) %>%
  step_mutate(ds = date, y = value)

# Models

# ARIMA with regressors
model_arima <- arima_reg() %>%
  set_engine("auto_arima") %>%
  workflow() %>%
  add_recipe(rec_arima) %>%
  fit(training(splits))

# Prophet with regressors
model_prophet <- prophet_reg() %>%
  set_engine("prophet") %>%
  workflow() %>%
  add_recipe(rec_prophet) %>%
  fit(training(splits))

# Model table
models_tbl <- modeltime_table(
  model_arima,
  model_prophet
)

# Calibration
calibration_tbl <- models_tbl %>%
  modeltime_calibrate(new_data = testing(splits))

# Ensemble (average)
ensemble_fit <- calibration_tbl %>%
  ensemble_average(type = "mean")

# Forecasts
forecast_tbl <- modeltime_table(ensemble_fit) %>%
  modeltime_forecast(
    new_data = testing(splits),
    actual_data = data_tbl
  )

# Plot
forecast_tbl %>%
  plot_modeltime_forecast()
