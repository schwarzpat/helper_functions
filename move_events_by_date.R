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
