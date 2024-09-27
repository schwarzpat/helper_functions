library(readxl)
library(openxlsx)
library(dplyr)

folder_path <- "your/folder/path"
file_list <- list.files(path = folder_path, pattern = "*.xlsx", full.names = TRUE)

clean_excel_file <- function(file_path) {
  data <- read_excel(file_path)
  cols_to_keep <- sapply(data, function(col) {
    any(!is.na(col) & col != 'NULL')
  })
  cleaned_data <- data[, cols_to_keep]
  cleaned_file_path <- sub("\\.xlsx$", "_cleaned.xlsx", file_path)
  write.xlsx(cleaned_data, cleaned_file_path)
}

lapply(file_list, clean_excel_file)
