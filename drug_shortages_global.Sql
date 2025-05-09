CREATE DATABASE  Drugs_shortage_global;

USE Drugs_shortage_global;

CREATE TABLE Drugs_shortage
(
Discontinued_date text,	
Update_type	text,
Initial_posting_date	date,
Proprietary_name	text,
Strength	text,
Generic_name	text,
Related_info	text,
Updated_date	date,
Therapeutic_category text,	
Dosage_form	text,
Company_name	text,
Drug_status	text,
CompanyBrand_name	text,
CompanyGeneric_name	text,
Manufacturer_name	text,
Route	text,
Substance_name text,	
Availability	text,
Shortage_reason	text,
Changed_date date
);

------ SET GLOBAL LOCAL_INFILE=ON;
LOAD DATA LOCAL INFILE 'C:/Users/PC/Downloads/drug_shortages_global.csv' INTO TABLE Drugs_shortage
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

Select * from Drugs_shortage;

#1.Commonly most discontinued drugs?

SELECT proprietary_name, COUNT(*) AS discontinued_mentions
FROM drugs_shortage
WHERE drug_status LIKE '%Discontinued%'
GROUP BY proprietary_name
ORDER BY discontinued_mentions DESC
LIMIT 10;

#2. Which suppliers control the majority of “at-risk” drugs?

SELECT company_name, COUNT(*) AS at_risk_count
FROM drugs_shortage
WHERE drug_status LIKE '%Discontinued%' OR drug_status = 'To Be Discontinued'
GROUP BY company_name
ORDER BY at_risk_count DESC
LIMIT 10;

#3. Where are the biggest therapy gaps by category?

SELECT therapeutic_category, COUNT(*) AS shortage_count
FROM drugs_shortage
WHERE drug_status LIKE '%Discontinued%'
GROUP BY therapeutic_category
ORDER BY shortage_count DESC;

#4. What’s the distribution of risk across dosage forms?

SELECT dosage_form, COUNT(*) AS discontinued_count
FROM drugs_shortage
WHERE drug_status LIKE '%Discontinued%'
GROUP BY dosage_form
ORDER BY discontinued_count DESC;

#5. Which critical drugs lack any alternative suppliers?

SELECT proprietary_name, COUNT(DISTINCT company_name) AS supplier_count
FROM drugs_shortage
WHERE drug_status LIKE '%Discontinued%'
GROUP BY proprietary_name
HAVING supplier_count = 1;

#6. Which therapeutic categories have the highest number of single-supplier discontinued drugs?

SELECT 
  t.therapeutic_category,
  COUNT(*) AS vulnerable_drug_count
FROM (
  SELECT
    proprietary_name,
    therapeutic_category
  FROM drugs_shortage
  WHERE drug_status LIKE '%Discontinued%'
  GROUP BY proprietary_name, therapeutic_category
  HAVING COUNT(DISTINCT company_name) = 1
) AS t
GROUP BY t.therapeutic_category
ORDER BY vulnerable_drug_count DESC
LIMIT 5;


#7. Which suppliers have the highest instability ratio?

SELECT company_name,
       CAST(SUM(CASE WHEN drug_status LIKE '%Discontinued%' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS risk_ratio
FROM drugs_shortage
GROUP BY company_name
HAVING COUNT(*) > 20
ORDER BY risk_ratio DESC;

#8. Which companies have the most drugs in “Limited Availability” or “Unavailable” status?

SELECT 
  Company_name,
  SUM(CASE WHEN Availability = 'Limited Availability' THEN 1 ELSE 0 END) +
  SUM(CASE WHEN Availability = 'Unavailable'          THEN 1 ELSE 0 END) AS constrained_drug_count
FROM drugs_shortage
GROUP BY Company_name
ORDER BY constrained_drug_count DESC
LIMIT 5;

#9. What are the top 5 most common shortage reasons?

SELECT Shortage_reason,
  COUNT(*) AS reason_count
FROM drugs_shortage
WHERE Shortage_reason IS NOT NULL
GROUP BY Shortage_reason
ORDER BY reason_count DESC
LIMIT 5;

#10. Which dosage forms are most often in shortage (any status)?

SELECT 
  Dosage_form,
  COUNT(*) AS shortage_count
FROM drugs_shortage
GROUP BY Dosage_form
ORDER BY shortage_count DESC
LIMIT 5;

#11. Which drugs have experienced the most supply‐status updates (i.e., highest volatility)?

SELECT 
  Proprietary_name,
  COUNT(*) AS update_count
FROM drugs_shortage
GROUP BY Proprietary_name
ORDER BY update_count DESC
LIMIT 10;


#12.  Post‐discontinuation volatility
SELECT 
  Proprietary_name,
  COUNT(*) AS post_discontinuation_updates
FROM drugs_shortage
WHERE Update_type IN ('Revised','Reverified')
  AND Drug_Status LIKE '%Discontinued%'
GROUP BY Proprietary_name
ORDER BY post_discontinuation_updates DESC
LIMIT 5;
