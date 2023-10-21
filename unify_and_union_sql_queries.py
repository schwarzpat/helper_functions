# Create a folder named 'sample_sql'
# mkdir sample_sql
# cd sample_sql
# echo "SELECT id, name FROM table1;" > query1.sql
# echo "SELECT name, id FROM table1;" > query2.sql
# echo "SELECT age FROM table2;" > query3.sql
# echo "SELECT salary FROM table3;" > query4.sql

# Import required modules
import os
import re
from collections import defaultdict
import unittest

# Redefine the function to remove trailing semicolons from SQL queries
def unify_and_union_sql_queries(sql_dir):
    """
    Unify and concatenate SQL queries from files in a specified directory
    using the UNION operator.

    Parameters:
        sql_dir (str): The directory containing SQL files.

    Returns:
        list: A list of unified SQL queries with consistent column orders.
    """

    # List to hold SQL queries
    sql_queries = []

    # Regular expression pattern to extract columns in 'SELECT ... FROM' clause
    select_pattern = re.compile(r'SELECT (.*?) FROM', re.IGNORECASE)

    # Read each SQL file and store the queries in the list
    for filename in os.listdir(sql_dir):
        if filename.endswith(".sql"):
            with open(os.path.join(sql_dir, filename), 'r') as f:
                sql_query = f.read().strip(';')  # Remove trailing semicolons
                sql_queries.append(sql_query)

    # Dictionary to group similar queries
    query_groups = defaultdict(list)

    # Extract columns and group similar queries
    for query in sql_queries:
        columns_str = select_pattern.findall(query)[0]
        columns_set = set(map(str.strip, columns_str.split(',')))
        query_groups[frozenset(columns_set)].append(query)

    # Standardize column order and concatenate queries using 'UNION'
    final_queries = []
    for columns_set, queries in query_groups.items():
        # Standardize to the column order of the first query in the group
        standard_columns_str = select_pattern.findall(queries[0])[0]
        
        # Modify each query in the group to have the standardized column order
        modified_queries = []
        for query in queries:
            original_columns_str = select_pattern.findall(query)[0]
            modified_query = query.replace(original_columns_str, standard_columns_str)
            modified_queries.append(modified_query)
        
        # Concatenate all modified queries in the group using 'UNION'
        final_query = " UNION ".join(modified_queries)
        final_queries.append(final_query)

    return final_queries

class TestUnifyAndUnionSQLQueries(unittest.TestCase):

    def setUp(self):
        self.test_dir = '/test_sql_dir'
        os.makedirs(self.test_dir, exist_ok=True)

    def tearDown(self):
        for filename in os.listdir(self.test_dir):
            os.remove(os.path.join(self.test_dir, filename))
        os.rmdir(self.test_dir)

    def write_sql_files(self, queries):
        for i, query in enumerate(queries):
            with open(os.path.join(self.test_dir, f"query{i+1}.sql"), 'w') as f:
                f.write(query)

    def test_unify_and_union(self):
        queries = [
            "SELECT id, name FROM table1;",
            "SELECT name, id FROM table1;",
            "SELECT age FROM table2;",
            "SELECT salary FROM table3;"
        ]
        self.write_sql_files(queries)

        result = unify_and_union_sql_queries(self.test_dir)

        expected1 = "SELECT id, name FROM table1 UNION SELECT id, name FROM table1"
        expected2 = "SELECT age FROM table2"
        expected3 = "SELECT salary FROM table3"

        self.assertIn(expected1, result)
        self.assertIn(expected2, result)
        self.assertIn(expected3, result)

    def test_empty_directory(self):
        result = unify_and_union_sql_queries(self.test_dir)
        self.assertEqual(result, [])

    def test_single_query(self):
        queries = ["SELECT id, name FROM table1;"]
        self.write_sql_files(queries)

        result = unify_and_union_sql_queries(self.test_dir)

        expected = "SELECT id, name FROM table1"
        self.assertEqual(result, [expected])

# Run the unittests
unittest.TextTestRunner().run(unittest.TestLoader().loadTestsFromTestCase(TestUnifyAndUnionSQLQueries))

