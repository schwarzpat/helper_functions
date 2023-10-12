# Install and load required packages
install.packages("timeDate")
library(timeDate)

# Function to determine the payment days for each country
payment_days <- function(year) {
  start_date <- as.Date(paste(year, "01-01", sep = "-"))
  end_date <- as.Date(paste(year, "12-31", sep = "-"))
  all_days <- seq(from = start_date, to = end_date, by = "days")
  weekdays_all_days <- weekdays(all_days)
  
  # Denmark: Last banking day of the month
  denmark_days <- sapply(split(all_days, format(all_days, "%Y-%m")), function(x) tail(x[weekdays(x) != "Saturday" & weekdays(x) != "Sunday"], 1))
  
  # Sweden: 25th or nearest preceding business day
  sweden_days <- sapply(split(all_days, format(all_days, "%Y-%m")), function(x) {
    day_25 <- x[as.numeric(format(x, "%d")) == 25]
    while (weekdays(day_25) %in% c("Saturday", "Sunday")) {
      day_25 <- day_25 - 1
    }
    return(day_25)
  })
  
  # Finland: 15th or nearest preceding business day, or the last bank day
  finland_days <- sapply(split(all_days, format(all_days, "%Y-%m")), function(x) {
    day_15 <- x[as.numeric(format(x, "%d")) == 15]
    while (weekdays(day_15) %in% c("Saturday", "Sunday")) {
      day_15 <- day_15 - 1
    }
    last_bank_day <- tail(x[weekdays(x) != "Saturday" & weekdays(x) != "Sunday"], 1)
    return(ifelse(day_15 >= last_bank_day, last_bank_day, day_15))
  })
  
  # Norway: 12th or nearest preceding business day
  norway_days <- sapply(split(all_days, format(all_days, "%Y-%m")), function(x) {
    day_12 <- x[as.numeric(format(x, "%d")) == 12]
    while (weekdays(day_12) %in% c("Saturday", "Sunday")) {
      day_12 <- day_12 - 1
    }
    return(day_12)
  })
  
  return(list(Denmark = denmark_days, Sweden = sweden_days, Finland = finland_days, Norway = norway_days))
}

# Example usage
payment_schedule_2023 <- payment_days(2023)
print(payment_schedule_2023)
