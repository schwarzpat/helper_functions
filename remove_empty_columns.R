install.packages("readxl")
install.packages("writexl")

library(readxl)
library(writexl)

folder_path <- "path_to_your_folder"

file_list <- list.files(path = folder_path, pattern = "\\.xlsx$", full.names = TRUE)

clean_excel_file <- function(file_path) {
  data <- read_excel(file_path)
  data <- as.data.frame(lapply(data, function(x) if (is.character(x)) trimws(x) else x))
  clean_data <- data[, colSums(data == 'NULL' | is.na(data) | data == "") != nrow(data)]
  file_name <- basename(file_path)
  clean_file_name <- sub("\\.xlsx$", "_clean.xlsx", file_name)
  write_xlsx(clean_data, file.path(folder_path, clean_file_name))
}

sapply(file_list, clean_excel_file)
