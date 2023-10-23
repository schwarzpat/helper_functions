# Load required library
library(dplyr)

# Define the function
replace_values <- function(lookup_tibble, target_tibble, old_col_t1, new_col_t1, target_col_t2) {
  target_tibble %>%
    left_join(select(lookup_tibble, all_of(c(old_col_t1, new_col_t1))), 
              by = setNames(old_col_t1, target_col_t2)) %>%
    select(-all_of(target_col_t2)) %>%
    rename_with(~ target_col_t2, all_of(new_col_t1))
}

# Example usage
tibble_1 <- tibble(
  old_values = factor(c("a", "b", "c")),
  new_values = c("x", "y", "z")
)

tibble_2 <- tibble(
  some_column = c("a", "a", "b", "c", "c"),
  another_column = c(1, 2, 3, 4, 5)
)

result <- replace_values(tibble_1, tibble_2, "old_values", "new_values", "some_column")

# Display the result
print(result)

#########

# List of unique terms
list_of_terms <- unique(original_tibble$term)

# Create a list of tibbles based on unique terms
list_of_tibbles <- lapply(list_of_terms, function(term) {
  filtered_tibble <- original_tibble %>% 
                      filter(term == !!term) %>% 
                      select(old, new)
  return(filtered_tibble)
})

##########

# Iterate over each term and corresponding tibble to assign it to a variable
for (i in seq_along(list_of_terms)) {
  term <- list_of_terms[[i]]
  tibble_data <- list_of_tibbles[[i]]
  
  # Create a variable name based on the term
  variable_name <- paste0("tibble_for_term_", term)
  
  # Assign the tibble to a variable with the generated name
  assign(variable_name, tibble_data, envir = .GlobalEnv)
}
