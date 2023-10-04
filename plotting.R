highest_count_bar <- function(data, x_value = "x_default", y_value = "y_default", 
                              grouping_variable = c("group_default"), 
                              category = "category_default", 
                              title_string = "Default Title") {
  
  # Generate the plot
  plot <- data %>%
    group_by(across(all_of(grouping_variable))) %>%
    count(across(all_of(category))) %>%
    top_n(n = 1, wt = n) %>%
    ungroup() %>%
    ggplot(aes_string(x = x_value, y = y_value, color = category)) +
    geom_bar(stat = "identity", alpha = 0.5, show.legend = FALSE) +
    scale_color_discrete(guide = "none") +
    ggtitle(title_string) +
    geom_smooth(method = lm, color = "yellow") +
    geom_smooth() +
    geom_hline(aes_string(yintercept = "mean(n)", color = "'red'")) +
    theme_bw() +
    guides(shape = "none")
  
  return(plot)
}

# Utilizing default values
data %>% highest_count_bar()

# Specifying parameters
data %>% 
  highest_count_bar(x_value = some_x_variable, 
                    y_value = some_y_variable, 
                    grouping_variable = c(some_group_variable1, some_group_variable2),
                    category = some_category_variable,
                    title_string = "Custom Title")
