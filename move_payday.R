movePayday <- function(df, holidayColumn, paydayColumn) {
  # Ensure the Date column is of Date type
  df$Date <- as.Date(df$Date)
  
  # Iterate through each row
  for (i in 1:nrow(df)) {
    # Check if the day is a payday and either a holiday or a weekend
    if (df[i, paydayColumn] == 1 && (df[i, holidayColumn] != "None" || df[i, "Weekday"] == 1)) {
      # Move the payday forward
      j <- i
      while (df[j, holidayColumn] != "None" || df[j, "Weekday"] == 1) {
        j <- j + 1
        # Optional: Check for bounds of the dataframe
        if (j > nrow(df)) {
          break
        }
      }
      if (j <= nrow(df)) {
        # Update the payday
        df[i, paydayColumn] <- 0
        df[j, paydayColumn] <- 1
      }
    }
  }
  return(df)
}

########

movePaydayForward <- function(df, holidayColumn, paydayColumn) {
  # Ensure the Date column is of Date type
  df$Date <- as.Date(df$Date)
  
  # Iterate through each row
  for (i in 1:nrow(df)) {
    # Check if the day is a payday and either a holiday or a weekend
    if (df[i, paydayColumn] == 1 && (df[i, holidayColumn] != "None" || df[i, "Weekday"] == 1)) {
      # Move the payday forward
      j <- i
      while (df[j, holidayColumn] != "None" || df[j, "Weekday"] == 1) {
        j <- j - 1
        # Optional: Check for bounds of the dataframe
        if (j < 1) {
          break
        }
      }
      if (j >= 1) {
        # Update the payday
        df[i, paydayColumn] <- 0
        df[j, paydayColumn] <- 1
      }
    }
  }
  return(df)
}
