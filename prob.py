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
