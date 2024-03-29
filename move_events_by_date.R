# Load necessary libraries
library(testthat)
library(dplyr)
library(lubridate)

# Function to adjust payments
adjust_payments <- function(df) {
  df <- df %>%
    mutate(weekend = ifelse(wday(date) %in% c(1, 7), "Yes", "No"))

  for (i in seq_len(nrow(df))) {
    if (df$holiday[i] == "Yes" || df$weekend[i] == "Yes") {
      j <- i - 1
      while (j >= 1 && (df$holiday[j] == "Yes" || df$weekend[j] == "Yes")) {
        j <- j - 1
      }
      
      if (j >= 1) {
        if (df$pay_day[i] == 1) {
          df$pay_day[j] <- df$pay_day[j] + df$pay_day[i]
          df$pay_day[i] <- 0
        }
        if (df$pension[i] == 1) {
          df$pension[j] <- df$pension[j] + df$pension[i]
          df$pension[i] <- 0
        }
      } else {
        df$pay_day[i] <- 0
        df$pension[i] <- 0
      }
    }
  }

  return(df)
}



# Basic Test
test_that("Basic test", {
  df <- tibble(
    date = as.Date(c("2022-03-01", "2022-03-02")),
    holiday = c("No", "Yes"),
    pay_day = c(0, 1),
    pension = c(0, 0)
  )
  df <- adjust_payments(df)
  expect_equal(df$pay_day, c(1, 0))
})

# Consecutive Holidays Test
test_that("Consecutive holidays test", {
  df <- tibble(
    date = as.Date(c("2022-01-11", "2022-01-12", "2022-01-13")),
    holiday = c("No", "Yes", "Yes"),
    pay_day = c(0, 0, 1),
    pension = c(0, 0, 0)
  )
  df <- adjust_payments(df)
  expect_equal(df$pay_day, c(1, 0, 0))
})

# Weekend and Holiday Test
test_that("Weekend and holiday test", {
  df <- tibble(
    date = as.Date(c("2022-01-01", "2022-01-02", "2022-01-03", "2022-01-04")),
    holiday = c("No", "Yes", "No", "Yes"),
    pay_day = c(0, 0, 0, 1),
    pension = c(0, 0, 0, 0)
  )
  df <- adjust_payments(df)
  expect_equal(df$pay_day, c(0, 0, 1, 0))
})

# No Movement Test
test_that("No movement test", {
  df <- tibble(
    date = as.Date(c("2022-01-03", "2022-01-04")),
    holiday = c("No", "No"),
    pay_day = c(0, 1),
    pension = c(0, 0)
  )
  df <- adjust_payments(df)
  expect_equal(df$pay_day, c(0, 1))
})

# Edge Case Test
test_that("Edge case test", {
  df <- tibble(
    date = as.Date(c("2022-01-01")),
    holiday = c("Yes"),
    pay_day = c(1),
    pension = c(0)
  )
  df <- adjust_payments(df)
  expect_equal(df$pay_day, c(0))
})

test_that("Basic test for pension", {
  df <- tibble(
    date = as.Date(c("2022-01-03", "2022-01-04")),
    holiday = c("No", "Yes"),
    pay_day = c(0, 0),
    pension = c(0, 1)
  )
  df <- adjust_payments(df)
  expect_equal(df$pension, c(1, 0))
})

# Consecutive Holidays Test for Pension
test_that("Consecutive holidays test for pension", {
  df <- tibble(
    date = as.Date(c("2022-01-11", "2022-01-12", "2022-01-13")),
    holiday = c("No", "Yes", "Yes"),
    pay_day = c(0, 0, 0),
    pension = c(0, 0, 1)
  )
  df <- adjust_payments(df)
  expect_equal(df$pension, c(1, 0, 0))
})

# Weekend and Holiday Test for Pension
test_that("Weekend and holiday test for pension", {
  df <- tibble(
    date = as.Date(c("2022-01-01", "2022-01-02", "2022-01-03", "2022-01-04")),
    holiday = c("No", "Yes", "No", "Yes"),
    pay_day = c(0, 0, 0, 0),
    pension = c(0, 0, 0, 1)
  )
  df <- adjust_payments(df)
  expect_equal(df$pension, c(0, 0, 1, 0))
})

# No Movement Test for Pension
test_that("No movement test for pension", {
  df <- tibble(
    date = as.Date(c("2022-01-03", "2022-01-04")),
    holiday = c("No", "No"),
    pay_day = c(0, 0),
    pension = c(0, 1)
  )
  df <- adjust_payments(df)
  expect_equal(df$pension, c(0, 1))
})

# Edge Case Test for Pension
test_that("Edge case test for pension", {
  df <- tibble(
    date = as.Date(c("2022-01-01")),
    holiday = c("Yes"),
    pay_day = c(0),
    pension = c(1)
  )
  df <- adjust_payments(df)
  expect_equal(df$pension, c(0))
})

# Determine first week day of a quarter


# Define a function to find the first weekday of a quarter
find_first_weekday_of_quarter <- function(date) {
  while (wday(date) %in% c(6, 7)) { # 6 = Saturday, 7 = Sunday with ISO default
    date <- date + 1
  }
  return(date)
}

# Create a data frame with a sequence of dates
df <- tibble(
  date = seq(ymd('2023-01-01'), ymd('2024-01-01'), by = 'day')
)

# Add a column to indicate the first day of the quarter that's not a weekend
df <- df %>%
  rowwise() %>%
  mutate(
    firstDayOfQuarter = as.integer(date == find_first_weekday_of_quarter(floor_date(date, "quarter")))
  ) %>%
  ungroup() # to return to standard evaluation

# Display the result with all dates and their indicator
print(df)

##########
adjust_payments <- function(df, holiday_col, weekend_col, pay_day_col, pension_col) {
  # Calculate weekend based on date column
  df <- df %>%
    mutate({{weekend_col}} := ifelse(wday(date) %in% c(1, 7), "Yes", "No"))

  for (i in seq_len(nrow(df))) {
    if (df[[holiday_col]][i] == "Yes" || df[[weekend_col]][i] == "Yes") {
      j <- i - 1
      while (j >= 1 && (df[[holiday_col]][j] == "Yes" || df[[weekend_col]][j] == "Yes")) {
        j <- j - 1
      }
      
      if (j >= 1) {
        if (df[[pay_day_col]][i] == 1) {
          df[[pay_day_col]][j] <- df[[pay_day_col]][j] + df[[pay_day_col]][i]
          df[[pay_day_col]][i] <- 0
        }
        if (df[[pension_col]][i] == 1) {
          df[[pension_col]][j] <- df[[pension_col]][j] + df[[pension_col]][i]
          df[[pension_col]][i] <- 0
        }
      } else {
        df[[pay_day_col]][i] <- 0
        df[[pension_col]][i] <- 0
      }
    }
  }

  return(df)
}
adjusted_df <- adjust_payments(df, "holiday_column_name", "weekend_column_name", "pay_day_column_name", "pension_column_name")


######

adjust_payments <- function(df, holiday_cols, weekend_col, pay_day_cols) {
  df <- df %>%
    mutate({{weekend_col}} := ifelse(wday(date) %in% c(1, 7), "Yes", "No"))

  if (length(holiday_cols) != length(pay_day_cols)) {
    stop("The number of holiday columns must match the number of pay day columns.")
  }

  for (idx in seq_along(holiday_cols)) {
    holiday_col <- holiday_cols[idx]
    pay_day_col <- pay_day_cols[idx]

    for (i in seq_len(nrow(df))) {
      if (df[[holiday_col]][i] == "Yes" || df[[weekend_col]][i] == "Yes") {
        j <- i - 1
        while (j >= 1 && (df[[holiday_col]][j] == "Yes" || df[[weekend_col]][j] == "Yes")) {
          j <- j - 1
        }
        
        if (j >= 1 && df[[pay_day_col]][i] == 1) {
          df[[pay_day_col]][j] <- df[[pay_day_col]][j] + df[[pay_day_col]][i]
          df[[pay_day_col]][i] <- 0
        } else {
          df[[pay_day_col]][i] <- 0
        }
      }
    }
  }

  return(df)
}
holiday_columns = c("holiday_col1", "holiday_col2")
pay_day_columns = c("pay_day_col1", "pay_day_col2")

adjusted_df <- adjust_payments(df, holiday_columns, "weekend_column_name", pay_day_columns)




