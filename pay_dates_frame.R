library(lubridate)
library(dplyr)

# Function to determine the payment days for a specific year
payment_days <- function(year) {
  start_date <- ymd(paste0(year, "-01-01"))
  end_date <- ymd(paste0(year, "-12-31"))
  all_days <- seq(from = start_date, to = end_date, by = "days")
  
  denmark_days_salary <- sapply(split(all_days, floor_date(all_days, "month")), function(x) last(x[wday(x) %in% 2:6]))
  denmark_days_security <- sapply(split(all_days, floor_date(all_days, "month")), function(x) first(x[wday(x) %in% 2:6]))

  sweden_days_salary <- adjust_for_weekends(all_days, 25, "preceding")
  sweden_days_security <- adjust_for_weekends(all_days, c(18, 19), "preceding")
  
  finland_days_salary <- adjust_for_weekends(all_days, c(15, "last"), "preceding")
  finland_days_security <- adjust_for_weekends(all_days, 7, "following")
  
  norway_days_salary <- adjust_for_weekends(all_days, 12, "preceding")
  norway_days_security <- adjust_for_weekends(all_days, 20, "preceding")
  
  return(list(Denmark_Salary = denmark_days_salary, Denmark_Security = denmark_days_security,
              Sweden_Salary = sweden_days_salary, Sweden_Security = sweden_days_security,
              Finland_Salary = finland_days_salary, Finland_Security = finland_days_security,
              Norway_Salary = norway_days_salary, Norway_Security = norway_days_security))
}

# Helper function to adjust for weekends
adjust_for_weekends <- function(all_days, days, direction) {
  selected_days <- lapply(split(all_days, floor_date(all_days, "month")), function(x) {
    target_days <- if ("last" %in% days) {
      c(x[day(x) %in% days], last(x[wday(x) %in% 2:6]))
    } else {
      x[day(x) %in% days]
    }
    for (i in seq_along(target_days)) {
      while (wday(target_days[i]) %in% c(1, 7)) {
        if (direction == "preceding") {
          target_days[i] <- target_days[i] - days(1)
        } else {
          target_days[i] <- target_days[i] + days(1)
        }
      }
    }
    return(target_days)
  })
  return(do.call(c, selected_days))
}

# Function to determine payment days within a range of years
payment_days_multiyear <- function(start_year, end_year) {
  all_years <- start_year:end_year
  all_payment_days <- lapply(all_years, payment_days)
  
  all_columns <- names(all_payment_days[[1]])
  concatenated_days <- lapply(all_columns, function(col) {
    do.call(c, lapply(all_payment_days, function(x) x[[col]]))
  })
  names(concatenated_days) <- all_columns
  
  start_date <- ymd(paste0(start_year, "-01-01"))
  end_date <- ymd(paste0(end_year, "-12-31"))
  all_days <- seq(from = start_date, to = end_date, by = "days")
  
  df <- data.frame(Date = all_days)
  for (col in all_columns) {
    df[col] <- 0
  }
  
  df <- df %>% mutate(across(all_columns, ~ ifelse(Date %in% concatenated_days[[cur_column()]], 1, 0), .names = "{.col}"))
  
  return(df)
}

# Determine payment days from 2015 to 2030
df_payment_days <- payment_days_multiyear(2015, 2030)

# Display first few rows of the data frame
head(df_payment_days)
