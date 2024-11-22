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
