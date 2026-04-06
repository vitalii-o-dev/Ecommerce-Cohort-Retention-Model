WITH user_registration AS (
  /* Define cohort based on initial account creation date */
  SELECT
    id AS user_id,
    DATE_TRUNC(DATE(created_at), MONTH) AS cohort_month
  FROM
    `bigquery-public-data.thelook_ecommerce.users`
  WHERE 
    created_at >= '2023-01-01'
),

active_purchase_months AS (
  /* Aggregate unique months where users had successful transactions */
  SELECT
    user_id,
    DATE_TRUNC(DATE(created_at), MONTH) AS activity_month
  FROM
    `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE
    status NOT IN ('Cancelled', 'Returned') -- Focus on realized revenue activity
  GROUP BY
    1, 2
),

cohort_base_counts AS (
  /* Determine denominator for each cohort month */
  SELECT
    cohort_month,
    COUNT(DISTINCT user_id) AS cohort_size
  FROM
    user_registration
  GROUP BY
    1
),

retention_aggregation AS (
  /* Map activity back to cohort and calculate relative month index */
  SELECT
    reg.cohort_month,
    base.cohort_size,
    DATE_DIFF(act.activity_month, reg.cohort_month, MONTH) AS month_number,
    COUNT(DISTINCT act.user_id) AS active_user_count
  FROM
    user_registration reg
  JOIN
    cohort_base_counts base ON reg.cohort_month = base.cohort_month
  LEFT JOIN
    active_purchase_months act ON reg.user_id = act.user_id
  WHERE 
    act.user_id IS NOT NULL -- Exclude inactive users from the index breakdown
  GROUP BY
    1, 2, 3
)

/* Final reporting view: 12-month retention window */
SELECT
  cohort_month,
  cohort_size,
  month_number,
  active_user_count,
  ROUND(SAFE_DIVIDE(active_user_count, cohort_size) * 100, 2) AS retention_pct
FROM
  retention_aggregation
WHERE
  month_number BETWEEN 0 AND 12
ORDER BY
  cohort_month DESC, 
  month_number ASC;