import pandas as pd

def match_and_merge_ibans(input_excel_path, output_excel_path, iban_csv_path):
    """
    Efficiently matches accounts in an Excel file against a DataFrame created from a CSV file.
    Additional columns from the CSV are also merged into the Excel data. NULL values are not matched.
    
    Parameters:
    input_excel_path (str): The path to the input Excel file.
    output_excel_path (str): The path where the updated Excel file will be saved.
    iban_csv_path (str): The path to the CSV file containing the IBAN list and additional columns.
    
    Returns:
    None: The function saves the updated Excel file at the specified output path.
    """
    
    # Data Importation
    df_excel = pd.read_excel(input_excel_path)
    df_csv = pd.read_csv(iban_csv_path).dropna(subset=['iban'])
    
    # Reshape Excel DataFrame for efficient matching
    df_melt = df_excel.melt(id_vars=['alert_identifier'], 
                            value_vars=['ordering_account', 'beneficiary_account', 'creditor_account', 'debtor_account'],
                            var_name='account_type', value_name='account_value').dropna(subset=['account_value'])
    
    # Perform Merge Operation
    df_merged = pd.merge(df_melt, df_csv, left_on='account_value', right_on='iban', how='left')
    
    # Reshape back to original form
    df_unmelt = df_merged.pivot(index='alert_identifier', columns='account_type', values=['iban'] + list(df_csv.columns.difference(['iban'])))
    
    # Merge additional columns and 'iban' back to original DataFrame
    df_excel = pd.merge(df_excel, df_unmelt, left_on='alert_identifier', right_index=True, how='left')
    
    # Data Exportation
    df_excel.to_excel(output_excel_path, index=False)

input_excel_path = 'path_to_input_excel_file.xlsx'
output_excel_path = 'path_to_output_excel_file.xlsx'
iban_csv_path = 'path_to_iban_csv_file.csv'

match_and_merge_accounts_efficient(input_excel_path, output_excel_path, iban_csv_path)

