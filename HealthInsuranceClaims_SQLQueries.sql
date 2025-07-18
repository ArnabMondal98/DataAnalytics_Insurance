---Checking all data in database---
select * from HealthInsuranceClaims;

---Remove Duplicate Claims---
WITH CTE_Duplicates AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY ClaimID ORDER BY ClaimID) AS rn
  FROM HealthInsuranceClaims)
DELETE FROM CTE_Duplicates WHERE rn > 1;

-----Handle Null Values in Critical Fields-----
-- Replace NULLs in Claim_Status
UPDATE HealthInsuranceClaims
SET ClaimStatus = 'Unknown'
WHERE ClaimStatus IS NULL;
-- Replace NULLs in Claim_Amount with 0
UPDATE HealthInsuranceClaims
SET ClaimAmount = 0
WHERE ClaimAmount IS NULL;

---Remove Impossible Age Values---
DELETE FROM HealthInsuranceClaims WHERE PatientAge < 0 OR PatientAge > 120;

---Normalize Gender Values---
UPDATE HealthInsuranceClaims SET PatientGender = CASE 
WHEN PatientGender IN ('M', 'Male') THEN 'Male'
WHEN PatientGender IN ('F', 'Female') THEN 'Female'
ELSE 'Other' END;

--Check and Fix Negative Claim Amounts--
UPDATE HealthInsuranceClaims SET ClaimAmount = ABS(ClaimAmount) WHERE ClaimAmount < 0;
/*
---Remove or Flag Records with Admission > Discharge---
-- Option 1: Delete
DELETE FROM HealthInsuranceClaims
WHERE Date_Of_Admission > Date_Of_Discharge;
-- Option 2: Flag
ALTER TABLE Health_Insurance_Claims
ADD Date_Mismatch_Flag BIT;
UPDATE HealthInsuranceClaims
SET Date_Mismatch_Flag = CASE WHEN Date_Of_Admission > Date_Of_Discharge THEN 1 ELSE 0 END;
*/

---Total Claims by Status---
SELECT ClaimStatus, COUNT(*) AS Total_Claims 
FROM HealthInsuranceClaims GROUP BY ClaimStatus;

---Average Claim Amount by Gender and Claim Type---
SELECT PatientGender, ClaimType, AVG(ClaimAmount) AS Avg_ClaimAmount
FROM HealthInsuranceClaims GROUP BY PatientGender, ClaimType;

---Top 5 Hospitals/ProviderLocation(in this Database) by Total Claim Amount---
SELECT TOP 5 ProviderLocation, SUM(ClaimAmount) AS TotalClaimed
FROM HealthInsuranceClaims
GROUP BY ProviderLocation ORDER BY TotalClaimed DESC;

---Claim Rejection Rate by ProcedureCode---
SELECT ProcedureCode,
COUNT(CASE WHEN ClaimStatus = 'Rejected' THEN 1 END) * 100.0 / COUNT(*) AS Rejection_Percentage
FROM HealthInsuranceClaims GROUP BY ProcedureCode;

---Claim Pending Rate by PatientID---
SELECT PatientID,
COUNT(CASE WHEN ClaimStatus = 'Pending' THEN 1 END) * 100.0 / COUNT(*) AS Pending_Percentage
FROM HealthInsuranceClaims GROUP BY PatientID;

---Diagnosis vs Claim Frequency---
SELECT TOP 10 DiagnosisCode, COUNT(*) AS ClaimCount
FROM HealthInsuranceClaims
GROUP BY DiagnosisCode ORDER BY ClaimCount DESC;

---Add a New Column - Claim Approval Flag---
ALTER TABLE HealthInsuranceClaims
ADD IsApproved BIT;
UPDATE HealthInsuranceClaims
SET IsApproved = CASE WHEN ClaimStatus = 'Approved' THEN 1 ELSE 0 END;

---Calculate Claim Processing Duration---
UPDATE HealthInsuranceClaims
SET DiagnosisCode = 'Unknown'
WHERE DiagnosisCode IS NULL OR LTRIM(RTRIM(DiagnosisCode)) = '';

---Bucket Age Groups---
ALTER TABLE HealthInsuranceClaims
ADD Age_Group bigint(20);
UPDATE HealthInsuranceClaims
SET Age_Group = CASE 
WHEN PatientAge < 18 THEN 'Child'
WHEN PatientAge BETWEEN 18 AND 35 THEN 'Young Adult'
WHEN PatientAge BETWEEN 36 AND 60 THEN 'Adult'
ELSE 'Senior' END;

---Identify High-Value Claims---
SELECT * FROM HealthInsuranceClaims WHERE ClaimAmount > 10000
ORDER BY ClaimAmount DESC;

---Monthly Claims Summary---
/*SELECT FORMAT(ClaimDate,'YYYY-MM') AS ClaimMonth,
       COUNT(*) AS TotalClaims,
       SUM(ClaimAmount) AS Total_Claimed
FROM HealthInsuranceClaims
GROUP BY FORMAT(ClaimDate,'YYYY-MM')
ORDER BY ClaimMonth;
*/
----------Monthly Claims Summary----------
-- Safely convert ClaimDate to a DATE type first, then format
SELECT FORMAT(TRY_CONVERT(DATE, ClaimDate), 'yyyy-MM-dd') AS ClaimMonth,
       COUNT(*) AS TotalClaims,
       SUM(ClaimAmount) AS Total_Claimed FROM HealthInsuranceClaims
-- Optional: Only include rows where ClaimDate can be successfully converted to a date
WHERE TRY_CONVERT(DATE, ClaimDate) IS NOT NULL
-- Group by the converted and formatted date to ensure correct aggregation    
GROUP BY FORMAT(TRY_CONVERT(DATE, ClaimDate), 'yyyy-MM-dd')
ORDER BY ClaimMonth;

---Create a View for Approved Claims Summary---
CREATE VIEW vw_Approved_Claims_Summary AS
SELECT ProviderLocation,
COUNT(*) AS Total_Approved_Claims,
AVG(ClaimAmount) AS Avg_Claim_Amount,
SUM(ClaimAmount) AS Total_Claimed
FROM HealthInsuranceClaims
WHERE ClaimStatus = 'Approved'
GROUP BY ProviderLocation;

---Create a Summary Table for Reporting---
SELECT ClaimType,PatientGender,Age_Group,
COUNT(*) AS Total_Claims,
SUM(ClaimAmount) AS Total_Claim_Amount,
AVG(ClaimAmount) AS Avg_Claim_Amount
INTO Claim_Type_Summary
FROM HealthInsuranceClaims
GROUP BY ClaimType, PatientGender, Age_Group;

---Create Summary View for Power BI or Reporting---
CREATE VIEW Claim_Summary_By_Region AS
SELECT ProviderLocation,
COUNT(*) AS TotalClaims,
SUM(ClaimAmount) AS TotalClaim_Amount,
AVG(ClaimAmount) AS AvgClaim_Amount,
COUNT(CASE WHEN ClaimStatus = 'Rejected' THEN 1 END) AS Rejected_Claims
FROM HealthInsuranceClaims
GROUP BY ProviderLocation;
