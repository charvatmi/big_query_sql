/*
  It was not specified of what should be the basis for the cohorts so I chose months as I think that's the most common choice.
  Also, I assumed that "in the first month after registration" means "in the first 30 days after registration".
*/

WITH

-- CTE that calculates the timestamp of the first transaction for each customer with at least one transaction
tmp_first_transaction AS (
  SELECT
    customer_id,
    MIN(`timestamp`) AS first_transaction_timestamp,
  FROM `dataset_name.payments`
  GROUP BY 1
)

SELECT
  DATE(DATE_TRUNC(customers.registration_timestamp, MONTH)) AS monthly_cohort,
  COUNTIF(DATE_DIFF(customers.registration_timestamp, tmp_first_transaction.first_transaction_timestamp, DAY) < 31) AS customers_with_first_transaction_within_first_month,
  COUNT(customers.customer_id) AS customers_with_transaction,
  customers_with_first_transaction_within_first_month / customers_with_transaction AS first_transaction_within_first_month_percentage
FROM `dataset_name.customers` as customers
JOIN tmp_first_transaction
  ON tmp_first_transaction.customer_id = customers.customer_id
GROUP BY 1
ORDER BY 1 DESC
