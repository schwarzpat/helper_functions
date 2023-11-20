# Sample data
data <- data.frame(
  Date = as.Date('2023-01-01') + 0:9,
  FI = c("None", "Holiday", "None", "None", "None", "None", "None", "None", "None", "None"),
  NO = c("None", "None", "Holiday", "None", "None", "None", "None", "None", "None", "None"),
  DK = c("None", "None", "None", "Holiday", "None", "None", "None", "None", "None", "None"),
  SE = c("None", "None", "None", "None", "Holiday", "None", "None", "None", "None", "None"),
  Weekend = c(1, 0, 0, 0, 0, 0, 1, 1, 0, 0)
)

# Convert holiday columns to binary
data$FI <- ifelse(data$FI != "None", 1, 0)
data$NO <- ifelse(data$NO != "None", 1, 0)
data$DK <- ifelse(data$DK != "None", 1, 0)
data$SE <- ifelse(data$SE != "None", 1, 0)

# Function to determine if the next day is a workday after a holiday for a specific country
is_next_workday_after_holiday <- function(holiday, weekend) {
  length_h <- length(holiday)
  next_workday_after_holiday <- rep(0, length_h)

  for (i in 1:(length_h - 1)) {
    if (holiday[i] == 1 && !weekend[i + 1] && holiday[i + 1] == 0) {
      next_workday_after_holiday[i + 1] <- 1
    }
  }

  # Adjust for holidays followed by weekends
  for (i in 1:(length_h - 2)) {
    if (holiday[i] == 1 && weekend[i + 1]) {
      # Find the next weekday that is not a holiday
      j <- i + 2
      while(j <= length_h && (weekend[j] || holiday[j])) {
        j <- j + 1
      }
      if(j <= length_h && next_workday_after_holiday[j] == 0) {
        next_workday_after_holiday[j] <- 1
      }
    }
  }

  return(next_workday_after_holiday)
}






# Apply the function to create new columns for each country
data$WorkdayAfterHoliday_FI <- is_next_workday_after_holiday(data$FI, data$Weekend)
data$WorkdayAfterHoliday_NO <- is_next_workday_after_holiday(data$NO, data$Weekend)
data$WorkdayAfterHoliday_DK <- is_next_workday_after_holiday(data$DK, data$Weekend)
data$WorkdayAfterHoliday_SE <- is_next_workday_after_holiday(data$SE, data$Weekend)

# View the resulting data
print(data)


######## TESTS


library(testthat)

# Test 1: Holiday on a Friday, Monday is a workday
test_that("Holiday on Friday, Monday is workday", {
  data <- data.frame(
    Holiday = c(0, 0, 0, 0, 1, 0, 0, 0), # Holiday on Friday
    Weekend = c(0, 0, 0, 0, 0, 1, 1, 0)  # Weekend on Saturday and Sunday
  )
  expected <- c(0, 0, 0, 0, 0, 0, 0, 1) # Monday should be marked as workday after holiday
  result <- is_next_workday_after_holiday(data$Holiday, data$Weekend)
  expect_equal(result, expected)
})

# Test 2: Consecutive holidays
test_that("Consecutive holidays", {
  data <- data.frame(
    Holiday = c(1, 1, 0, 0), # Two consecutive holidays
    Weekend = c(0, 0, 0, 0)  # No weekend
  )
  expected <- c(0, 0, 1, 0) # The day after the consecutive holidays should be marked
  result <- is_next_workday_after_holiday(data$Holiday, data$Weekend)
  expect_equal(result, expected)
})

# Test 3: Holiday before a weekend
test_that("Holiday before a weekend", {
  data <- data.frame(
    Holiday = c(0, 1, 0, 0, 0), # Holiday on second day
    Weekend = c(0, 0, 1, 1, 0)  # Weekend follows the holiday
  )
  expected <- c(0, 0, 0, 0, 1) # The day after the weekend should be marked
  result <- is_next_workday_after_holiday(data$Holiday, data$Weekend)
  expect_equal(result, expected)
})
