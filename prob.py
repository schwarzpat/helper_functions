import pandas as pd
import numpy as np
import scipy.stats as stats

# Sample data
data = {
    "forecasts": [100, 105, 110, 115, 120],
    "actuals": [102, 107, 115, 117, 125]
}

# Create a DataFrame
df = pd.DataFrame(data)

# Calculate forecast errors
df['errors'] = df['actuals'] - df['forecasts']

# Estimating the distribution of forecast errors
mean_error, sd_error = df['errors'].mean(), df['errors'].std()

# Probability thresholds
prob_thresholds = np.array([0.90, 0.95, 0.99])

# Calculate quantiles for these thresholds
quantiles = stats.norm.ppf(prob_thresholds, loc=mean_error, scale=sd_error)

# Convert quantiles to adjustment percentages relative to mean forecast
mean_forecast = df['forecasts'].mean()
adjustment_percentages = (quantiles / mean_forecast) * 100

# Creating a DataFrame for results
results_df = pd.DataFrame({
    "Confidence Level": prob_thresholds,
    "Adjustment Percentage (%)": adjustment_percentages
})

results_df

# Generating a sample of 30 forecast errors (for illustration)
np.random.seed(0)  # For reproducibility
sample_errors = np.random.normal(0, 10, 30)  # Sample errors with mean=0 and std=10

# Sorting errors from highest to lowest
sorted_sample_errors = np.sort(sample_errors)[::-1]

# Plotting errors
plt.figure(figsize=(12, 7))
plt.plot(sorted_sample_errors, marker='o', linestyle='-', color='blue')
plt.title("Sample Forecast Errors (30 Data Points) from Highest to Lowest")
plt.xlabel("Observation")
plt.ylabel("Error")

# Adding lines for 10% increments
num_errors = len(sorted_sample_errors)
for i in range(1, 10):
    percentile_index = int(np.ceil(num_errors * (i / 10))) - 1
    percentile_value = sorted_sample_errors[percentile_index]
    plt.axhline(y=percentile_value, color='red', linestyle='--', alpha=0.7, 
                label=f"{i*10}th percentile" if i == 1 else "")

plt.legend()
plt.show()

# Sample data: Replace with your actual forecast and real numbers
forecasts <- c(100, 105, 110, 115, 120)
actuals <- c(102, 107, 115, 117, 125)

# Step 1: Calculate forecast errors
errors <- actuals - forecasts

# Step 2: Compute descriptive statistics
mean_error <- mean(errors)
sd_error <- sd(errors)

# Step 3: Set your confidence interval (e.g., 95%)
confidence_interval <- 0.95
z_score <- qnorm(confidence_interval)

# Step 4: Adjust forecasts
# Assuming a normal distribution of errors
adjusted_forecasts <- forecasts + z_score * sd_error

# Display adjusted forecasts
adjusted_forecasts

