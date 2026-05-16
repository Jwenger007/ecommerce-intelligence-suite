-- ============================================================
-- E-Commerce Intelligence Suite
-- 01_schema.sql — Tabellen erstellen
-- ============================================================

DROP TABLE IF EXISTS fact_orders;

CREATE TABLE fact_orders (
    invoiceno       VARCHAR(20),
    stockcode       VARCHAR(20),
    description     TEXT,
    quantity        INTEGER,
    invoicedate     TIMESTAMP,
    unitprice       NUMERIC(10,2),
    country         VARCHAR(100),
    campaign_name   VARCHAR(50),
    utm_source      VARCHAR(30),
    utm_medium      VARCHAR(30),
    ab_variant      CHAR(1),
    email_sent      SMALLINT,
    email_opened    SMALLINT,
    email_clicked   SMALLINT,
    churned         SMALLINT,
    revenue         NUMERIC(10,2),
    customer_id     INTEGER
);

-- Schnellcheck: Tabelle vorhanden?
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';
