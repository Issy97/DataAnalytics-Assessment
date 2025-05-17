### Question 1: High-Value Customers with Multiple Products


**Objective: Find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.
**Tables Used: users_customuser, savings_savingsaccount, plans_plan

**Approach:
1.  Joined the tables to link customer information with their plans and savings accounts.
2.  Used COUNT(DISTINCT CASE WHEN ...) to count the number of distinct savings and investment plans for each customer.
3.  Filtered for customers having at least one savings plan and one investment plan using a HAVING clause.
4.  Calculated total_deposits by summing the confirmed_amount.
5.  Grouped the results by customer ID and name.
6.  Ordered the results by total_deposits in descending order.

**Key Decisions:
* Used LEFT JOIN to include all customers even if they didn't have savings or investment plans.
* Used COUNT(DISTINCT CASE WHEN ...) to accurately count distinct plan types.

* **Challenge: Ensuring that customers with multiple savings or investment plans were not double-counted.
* **Solution: Used `COUNT(DISTINCT CASE WHEN ... END)` to count only unique savings and investment plans for each customer.


### Question 2: Transaction Frequency Analysis

**Objective: Calculate the average number of transactions per customer per month and categorize them.
**Tables Used: users_customuser, savings_savingsaccount

**Approach:
1.  Created a subquery to calculate the transaction count for each customer per month.
2.  Joined the subquery with the users_customuser table.
3.  Calculated the average transactions per month.
4.  Used a CASE statement to categorize customers into "High Frequency", "Medium Frequency", and "Low Frequency".
5.  Grouped the results by frequency category.

**Key Decisions:
* The main query uses a subquery to first determine the number of transactions per user.
* The results of the subquery are then used in a CASE statement to categorize users based on their average monthly transaction frequency.

 * **Challenge: Calculating the average transactions per month for each user.
*  **Solution: I created a subquery that calculates the number of transactions per user, then joined this subquery with the main query to calculate the average monthly transactions and categorize users accordingly.




### Question 3: Account Inactivity Alert


**Objective: Find all active accounts with no inflow transactions in the last 1 year.
**Tables Used: plans_plan, savings_savingsaccount

**Approach:
1.  Joined the `plans_plan` and `savings_savingsaccount` tables.
2.  Used a `CASE` statement to determine if the plan is a 'Savings' or 'Investment' plan.
3.  Found the most recent transaction date for each plan using `MAX(sa.transaction_date)`.
4.  Calculated the number of days since the last transaction using `julianday()`.
5.  Filtered for plans where the `last_transaction_date` is more than 365 days prior to the current date using a `HAVING` clause.


**Key Decisions:
* Use of `MAX(sa.transaction_date)` is crucial for determining the last activity date for each plan.
* The query uses a `HAVING` clause to filter records based on the result of an aggregate function.

* **Challenge:Identifying accounts with no transactions within the past year
* **Solution: I used the `MAX` function to get the most recent transaction date and the `julianday` function to calculate the number of days since the most recent transaction.



### Question 4: Customer Lifetime Value (CLV) Estimation

**Objective: Estimate customer lifetime value based on account tenure and transaction volume.
**Tables Used: users_customuser, savings_savingsaccount

**Approach:
1.  Joined the tables to link customer data with transaction data.
2.  Calculated account tenure in months.
3.  Calculated the total number of transactions for each customer.
4.  Applied the CLV formula.
5.  Ordered the results by CLV in descending order.

**Key Decisions:
* The CLV is calculated using the formula: CLV = (total_transactions / tenure) \* 12 \* avg_profit_per_transaction
* The final result is ordered by CLV in descending order to easily identify the most valuable customers.

* **Challenge: Accurately calculating the tenure in months.
* **Solution: I calculated the difference in days between the current date and the user's join date, then divided by 30 to approximate the number of months.


## Additional Analysis

 * Confirm there are successful transactions in savings_savingsaccount
 * how many plans belong to each plan description
 * how many accounts link to these plans with successful transactions
 * Customers with savings
 * Customers with investments

* Identifying peak transaction times.
* Analyzing correlations between account tenure and transaction volume.
* Segmenting customers based on both transaction frequency and CLV.


This analysis could provide valuable insights for marketing and customer retention strategies.


### Recommendations for Future Improvement

Based on the assessment, I would suggest the following improvements:
* Implement a more robust CLV model that incorporates additional factors, such as customer demographics and purchase history.
* Develop a dashboard to visualize key metrics, such as transaction frequency and CLV, for easier monitoring.
* Conduct further analysis to identify the root causes of account inactivity and develop targeted interventions to re-engage inactive customers.
