df_transformed_multi <- df_multi_values %>%
  mutate(
    is_weekend = wday(date, week_start = 1) %in% c(6, 7), # 6 = Saturday, 7 = Sunday (with Monday as start of week)

    target_date = if_else(is_weekend,
                          case_when(
                            wday(date, week_start = 1) == 6 ~ date + days(2), # Saturday -> Monday
                            wday(date, week_start = 1) == 7 ~ date + days(1), # Sunday -> Monday
                            TRUE ~ date # Should not happen for non-weekends
                          ),
                          date)
  ) %>%
  # Group by the target date to sum values for the new Monday entries
  group_by(date = target_date) %>%
  summarise(
    # Use across() to apply sum to all columns whose name contains "L1"
    across(contains("L1"), sum),

    .groups = "drop" # Drop grouping after summarising
  ) %>%

  filter(wday(date, week_start = 1) < 6)

print(df_transformed_multi)
