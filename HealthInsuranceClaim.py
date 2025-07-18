import pandas as pd
import numpy as np
from sqlalchemy import create_engine
import pyodbc

# ----------------------------------
# 1. SQL Server Connection Details
# ----------------------------------
server = r'DESKTOP-S8LCP9M\SQLEXPRESS'      # e.g., 'localhost\SQLEXPRESS'
database = 'InsuranceProject'           # e.g., 'InsuranceDB'
username = r'DESKTOP-S8LCP9M\hp'

# SQLAlchemy connection string
#conn_str = f"mssql+pyodbc://{username}:{password}@{server}/{database}?driver=ODBC+Driver+17+for+SQL+Server"
#engine = create_engine(conn_str)
connection_string = (
    r'DRIVER={ODBC Driver 17 for SQL Server};'
    rf'SERVER={server};'
    rf'DATABASE={database};'
    r'Trusted_Connection=yes;' # This is key for Windows Authentication
)

# Define SQLAlchemy engine for Windows Authentication (no password needed)
engine = create_engine(
    f"mssql+pyodbc://{server}/{database}?trusted_connection=yes&driver=ODBC+Driver+17+for+SQL+Server"
)
# ----------------------------------
# 2. Load CSV Data with Pandas
# ----------------------------------
csv_file_path = r"C:\Users\hp\Downloads\Dataset for DA\enhanced_health_insurance_claims.csv"
df = pd.read_csv(csv_file_path)

print("✅ Loaded CSV Data:")
print(df.head())

# ----------------------------------
# 3. Clean / Preprocess Data
# ----------------------------------
# Fill missing numerical values with median
num_cols = df.select_dtypes(include=[np.number]).columns
df[num_cols] = df[num_cols].fillna(df[num_cols].median())

# Fill other missing values with "Unknown" or appropriate default
df = df.fillna("Unknown")

# ----------------------------------
# 4. Load Data to SQL Server Table
# ----------------------------------
table_name = 'HealthInsuranceClaims'

df.to_sql(table_name, con=engine, if_exists='replace', index=False)
print(f"✅ Data uploaded to SQL Server table: {table_name}")

# ----------------------------------
# 5. Run SQL Query for Analytics
# ----------------------------------
query = f"""
SELECT 
    Claim_Status, 
    COUNT(*) AS Total_Claims,
    AVG(CAST(Claim_Amount AS FLOAT)) AS Avg_Claim_Amount,
    SUM(CAST(Claim_Amount AS FLOAT)) AS Total_Claimed
FROM {table_name}
GROUP BY Claim_Status
"""

analytics_df = pd.read_sql(query, con=engine)

print("\n📊 Claim Status Analytics:")
print(analytics_df)

# ----------------------------------
# 6. NumPy-based Summary
# ----------------------------------
claim_amounts = df['Claim_Amount'].replace('Unknown', np.nan).astype(float).dropna()

print("\n📈 NumPy Stats on Claim_Amount:")
print("Mean:", np.mean(claim_amounts))
print("Median:", np.median(claim_amounts))
print("Std Dev:", np.std(claim_amounts))
print("Max:", np.max(claim_amounts))
print("Min:", np.min(claim_amounts))
