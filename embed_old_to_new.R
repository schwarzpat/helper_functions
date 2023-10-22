# Load required library
library(dplyr)

# Define the function
replace_values <- function(tibble_1, tibble_2, old_col_t1, new_col_t1, target_col_t2) {
  tibble_2 %>%
    left_join(select(tibble_1, all_of(c(old_col_t1, new_col_t1))), 
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
