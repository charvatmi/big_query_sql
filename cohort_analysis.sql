SELECT
  DATE(DATE_TRUNC(customers.registration_timestamp, MONTH)) as monthly_cohort,
  COUNT(DISTINCT IF(DATE_DIFF(customers.registration_timestamp, payments.`timestamp`, DAY) < 31, customers.customer_id, null))
  /
  COUNT(DISTINCT customers.customer_id) AS first_transaction_within_one_month_after_registration_percentage
FROM `dataset_name.customers` AS customers
JOIN `dataset_name.payments` AS payments
  ON payments.customer_id = customers.customer_id
GROUP BY 1
ORDER BY 1 DESC



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