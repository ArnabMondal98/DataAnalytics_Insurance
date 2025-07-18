# 🏥 Data Analytics in Insurance Domain using SQL Server, Python (NumPy, Pandas)
This project demonstrates a complete **data analytics pipeline** for health insurance claim data using:
- 📊 **SQL Server** for data storage and query-based analysis
- 🐍 **Python** for data cleaning, transformation, and statistical insights
- 📈 **NumPy** and **Pandas** for data exploration and summary statistics
---
## 📁 Project Structure
├── HealthInsuranceClaim.py # Python script for data cleaning, SQL integration & analysis
├── HealthInsuranceClaims_SQLQueries.sql# SQL scripts for data cleaning, EDA, and transformation
├── enhanced_health_insurance_claims.csv# Sample dataset used for analytics
├── README.md # Project documentation
---
## 🧠 Objectives
- Clean and preprocess raw health insurance claim data
- Load data into SQL Server and perform structured queries
- Extract insights such as average claim amount, approval rates, and age-based trends
- Generate summary statistics using NumPy
---
## 🔗 Technologies Used
| Tool            | Purpose                              |
|-----------------|--------------------------------------|
| 🐍 Python        | Data processing and ETL              |
| 🗃 SQL Server     | Database for structured storage and queries |
| 📦 Pandas        | Data cleaning and manipulation       |
| ➕ NumPy         | Statistical summary and analysis     |
| 🧮 SQL Queries   | EDA, transformation, and aggregation |
---

## ⚙️ How It Works
### 1. Load & Clean Data using Python
The script reads a CSV file, fills missing values, and uploads the cleaned data to SQL Server.

```python
df = pd.read_csv("enhanced_health_insurance_claims.csv")
df.fillna("Unknown", inplace=True)
df.to_sql("HealthInsuranceClaims", con=engine, if_exists="replace")

**SQL-Based Data Aggregation:**
SELECT 
    Claim_Status, 
    COUNT(*) AS Total_Claims,
    AVG(CAST(Claim_Amount AS FLOAT)) AS Avg_Claim_Amount,
    SUM(CAST(Claim_Amount AS FLOAT)) AS Total_Claimed
FROM HealthInsuranceClaims
GROUP BY Claim_Status;

**NumPy Analytics:
print("Mean:", np.mean(claim_amounts))
print("Std Dev:", np.std(claim_amounts))

📌 Key Insights
📉 Identify high-cost vs. high-frequency claim regions
🔍 Detect anomalies such as negative values or missing data
👵 Breakdown claims by age groups, gender, and region
📆 Understand trends over time using SQL's FORMAT(Date, 'yyyy-MM')

🛠 Prerequisites
Python 3.x
SQL Server (Express or Standard)
Python packages: pandas, numpy, sqlalchemy, pyodbc

🤝 Contributing
Feel free to fork this repo, raise issues, or submit PRs to improve the analysis or add dashboarding tools (e.g., Power BI, Streamlit).

👨‍💻 Author
Arnab Mondal
Data Analyst in progress, specializing in Python, SQL, and Power BI for data-driven insights in healthcare & insurance domains.
