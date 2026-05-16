# E-Commerce Intelligence Suite

**Built by Johannes Wenger · [@JWenger007](https://github.com/JWenger007)**

> Aspiring Data Analyst building automated data pipelines that turn raw business data into actionable insights — using SQL, Python, and modern BI tools.

---

## Overview

A full end-to-end analytics project built on the UCI Online Retail Dataset. The pipeline covers data engineering, customer segmentation, cohort analysis, A/B testing, email funnel analysis and churn prediction — connected through a PostgreSQL backend, automated via Google AppScript, and visualized in Looker Studio.

**The core business question:** How do you go from 300,000 raw transactions to a dashboard that tells you exactly who your best customers are, who is about to leave, and which campaigns are actually driving revenue?

🔗 **[View Live Dashboard](https://datastudio.google.com/reporting/aa686882-d0d2-420f-a993-34fcb4ed52d0)**

---

## Dataset

**Base:** [UCI Online Retail Dataset](https://archive.ics.uci.edu/ml/datasets/online+retail)

| | |
|---|---|
| Transactions | 300,000 |
| Unique Customers | 3,263 |
| Countries | 37 |
| Period | December 2010 – August 2011 |
| Total Revenue | £4.89M |
| Total Orders | 7,492 |
| Avg Order Value | £458.32 |

**Synthetic extensions** added via `python/01_data_generation.py` to simulate a realistic marketing environment:

| Column | Description |
|---|---|
| `campaign_name` | Seasonal campaign based on purchase date (BlackFriday, Xmas, Easter etc.) |
| `utm_source` | Traffic source: email 35%, google 30%, direct 20%, instagram 10%, referral 5% |
| `utm_medium` | Channel type: newsletter, cpc, social, none, referral |
| `ab_variant` | Checkout variant A or B — deterministic by customer_id |
| `email_sent` | Whether transaction came from an email send |
| `email_opened` | Open Rate ~62% |
| `email_clicked` | Click-to-Open Rate ~45% |
| `churned` | 1 if customer inactive >60 days before end of dataset |
| `revenue` | quantity × unit_price |

> The original UCI Online Retail Dataset contains 541,909 transactions. For this project the dataset was reduced to 300,000 rows and extended with AI-assisted synthetic data generation to simulate a realistic E-Commerce marketing environment. The original dataset contains only transactional data — additional attributes including email campaign events, UTM sources, A/B test flags and churn labels were generated with AI assistance to reflect how a real marketing data pipeline would look.

> All synthetic values use a fixed random seed (42) and are fully reproducible.

---

## Dashboard

### Page 1 — Executive Overview
![Executive Overview](Result_Screenshots(Looker_Studio)/01_executive_overview.png)
KPI scorecards for Total Revenue, Total Orders and Average Order Value. Revenue breakdown by campaign and a geo heatmap showing revenue distribution across 37 countries.

### Page 2 — Customer Segmentation
![Customer Segmentation](Result_Screenshots(Looker_Studio)/02_customer_segmentation.png)
RFM segmentation of 3,263 customers into 7 groups — Champions, Loyal Customers, At Risk, Needs Attention, New Customers, Promising and Lost. Includes churn vs active split and revenue per segment.

### Page 3 — Cohort Retention
![alt text](Result_Screenshots(Looker_Studio)/03_cohort_retention.png)
Retention heatmap showing how each monthly cohort behaves over 7 periods. December cohort maintains 35–40% retention across all months. Newer cohorts drop sharply after month 1.

### Page 4 — Marketing Performance
![alt text](Result_Screenshots(Looker_Studio)/04_marketing_performance.png)
Email funnel (104.9k sent → 64.8k opened → 29.3k clicked), campaign performance table with Open Rate and CTOR, and A/B test results comparing Checkout Variant A vs B.

---

## Key Findings

### RFM Segmentation
| Segment | Customers | Avg Revenue | Avg Recency |
|---|---|---|---|
| Champion | 735 | £4,439 | 18 days |
| Loyal Customer | 749 | £886 | 47 days |
| At Risk | 451 | £976 | 139 days |
| Needs Attention | 586 | £456 | 156 days |
| New Customer | 232 | £403 | 22 days |
| Promising | 219 | £355 | 67 days |
| Lost | 254 | £319 | 204 days |

> 451 At Risk customers with £976 avg revenue = ~£88k win-back potential with a targeted campaign.

### Cohort Retention
- December cohort (885 customers): stable retention of 35–40% across all 7 months
- July cohort: retention drops to 9% after just one month
- Christmas buyers are significantly more loyal than summer buyers — suggesting seasonal acquisition quality differs

### A/B Test
- Variant B: more orders per customer (3.44 vs 3.17), more stable results (std_error 0.23 vs 0.90)
- Variant A: higher avg order value in premium campaigns — NewYear £32.85 vs £21.89
- No universal winner — context-dependent deployment recommended

### Email Funnel
- Open Rate ~62% consistent across all campaigns
- CTOR ~45% — strong content engagement
- Summer and MayBank campaigns outperform Christmas on revenue from clicks
- Churned customers show almost identical email engagement to active ones — churn is driven by order value, not email disengagement

### Churn Prediction
| | |
|---|---|
| Model | Random Forest (100 estimators, balanced weights) |
| Accuracy | 67.7% |
| ROC-AUC | 0.695 |
| Recall (Churn) | 81% |
| Top Features | monetary, total_items, avg_order_value |

> `recency_days` was intentionally excluded to avoid data leakage — it is derived directly from the churn definition.

---

## Project Structure

```
ecommerce-intelligence-suite/
│
├── data/
│   ├── data_300k.csv                    # Raw UCI dataset (not tracked in git)
│   ├── data_enriched_fixed.csv          # Enriched dataset (not tracked in git)
│   └── churn_predictions.csv            # Model output
│
├── sql/
│   ├── 01_schema.sql                    # PostgreSQL table creation
│   ├── 02_rfm.sql                       # RFM segmentation
│   ├── 03_cohort.sql                    # Cohort retention analysis
│   ├── 04_ab_test.sql                   # A/B test evaluation
│   └── 05_email_funnel.sql              # Email funnel analysis
│
├── python/
│   ├── 01_data_generation.py            # Synthetic data generation
│   └── 02_churn_model.py               # Churn prediction model
│
├── appscript/
│   └── data_loader.gs                   # Google AppScript for Sheets automation
│
├── screenshots/
│   ├── 01_executive_overview.png
│   ├── 02_customer_segmentation.png
│   ├── 03_cohort_retention.png
│   └── 04_marketing_performance.png
│
├── .env.example
├── .gitignore
├── requirements.txt
└── README.md
```

---

## Tech Stack

| Layer | Tool |
|---|---|
| Database | PostgreSQL + pgAdmin 4 |
| Query execution | VS Code + SQLTools |
| Data engineering | Python · pandas · numpy |
| Machine learning | scikit-learn |
| Automation | Google AppScript |
| Visualization | Looker Studio |