/*
  I was not sure whether to calculate the forecast for the next quarter only or to do so for all past quarters historically.
  I chose the more challenging option, so that the result would be the forecast for the next quarter (based on the average growth rate of the previous three quarters) for each quarter,
  which could also be used for further evaluation of the accuracy of such a forecast.
*/

WITH

-- CTE that calculates quarterly revenue for each quarter up to the last complete one
tmp_quarterly_revenue AS (
  SELECT
    DATE_TRUNC(`timestamp`, QUARTER) as quarter_start_date,
    SUM(amount) as revenue
  FROM `dataset_name.payment`
  WHERE DATE(`timestamp`) < DATE_TRUNC(CURRENT_DATE(), QUARTER)
  GROUP BY 1
),

-- CTE that adds the revenue from previous quarter and calculates the growth rate
-- row number is added for exclusion of the first three quarter later on
tmp_quarterly_growth_rate AS (
  SELECT
    quarter_start_date,
    revenue,
    LAG(revenue) OVER (ORDER BY quarter_start_date) as previous_quarter_revenue,
    revenue / LAG(revenue) OVER (ORDER BY quarter_start_date) AS growth_rate,
    ROW_NUMBER() OVER (ORDER BY quarter_start_date) as rn
  FROM tmp_quarterly_revenue
)

-- final query that calculates the average growth rate for each quarter from three previous quarters and predicts the revenue for next quarter
SELECT
  EXTRACT(YEAR FROM quarter_start_date) AS year,
  EXTRACT(QUARTER FROM quarter_start_date) AS quarter,
  revenue,
  AVG(growth_rate) OVER (ORDER BY quarter_start_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS predicted_growth_rate_for_next_quarter,
  revenue * AVG(growth_rate) OVER (ORDER BY quarter_start_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS predicted_revenue_for_next_quarter
FROM tmp_quarterly_growth_rate
WHERE
  rn > 3
ORDER BY quarter_start_date DESC
