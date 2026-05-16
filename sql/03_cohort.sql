-- ============================================================
-- E-Commerce Intelligence Suite
-- 03_cohort.sql — Cohort Retention Analyse
-- ============================================================

-- ============================================================
-- SCHRITT 1: Ersten Kaufmonat pro Kunde ermitteln
-- ============================================================
DROP TABLE IF EXISTS cohort_base;

CREATE TABLE cohort_base AS
SELECT
    customer_id,
    DATE_TRUNC('month', MIN(invoicedate))::DATE AS cohort_month
FROM fact_orders
WHERE customer_id != 0
  AND quantity > 0
  AND revenue > 0
GROUP BY customer_id;

-- ============================================================
-- SCHRITT 2: Jeden Kauf einem Cohort-Monat zuordnen
-- ============================================================
DROP TABLE IF EXISTS cohort_orders;

CREATE TABLE cohort_orders AS
SELECT
    f.customer_id,
    c.cohort_month,
    DATE_TRUNC('month', f.invoicedate)::DATE AS order_month,
    -- Wie viele Monate nach dem ersten Kauf?
    EXTRACT(YEAR FROM AGE(
        DATE_TRUNC('month', f.invoicedate),
        c.cohort_month
    )) * 12 +
    EXTRACT(MONTH FROM AGE(
        DATE_TRUNC('month', f.invoicedate),
        c.cohort_month
    ))                                        AS period_number
FROM fact_orders f
JOIN cohort_base c ON f.customer_id = c.customer_id
WHERE f.customer_id != 0
  AND f.quantity > 0
  AND f.revenue > 0;

-- ============================================================
-- SCHRITT 3: Retention Tabelle
-- ============================================================
DROP TABLE IF EXISTS cohort_retention;

CREATE TABLE cohort_retention AS
SELECT
    cohort_month,
    period_number,
    COUNT(DISTINCT customer_id) AS customers
FROM cohort_orders
GROUP BY cohort_month, period_number;

-- ============================================================
-- SCHRITT 4: Retention Rate berechnen
-- ============================================================
SELECT
    r.cohort_month,
    r.period_number,
    r.customers,
    first.customers                                         AS cohort_size,
    ROUND(r.customers::NUMERIC / first.customers * 100, 1) AS retention_rate
FROM cohort_retention r
JOIN cohort_retention first
    ON r.cohort_month = first.cohort_month
    AND first.period_number = 0
WHERE r.period_number <= 7
ORDER BY r.cohort_month, r.period_number;

SELECT COUNT(*) FROM fact_orders;

SELECT
    r.cohort_month,
    r.period_number,
    r.customers,
    first.customers                                         AS cohort_size,
    ROUND(r.customers::NUMERIC / first.customers * 100, 1) AS retention_rate
FROM cohort_retention r
JOIN cohort_retention first
    ON r.cohort_month = first.cohort_month
    AND first.period_number = 0
WHERE r.period_number <= 7
ORDER BY r.cohort_month, r.period_number;