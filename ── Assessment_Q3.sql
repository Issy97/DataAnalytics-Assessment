USE adashi_staging;

USE adashi_staging;
DESCRIBE users_customuser;
USE adashi_staging;
DESCRIBE savings_savingsaccount;
USE adashi_staging;
DESCRIBE plans_plan;
USE adashi_staging;
DESCRIBE withdrawals_withdrawal;

SELECT  
   is_fixed_investment,
   is_regular_savings,
   is_a_wallet,
   is_a_fund,
   COUNT(*) AS plan_count
FROM 
   plans_plan
GROUP BY 
   is_fixed_investment, is_regular_savings, is_a_wallet, is_a_fund
ORDER BY 
   plan_count DESC;


SELECT 
    plan_type_id,
    frequency_id,
    COUNT(*) AS count
FROM plans_plan
GROUP BY plan_type_id, frequency_id
ORDER BY count DESC;
SELECT 
    plan_source,
    description,
    COUNT(*) AS count
FROM plans_plan
GROUP BY plan_source, description
ORDER BY count DESC
LIMIT 20;

WITH savings AS (
    SELECT 
        s.owner_id,
        COUNT(DISTINCT s.plan_id) AS savings_count,
        SUM(s.confirmed_amount) AS savings_total
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE s.transaction_status = 'successful'
      AND p.plan_source = 'COWRYWISE'
      AND p.description IN (
          'Regular Savings', 'Regular Savings Plan', 'Save As You Earn', 'Save As You Earn (Interest-Free)', 
          'Vacation', 'Home', 'Group', 'Interest Free Plan', 'Family', 'Emergency'
      )
    GROUP BY s.owner_id
),
investment AS (
    SELECT 
        s.owner_id,
        COUNT(DISTINCT s.plan_id) AS investment_count,
        SUM(s.confirmed_amount) AS investment_total
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE s.transaction_status = 'successful'
      AND p.plan_source = 'COWRYWISE'
      AND p.description IN (
          'Mutual Fund', 'Fixed Investment', 'Managed Portfolio', 'USD Index', 
          'Periodic Plan', 'Periodic', 'Stash'
      )
    GROUP BY s.owner_id
)
SELECT
    u.id AS owner_id,
    u.name,
    s.savings_count,
    i.investment_count,
    COALESCE(s.savings_total, 0) + COALESCE(i.investment_total, 0) AS total_deposits
FROM users_customuser u
JOIN savings s ON u.id = s.owner_id
JOIN investment i ON u.id = i.owner_id
ORDER BY total_deposits DESC
LIMIT 100;


SELECT DISTINCT plan_source FROM plans_plan LIMIT 20;
SELECT DISTINCT description FROM plans_plan LIMIT 20;
SELECT plan_source, description, id
FROM plans_plan
WHERE plan_source LIKE '%COWRYWISE%' OR description LIKE '%COWRYWISE%'
LIMIT 10;
-- Confirm there are successful transactions in savings_savingsaccount
SELECT COUNT(*) AS successful_transactions
FROM savings_savingsaccount
WHERE transaction_status = 'successful';
-- how many plans belong to each plan description
SELECT description, COUNT(*) AS count
FROM plans_plan
WHERE plan_source = 'COWRYWISE'
GROUP BY description
ORDER BY count DESC;
-- how many accounts link to these plans with successful transactions
SELECT p.description, COUNT(DISTINCT s.owner_id) AS customers
FROM savings_savingsaccount s
JOIN plans_plan p ON s.plan_id = p.id
WHERE s.transaction_status = 'successful'
  AND p.plan_source = 'COWRYWISE'
GROUP BY p.description
ORDER BY customers DESC;
-- Customers with savings
SELECT DISTINCT s.owner_id
FROM savings_savingsaccount s
JOIN plans_plan p ON s.plan_id = p.id
WHERE s.transaction_status = 'successful'
  AND p.plan_source = 'COWRYWISE'
  AND p.description IN (
      'Regular Savings', 'Regular Savings Plan', 'Save As You Earn', 'Save As You Earn (Interest-Free)', 
      'Vacation', 'Home', 'Group', 'Interest Free Plan', 'Family', 'Emergency'
  );
  
-- Customers with investments
SELECT DISTINCT s.owner_id
FROM savings_savingsaccount s
JOIN plans_plan p ON s.plan_id = p.id
WHERE s.transaction_status = 'successful'
  AND p.plan_source = 'COWRYWISE'
  AND p.description IN (
      'Mutual Fund', 'Fixed Investment', 'Managed Portfolio', 'USD Index', 
      'Periodic Plan', 'Periodic', 'Stash'
  );
  
  SELECT 
    savings.owner_id
FROM
    (SELECT DISTINCT s.owner_id
     FROM savings_savingsaccount s
     JOIN plans_plan p ON s.plan_id = p.id
     WHERE s.transaction_status = 'successful'
       AND p.plan_source = 'COWRYWISE'
       AND p.description IN (
           'Regular Savings', 'Regular Savings Plan', 'Save As You Earn', 'Save As You Earn (Interest-Free)', 
           'Vacation', 'Home', 'Group', 'Interest Free Plan', 'Family', 'Emergency'
       )) AS savings
JOIN
    (SELECT DISTINCT s.owner_id
     FROM savings_savingsaccount s
     JOIN plans_plan p ON s.plan_id = p.id
     WHERE s.transaction_status = 'successful'
       AND p.plan_source = 'COWRYWISE'
       AND p.description IN (
           'Mutual Fund', 'Fixed Investment', 'Managed Portfolio', 'USD Index', 
           'Periodic Plan', 'Periodic', 'Stash'
       )) AS investment ON savings.owner_id = investment.owner_id;

WITH customer_transactions AS (
    SELECT
        s.owner_id,
        COUNT(*) AS total_transactions,
        TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) + 1 AS active_months
    FROM savings_savingsaccount s
    WHERE s.transaction_status = 'successful'
    GROUP BY s.owner_id
),
customer_frequency AS (
    SELECT
        owner_id,
        total_transactions,
        active_months,
        total_transactions / active_months AS avg_transactions_per_month,
        CASE
            WHEN total_transactions / active_months >= 10 THEN 'High Frequency'
            WHEN total_transactions / active_months BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM customer_transactions
)
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM customer_frequency
GROUP BY frequency_category
ORDER BY
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;
    
    SELECT
    u.id AS owner_id,
    u.name,
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id ELSE NULL END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id ELSE NULL END) AS investment_count,
    SUM(sa.confirmed_amount) / 100 AS total_deposits -- Convert kobo to naira
FROM
    users_customuser u
JOIN
    plans_plan p ON u.id = p.owner_id
LEFT JOIN
    savings_savingsaccount sa ON p.id = sa.plan_id
WHERE
    p.is_regular_savings = 1 OR p.is_a_fund = 1
GROUP BY
    u.id, u.name
HAVING
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id ELSE NULL END) >= 1
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id ELSE NULL END) >= 1
ORDER BY
    total_deposits DESC;
    
-- Assessment_Q3.sql
-- Account Inactivity Alert
SELECT
    p.id AS plan_id,
    p.owner_id,
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Unknown'
    END AS type,
    MAX(sa.transaction_date) AS last_transaction_date,
    DATEDIFF(CURDATE(), MAX(sa.transaction_date)) AS inactivity_days
FROM
    plans_plan p
LEFT JOIN
    savings_savingsaccount sa ON p.id = sa.plan_id
GROUP BY
    p.id, p.owner_id, p.is_regular_savings, p.is_a_fund
HAVING
    MAX(sa.transaction_date) < DATE_SUB(CURDATE(), INTERVAL 365 DAY)
ORDER BY
    p.id;