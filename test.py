import os
import re

# Directory containing SQL files
sql_dir = "path/to/sql/files"

# List to hold SQL queries
sql_queries = []

# Regular expression pattern to extract 'SELECT ... FROM' clause
select_pattern = re.compile(r'SELECT .*? FROM', re.IGNORECASE)

# Read each SQL file and store the queries in the list
for filename in os.listdir(sql_dir):
    if filename.endswith(".sql"):
        with open(os.path.join(sql_dir, filename), 'r') as f:
            sql_query = f.read()
            sql_queries.append(sql_query)

# Extract 'SELECT ... FROM' clause from the first query as the standard
standard_select_clause = select_pattern.findall(sql_queries[0])[0]

# Replace 'SELECT ... FROM' clause in each query and store modified queries
modified_queries = []
for query in sql_queries:
    original_select_clause = select_pattern.findall(query)[0]
    modified_query = query.replace(original_select_clause, standard_select_clause)
    modified_queries.append(modified_query)

# Concatenate all modified queries using 'UNION'
final_query = " UNION ".join(modified_queries)

# Now, 'final_query' contains the unified SQL query with consistent 'SELECT ... FROM' clauses
