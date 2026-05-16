-- ============================================================
-- E-Commerce Intelligence Suite
-- 04_ab_test.sql — A/B Test Auswertung (Checkout Variante)
-- ============================================================

-- ============================================================
-- SCHRITT 1: Kennzahlen pro Variante
-- ============================================================
DROP TABLE IF EXISTS ab_summary;

CREATE TABLE ab_summary AS
SELECT
    ab_variant,
    COUNT(DISTINCT customer_id)                         AS unique_customers,
    COUNT(DISTINCT invoiceno)                           AS total_orders,
    ROUND(SUM(revenue)::NUMERIC, 2)                     AS total_revenue,
    ROUND(AVG(revenue)::NUMERIC, 2)                     AS avg_order_value,
    ROUND(SUM(revenue)::NUMERIC / 
          COUNT(DISTINCT customer_id), 2)               AS revenue_per_customer
FROM fact_orders
WHERE customer_id != 0
  AND quantity > 0
  AND revenue > 0
GROUP BY ab_variant;

-- Schnellcheck
SELECT * FROM ab_summary;

-- ============================================================
-- SCHRITT 2: Conversion Rate pro Variante
-- (Orders pro Kunde als Proxy für Conversion)
-- ============================================================
SELECT
    ab_variant,
    unique_customers,
    total_orders,
    avg_order_value,
    revenue_per_customer,
    ROUND(total_orders::NUMERIC / unique_customers, 2)  AS orders_per_customer
FROM ab_summary;

-- ============================================================
-- SCHRITT 3: Statistischer Signifikanztest
-- Welche Variante hat signifikant höheren Umsatz pro Kunde?
-- T-Test Approximation via Mittelwert + Standardabweichung
-- ============================================================
SELECT
    ab_variant,
    COUNT(*)                                            AS n,
    ROUND(AVG(revenue)::NUMERIC, 2)                     AS mean_revenue,
    ROUND(STDDEV(revenue)::NUMERIC, 2)                  AS std_revenue,
    -- Standard Error
    ROUND((STDDEV(revenue) / SQRT(COUNT(*)))::NUMERIC, 4) AS std_error
FROM fact_orders
WHERE customer_id != 0
  AND quantity > 0
  AND revenue > 0
GROUP BY ab_variant;

-- ============================================================
-- SCHRITT 4: Umsatz pro Kampagne & Variante
-- Welche Kampagne profitiert mehr von Variante B?
-- ============================================================
SELECT
    campaign_name,
    ab_variant,
    COUNT(DISTINCT invoiceno)                           AS orders,
    ROUND(AVG(revenue)::NUMERIC, 2)                     AS avg_order_value,
    ROUND(SUM(revenue)::NUMERIC, 2)                     AS total_revenue
FROM fact_orders
WHERE customer_id != 0
  AND quantity > 0
  AND revenue > 0
GROUP BY campaign_name, ab_variant
ORDER BY campaign_name, ab_variant;