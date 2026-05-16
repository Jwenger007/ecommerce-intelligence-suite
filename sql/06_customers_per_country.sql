SELECT
    country,
    COUNT(DISTINCT customer_id)        AS customers,
    ROUND(SUM(revenue)::NUMERIC, 2)    AS total_revenue,
    ROUND(AVG(revenue)::NUMERIC, 2)    AS avg_order_value
FROM fact_orders
WHERE customer_id != 0
  AND quantity > 0
  AND revenue > 0
GROUP BY country
ORDER BY total_revenue DESC;