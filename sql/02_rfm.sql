-- ============================================================
-- E-Commerce Intelligence Suite
-- 02_rfm.sql — RFM Segmentierung
-- ============================================================

-- ============================================================
-- SCHRITT 1: RFM Rohwerte pro Kunde berechnen
-- ============================================================
DROP TABLE IF EXISTS rfm_base;

CREATE TABLE rfm_base AS
SELECT
    customer_id,
    country,
    MAX(invoicedate)                                    AS last_purchase,
    COUNT(DISTINCT invoiceno)                           AS frequency,
    ROUND(SUM(revenue)::NUMERIC, 2)                    AS monetary,
    (SELECT MAX(invoicedate) FROM fact_orders)::DATE
        - MAX(invoicedate)::DATE                        AS recency_days
FROM fact_orders
WHERE customer_id != 0
  AND quantity > 0
  AND revenue > 0
GROUP BY customer_id, country;

-- ============================================================
-- SCHRITT 2: RFM Scores (1-5) per NTILE
-- ============================================================
DROP TABLE IF EXISTS rfm_scores;

CREATE TABLE rfm_scores AS
SELECT
    customer_id,
    country,
    recency_days,
    frequency,
    monetary,
    -- Recency: weniger Tage = besser = Score 5
    NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score
FROM rfm_base;

-- ============================================================
-- SCHRITT 3: Segmente zuweisen
-- ============================================================
DROP TABLE IF EXISTS rfm_segments;

CREATE TABLE rfm_segments AS
SELECT
    customer_id,
    country,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    ROUND((r_score + f_score + m_score)::NUMERIC / 3, 2) AS rfm_avg,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champion'
        WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal Customer'
        WHEN r_score >= 4 AND f_score <= 2                  THEN 'New Customer'
        WHEN r_score >= 3 AND f_score <= 2                  THEN 'Promising'
        WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
        WHEN r_score <= 2 AND f_score >= 4                  THEN 'Cannot Lose Them'
        WHEN r_score = 1  AND f_score = 1                   THEN 'Lost'
        ELSE 'Needs Attention'
    END AS segment
FROM rfm_scores;

-- ============================================================
-- SCHRITT 4: Ergebnis-Übersicht
-- ============================================================
SELECT
    segment,
    COUNT(*)                                AS customers,
    ROUND(AVG(monetary)::NUMERIC, 2)        AS avg_revenue,
    ROUND(AVG(recency_days)::NUMERIC, 0)    AS avg_recency_days,
    ROUND(AVG(frequency)::NUMERIC, 1)       AS avg_orders
FROM rfm_segments
GROUP BY segment
ORDER BY avg_revenue DESC;