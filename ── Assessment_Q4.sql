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

-- Q4: Customer Lifetime Value (CLV) Estimation
SELECT
    u.id AS customer_id,
    u.name,
    FLOOR(DATEDIFF(CURDATE(), u.date_joined) / 30) AS tenure_months, 
    COUNT(sa.id) AS total_transactions,
    (COUNT(sa.id) / (DATEDIFF(CURDATE(), u.date_joined) / 30)) * 12 * (AVG(sa.confirmed_amount) / 100 * 0.001) AS estimated_clv 
FROM
    users_customuser u
LEFT JOIN
    plans_plan p ON u.id = p.owner_id
LEFT JOIN
    savings_savingsaccount sa ON p.id = sa.plan_id
GROUP BY
    u.id, u.name, u.date_joined
ORDER BY
    estimated_clv DESC;