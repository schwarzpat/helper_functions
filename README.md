# Utility Functions for R Programming

This repository contains a collection of R scripts that provide useful and reusable functions for various programming tasks. The scripts are stored as separate files for ease of use and maintenance.

## Rdf_to_markdown_table.R

This script provides a function called df_2_MD() that converts the content of a data frame into a RMarkdown-formatted table. The table can be copied and pasted into a Markdown document for further formatting and styling.

To use the function, simply pass a data frame as an argument to the df_2_MD() function. For example:

```bash
short_iris <- iris[1:3,1:5]
df_2_MD(short_iris)
```

## using_package_checker.R

his script provides a function called using() that checks if R packages used in a script are installed in the environment and installs them if they are not. The function takes a variable number of package names as arguments and returns a list of the loaded packages.

To use the function, simply call it with the names of the packages you want to check. For example:

```bash
using("tidyverse", "dplyr", "ggplot2")
```


## License

[MIT](https://choosealicense.com/licenses/mit/)
