USE adashi_staging;

USE adashi_staging;
DESCRIBE users_customuser;
USE adashi_staging;
DESCRIBE savings_savingsaccount;
USE adashi_staging;
DESCRIBE plans_plan;
USE adashi_staging;
DESCRIBE withdrawals_withdrawal;
-- Q1: High-Value Customers with Multiple Products
SELECT
    u.id AS owner_id,
    u.name,
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN s.plan_id ELSE NULL END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN s.plan_id ELSE NULL END) AS investment_count,
    SUM(s.confirmed_amount / 100) AS total_deposits
FROM users_customuser u
JOIN savings_savingsaccount s ON u.id = s.owner_id
JOIN plans_plan p ON s.plan_id = p.id
WHERE s.confirmed_amount > 0
    AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)
GROUP BY u.id, u.name
HAVING savings_count > 0 AND investment_count > 0
ORDER BY total_deposits DESC;
