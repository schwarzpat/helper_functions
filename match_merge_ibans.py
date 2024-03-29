import pandas as pd

def match_and_merge_accounts_efficient(input_excel_path, output_excel_path, iban_csv_path):
    """
    Efficiently matches accounts in an Excel file against a DataFrame created from a CSV file.
    Only the "customer_id" column from the CSV is merged into the Excel data, in a single column. 
    NULL values are not matched.
    
    Parameters:
    input_excel_path (str): The path to the input Excel file.
    output_excel_path (str): The path where the updated Excel file will be saved.
    iban_csv_path (str): The path to the CSV file containing the IBAN list and the "customer_id" column.
    
    Returns:
    None: The function saves the updated Excel file at the specified output path.
    """
    
    # Data Importation
    df_excel = pd.read_excel(input_excel_path)
    df_csv = pd.read_csv(iban_csv_path).dropna(subset=['iban'])
    
    # Create a unique identifier for each row
    df_excel['unique_id'] = df_excel.index
    
    # Reshape Excel DataFrame for efficient matching
    df_melt = df_excel.melt(id_vars=['unique_id'], 
                            value_vars=['ordering_account', 'beneficiary_account', 'creditor_account', 'debtor_account'],
                            var_name='account_type', value_name='account_value').dropna(subset=['account_value'])
    
    # Perform Merge Operation
    df_merged = pd.merge(df_melt, df_csv[['iban', 'customer_id']], left_on='account_value', right_on='iban', how='left')
    
    # Aggregate to obtain a single "customer_id" per unique_id
    df_aggregate = df_merged.groupby('unique_id')['customer_id'].first().reset_index()
    
    # Merge the "customer_id" column back to original DataFrame
    df_excel = pd.merge(df_excel, df_aggregate, on='unique_id', how='left')
    
    # Remove the temporary unique identifier
    df_excel.drop(columns=['unique_id'], inplace=True)
    
    # Data Exportation
    df_excel.to_excel(output_excel_path, index=False)

input_excel_path = 'path_to_input_excel_file.xlsx'
output_excel_path = 'path_to_output_excel_file.xlsx'
iban_csv_path = 'path_to_iban_csv_file.csv'

match_and_merge_accounts_efficient(input_excel_path, output_excel_path, iban_csv_path)



-- Assume excel_data and csv_data are the result of some queries
WITH excel_data AS (
    -- Your SQL query here that generates excel_data
),
csv_data AS (
    -- Your SQL query here that generates csv_data
),
-- Filter NULLs from csv_data
filtered_csv_data AS (
    SELECT * FROM csv_data WHERE account_id IS NOT NULL
),
-- Melt the excel_data table
melted_excel_data AS (
    SELECT 
        alert_identifier,
        'ordering_account' AS account_type,
        ordering_account AS account_value
    FROM excel_data WHERE ordering_account IS NOT NULL
    UNION ALL
    SELECT 
        alert_identifier,
        'beneficiary_account' AS account_type,
        beneficiary_account AS account_value
    FROM excel_data WHERE beneficiary_account IS NOT NULL
    UNION ALL
    SELECT 
        alert_identifier,
        'creditor_account' AS account_type,
        creditor_account AS account_value
    FROM excel_data WHERE creditor_account IS NOT NULL
    UNION ALL
    SELECT 
        alert_identifier,
        'debtor_account' AS account_type,
        debtor_account AS account_value
    FROM excel_data WHERE debtor_account IS NOT NULL
),
-- Perform the merge operation
merged_excel_data AS (
    SELECT 
        e.alert_identifier,
        e.account_type,
        c.customer_id
    FROM melted_excel_data e
    LEFT JOIN filtered_csv_data c ON e.account_value = c.account_id
)
-- Merge the 'customer_id' and 'account_type' columns back into the original excel_data
SELECT 
    e.*,
    m.customer_id,
    m.account_type AS matched_account_type
FROM excel_data e
LEFT JOIN merged_excel_data m ON e.alert_identifier = m.alert_identifier;

