from datetime import date, timedelta

start_date = date(2023, 1, 1)
end_date = date(2030, 12, 31)
current_date = start_date

dates = []
while current_date <= end_date:
    dates.append(current_date)
    current_date += timedelta(days=1)

table_name = "your_table_name"

# Generate the CREATE TABLE statement
create_table_query = f"CREATE TABLE {table_name} (ymd DATE)"

# Generate the INSERT INTO statements for each date
insert_queries = [f"INSERT INTO {table_name} VALUES ('{date}');" for date in dates]

# Combine the CREATE TABLE statement and INSERT INTO statements
impala_query = create_table_query + "\n" + "\n".join(insert_queries)

print(impala_query)
