library(embed)
library(tidymodels)

# Factor collapsing
# Load the Ames Housing dataset and transform the Sale_Price column
data(ames, package = "modeldata")
ames$Sale_Price <- log10(ames$Sale_Price)

# Create a recipe for preprocessing the data, specifiying the columns to be collapsed by CART
collapsed_data <-
  recipe(Sale_Price ~ ., data = ames) %>%
  step_collapse_cart(Sale_Type,
                     Garage_Type,
                     Neighborhood,
                     Pool_QC,
                     Functional,
                     Exterior_1st,
                     Exterior_2nd,
                     MS_SubClass,
                     outcome = vars(Sale_Price)) %>%
  prep() %>%
  bake(new_data = NULL)

# GLM encoding
# Load the Ames Housing dataset and encode some factor columns
data(ames, package = "modeldata")
ames$Sale_Price <- log10(ames$Sale_Price)

# Create a recipe for preprocessing the data
encoded_data <-
  recipe(Sale_Price ~ ., data = ames) %>%
  step_lencode_glm(Sale_Type,
                     outcome = vars(Sale_Price)) %>%
    step_lencode_glm(Neighborhood,
                     outcome = vars(Sale_Price)) %>%
    step_lencode_glm(Garage_Type,
                     outcome = vars(Sale_Price)) %>%
    step_lencode_glm(Functional,
                     outcome = vars(Sale_Price)) %>%
    step_lencode_glm(MS_SubClass,
                     outcome = vars(Sale_Price)) %>%
  prep() %>%
  bake(new_data = NULL)
