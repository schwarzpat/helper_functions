import polars as pl

data = {
    "col1": ["apple", "banana", "cherry"],
    "col2": ["dog", "cat", "apple"],
    "col3": ["table", "chair", "desk"],
    "col4": [1, 2, 3]   
}
df = pl.DataFrame(data)


search_text = "apple"

filtered_df = df.filter(
    pl.any_horizontal(
        [pl.col(col)
         .str.to_lowercase()
         .str.contains(search_text
         .lower()) 
         for col in df.select(pl.col(pl.Utf8)).columns]
    )
)

print(filtered_df)
