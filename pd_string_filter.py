import pandas as pd

# Example DataFrame
data = {
    "col1": ["apple", "banana", "cherry"],
    "col2": ["dog", "cat", "apple"],
    "col3": ["table", "chair", "desk"],
    "col4": [1, 2, 3]  # Non-string column
}
df = pd.DataFrame(data)

# Text to search for
search_text = "apple"

# Identify columns of type object or string
string_columns = df.select_dtypes(include=['object', 'string']).columns

# Filtering rows where the text appears in any string column
filtered_df = df[df[string_columns].apply(lambda row: row.str.contains(search_text, case=False, na=False).any(), axis=1)]

print(filtered_df)
