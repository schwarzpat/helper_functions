import polars as pl

# Example DataFrame
data = {
    "col1": ["apple", "banana", "cherry"],
    "col2": ["dog", "cat", "apple"],
    "col3": ["table", "chair", "desk"],
    "col4": [1, 2, 3]   
}
df = pl.DataFrame(data)
lazy_df = df.lazy()

search_text = "apple"

string_columns = [col for col, dtype in lazy_df.collect_schema().items() if dtype == pl.Utf8]

filtered_lazy_df = lazy_df.filter(
    pl.any_horizontal(
        [pl.col(col)
           .str.to_lowercase()
           .str.contains(search_text.lower()) 
        for col in string_columns]
    )
)

filtered_df = filtered_lazy_df.collect()

print(filtered_df)

##################################

import polars as pl
import os
from pathlib import Path

def filter_excel_files(folder_path: str, search_text: str):
    """
    Reads all Excel files in a folder, filters them based on the presence of the search text in string columns,
    and saves the filtered data into new Excel files with "filtered_" prepended to the original filenames.

    Parameters:
        folder_path (str): Path to the folder containing the Excel files.
        search_text (str): Text to search for in the string columns.
    """
    folder = Path(folder_path)
    if not folder.exists() or not folder.is_dir():
        raise ValueError("Provided path is not a valid folder")

    excel_files = list(folder.glob("*.xlsx"))

    for file_path in excel_files:

        df = pl.read_excel(file_path)

        lazy_df = df.lazy()

        string_columns = [col for col, dtype in lazy_df.collect_schema().items() if dtype == pl.Utf8]

        filtered_lazy_df = lazy_df.filter(
            pl.any_horizontal(
                [pl.col(col)
                   .str.to_lowercase()
                   .str.contains(search_text.lower()) 
                for col in string_columns]
            )
        )

        filtered_df = filtered_lazy_df.collect()

        new_file_name = f"filtered_{file_path.name}"
        new_file_path = folder / new_file_name
        filtered_df.write_excel(new_file_path)

    print(f"Filtered files saved in: {folder_path}")

