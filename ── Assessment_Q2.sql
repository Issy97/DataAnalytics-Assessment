USE adashi_staging;

USE adashi;
DESCRIBE users_customuser;
USE adashi;
DESCRIBE savings_savingsaccount;
USE adashi;
DESCRIBE plans_plan;
USE adashi;
DESCRIBE withdrawals_withdrawal;
-- Q2: Transaction Frequency Analysis
SELECT
    CASE
        WHEN transactions_per_month >= 10 THEN 'High Frequency'
        WHEN transactions_per_month >= 3 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(transactions_per_month), 2) AS avg_transactions_per_month
FROM (
    SELECT
        u.id AS customer_id,
        COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), NOW()), 1) AS transactions_per_month
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY u.id
) AS customer_tx
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');

SELECT
    CASE
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM avg_transactions_per_customer
GROUP BY frequency_category
ORDER BY
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;    
