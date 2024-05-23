/*
  My understanding of "over the last two years" is last 24 full months. If it was meant as last full 2 years, the WHERE condition would be slightly different.
*/


WITH

-- CTE that generates the calendar table with one row per month for the past 24 full months:
tmp_month_spine AS (
  SELECT
      month_start_date,
      EXTRACT(YEAR FROM month_start_date) AS year,
      EXTRACT(MONTH FROM month_start_date) AS month,
  FROM
    UNNEST(GENERATE_DATE_ARRAY(DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 24 MONTH), DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 DAY), INTERVAL 1 MONTH)) AS month_start_date
),

-- CTE that calculates monthly revenue for the past 24 full months:
tmp_revenue AS (
  SELECT
    DATE(DATE_TRUNC(`timestamp`, MONTH)) AS month_start_date,
    SUM(amount) AS revenue
  FROM `dataset_name.payment`
  WHERE
    DATE(`timestamp`) BETWEEN DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 24 MONTH) AND DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 DAY)
  GROUP BY 1
)
  
SELECT
  tmp_month_spine.year,
  tmp_month_spine.month,
  COALESCE(tmp_revenue.revenue, 0) AS revenue
FROM tmp_month_spine
LEFT JOIN tmp_revenue
  ON tmp_revenue.month_start_date = tmp_month_spine.month_start_date
ORDER BY tmp_month_spine.month_start_date DESC
