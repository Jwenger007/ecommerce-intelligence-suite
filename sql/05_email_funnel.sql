-- ============================================================
-- E-Commerce Intelligence Suite
-- 05_email_funnel.sql — Email Marketing Funnel Analyse
-- ============================================================

-- ============================================================
-- SCHRITT 1: Gesamt-Funnel Übersicht
-- ============================================================
SELECT
    COUNT(*)                                                AS total_transactions,
    SUM(email_sent)                                         AS emails_sent,
    SUM(email_opened)                                       AS emails_opened,
    SUM(email_clicked)                                      AS emails_clicked,
    ROUND(SUM(email_opened)::NUMERIC / 
          NULLIF(SUM(email_sent), 0) * 100, 1)             AS open_rate_pct,
    ROUND(SUM(email_clicked)::NUMERIC / 
          NULLIF(SUM(email_opened), 0) * 100, 1)           AS click_to_open_rate_pct,
    ROUND(SUM(email_clicked)::NUMERIC / 
          NULLIF(SUM(email_sent), 0) * 100, 1)             AS overall_ctr_pct
FROM fact_orders;

-- ============================================================
-- SCHRITT 2: Funnel pro Kampagne
-- ============================================================
SELECT
    campaign_name,
    SUM(email_sent)                                         AS sent,
    SUM(email_opened)                                       AS opened,
    SUM(email_clicked)                                      AS clicked,
    ROUND(SUM(email_opened)::NUMERIC /
          NULLIF(SUM(email_sent), 0) * 100, 1)             AS open_rate_pct,
    ROUND(SUM(email_clicked)::NUMERIC /
          NULLIF(SUM(email_opened), 0) * 100, 1)           AS ctor_pct,
    ROUND(SUM(CASE WHEN email_clicked = 1 
                   THEN revenue ELSE 0 END)::NUMERIC, 2)   AS revenue_from_clicks,
    ROUND(AVG(CASE WHEN email_clicked = 1 
                   THEN revenue END)::NUMERIC, 2)          AS avg_order_clicked
FROM fact_orders
WHERE email_sent = 1
GROUP BY campaign_name
ORDER BY revenue_from_clicks DESC;

-- ============================================================
-- SCHRITT 3: Email ROI pro UTM Source
-- Welcher Kanal bringt nach dem Klick am meisten?
-- ============================================================
SELECT
    utm_source,
    SUM(email_sent)                                         AS sent,
    ROUND(SUM(email_opened)::NUMERIC /
          NULLIF(SUM(email_sent), 0) * 100, 1)             AS open_rate_pct,
    ROUND(SUM(revenue)::NUMERIC, 2)                         AS total_revenue,
    ROUND(AVG(revenue)::NUMERIC, 2)                         AS avg_order_value
FROM fact_orders
WHERE email_sent = 1
  AND email_clicked = 1
GROUP BY utm_source
ORDER BY total_revenue DESC;

-- ============================================================
-- SCHRITT 4: Churn vs Email Engagement
-- Haben gechurnte Kunden weniger mit Emails interagiert?
-- ============================================================
SELECT
    churned,
    COUNT(DISTINCT customer_id)                             AS customers,
    ROUND(AVG(email_opened)::NUMERIC * 100, 1)             AS avg_open_rate_pct,
    ROUND(AVG(email_clicked)::NUMERIC * 100, 1)            AS avg_click_rate_pct,
    ROUND(AVG(revenue)::NUMERIC, 2)                        AS avg_order_value
FROM fact_orders
WHERE customer_id != 0
GROUP BY churned
ORDER BY churned;