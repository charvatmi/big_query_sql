WITH

-- CTE recreating the is_deleted column, which is not strictly necessary in here, but anyway
tmp_product_fixed AS (
SELECT
  product_id,
  name,
  IF(ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY updated_at DESC) = 1, FALSE, TRUE) AS is_deleted
FROM `dataset_name.products`
),

-- CTE that calculates the seasonal increase in sold quantity
tmp_top_five_products AS (
  SELECT
    product_id,
    SUM(IF(EXTRACT(MONTH FROM `timestamp`) > 10, quantity, null)) AS season_sales,
    SUM(IF(EXTRACT(MONTH FROM `timestamp`) <= 10, quantity, null)) AS off_season_sales,
    SUM(IF(EXTRACT(MONTH FROM `timestamp`) > 10, quantity, null)) / SUM(IF(EXTRACT(MONTH FROM `timestamp`) <= 10, quantity, null)) AS seasonal_increase
  FROM `bigquery-public-data.london_bicycles.cycle_hire`
  WHERE
    DATE(`timestamp`) BETWEEN DATE_SUB(DATE_TRUNC(CURRENT_DATE(), YEAR), INTERVAL 1 YEAR) AND DATE_SUB(DATE_TRUNC(CURRENT_DATE(), YEAR), INTERVAL 1 DAY)
  GROUP BY 1
  ORDER BY 4 DESC
  LIMIT 5
)

SELECT
  tmp_product_fixed.name AS product_name,
  tmp_top_five_products.seasonal_increase
FROM tmp_top_five_products
JOIN tmp_product_fixed
  ON tmp_product_fixed.product_id = tmp_top_five_products.product_id
  AND tmp_product_fixed.is_deleted = FALSE
ORDER BY 2 DESC