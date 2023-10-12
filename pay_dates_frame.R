# Install and load required packages
install.packages(c("timeDate", "dplyr"))
library(timeDate)
library(dplyr)

# Function to determine the payment days for a specific year
payment_days <- function(year) {
  start_date <- as.Date(paste(year, "01-01", sep = "-"))
  end_date <- as.Date(paste(year, "12-31", sep = "-"))
  all_days <- seq(from = start_date, to = end_date, by = "days")
  
  # Denmark: Salary on last banking day, Security on first banking day
  denmark_days_salary <- sapply(split(all_days, format(all_days, "%Y-%m")), function(x) tail(x[weekdays(x) != "Saturday" & weekdays(x) != "Sunday"], 1))
  denmark_days_security <- sapply(split(all_days, format(all_days, "%Y-%m")), function(x) head(x[weekdays(x) != "Saturday" & weekdays(x) != "Sunday"], 1))
  
  # Sweden: Salary on 25th or nearest preceding business day, Security on 18th or nearest preceding business day
  sweden_days_salary <- adjust_for_weekends(all_days, 25, "preceding")
  sweden_days_security <- adjust_for_weekends(all_days, 18, "preceding")
  
  # Finland: Salary on 15th or nearest following business day, Security on 7th or nearest following business day
  finland_days_salary <- adjust_for_weekends(all_days, 15, "following")
  finland_days_security <- adjust_for_weekends(all_days, 7, "following")
  
  # Norway: Salary on 12th or nearest preceding business day, Security on 20th or nearest preceding business day
  norway_days_salary <- adjust_for_weekends(all_days, 12, "preceding")
  norway_days_security <- adjust_for_weekends(all_days, 20, "preceding")
  
  return(list(Denmark_Salary = denmark_days_salary, Denmark_Security = denmark_days_security,
              Sweden_Salary = sweden_days_salary, Sweden_Security = sweden_days_security,
              Finland_Salary = finland_days_salary, Finland_Security = finland_days_security,
              Norway_Salary = norway_days_salary, Norway_Security = norway_days_security))
}

# Helper function to adjust for weekends
adjust_for_weekends <- function(all_days, day, direction) {
  selected_days <- sapply(split(all_days, format(all_days, "%Y-%m")), function(x) {
    target_day <- x[as.numeric(format(x, "%d")) == day]
    while (weekdays(target_day) %in% c("Saturday", "Sunday")) {
      if (direction == "preceding") {
        target_day <- target_day - 1
      } else {
        target_day <- target_day + 1
      }
    }
    return(target_day)
  })
  return(selected_days)
}

# Function to determine payment days within a range of years
payment_days_multiyear <- function(start_year, end_year) {
  all_years <- start_year:end_year
  all_payment_days <- lapply(all_years, payment_days)

  # Concatenate payment days across all years
  all_columns <- names(all_payment_days[[1]])
  concatenated_days <- lapply(all_columns, function(col) {
    do.call(c, lapply(all_payment_days, function(x) x[[col]]))
  })
  names(concatenated_days) <- all_columns
  
  # Create comprehensive date sequence
  start_date <- as.Date(paste(start_year, "01-01", sep = "-"))
  end_date <- as.Date(paste(end_year, "12-31", sep = "-"))
  all_days <- seq(from = start_date, to = end_date, by = "days")

  # Initialize data frame
  df <- data.frame(Date = all_days)
  for (col in all_columns) {
    df[[col]] <- 0
  }
  
  # Update data frame based on payment days
  for (col in all_columns) {
    df[[col]][df$Date %in% concatenated_days[[col]]] <- 1
  }
  
  return(df)
}

# Determine payment days from 2015 to 2030
df_payment_days <- payment_days_multiyear(2015, 2030)

# Show the first few rows of the data frame
head(df_payment_days)
