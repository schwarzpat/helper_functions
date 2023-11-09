# Load necessary libraries
library(tseries)
library(corrplot)

# Function to calculate and plot correlation between two time series
calculate_and_plot_correlation <- function(ts1, ts2) {
  # Remove NA values
  ts1 <- na.omit(ts1)
  ts2 <- na.omit(ts2)
  
  # Ensure equal length after NA removal
  minLength <- min(length(ts1), length(ts2))
  ts1 <- ts1[1:minLength]
  ts2 <- ts2[1:minLength]
  
  # Check for stationarity and difference if necessary
  if (adf.test(ts1)$p.value > 0.05) {
    ts1 <- diff(ts1)
    ts1 <- na.omit(ts1)  # Remove NAs created by differencing
  }
  if (adf.test(ts2)$p.value > 0.05) {
    ts2 <- diff(ts2)
    ts2 <- na.omit(ts2)  # Remove NAs created by differencing
  }
  
  # Calculate correlation
  correlation_matrix <- cor(ts1, ts2, use = "complete.obs")
  
  # Plot correlation
  corrplot(correlation_matrix, method = "circle")
  
  # Return the correlation value
  return(correlation_matrix)
}
