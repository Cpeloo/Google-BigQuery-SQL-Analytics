# ☁️ Google BigQuery E-Commerce & GA4 Event Analytics

[![BigQuery](https://img.shields.io/badge/Google_Cloud-BigQuery-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)](https://cloud.google.com/bigquery)
[![SQL](https://img.shields.io/badge/SQL-Advanced_Queries-CC292B?style=for-the-badge&logo=postgresql&logoColor=white)](https://en.wikipedia.org/wiki/SQL)
[![GA4](https://img.shields.io/badge/Google_Analytics-GA4_Events-E37400?style=for-the-badge&logo=googleanalytics&logoColor=white)](https://analytics.google.com/)
[![Looker Studio](https://img.shields.io/badge/Looker_Studio-Live_Dashboard-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://datastudio.google.com/s/pLO8WhKL5sQ)
[![Amplitude](https://img.shields.io/badge/Amplitude-User_Behavior-0052CC?style=for-the-badge&logo=amplitude&logoColor=white)](https://app.amplitude.com/analytics/demo/dashboard/wrndi0vx?source=copy+url)

An end-to-end cloud data analytics project analyzing raw digital e-commerce event streams, user session journeys, multi-stage conversion funnels, and tracking taxonomy using **Google BigQuery** and **Google Analytics 4 (GA4)** data architectures.

---

## 📌 Business Context & Core Objectives

Modern digital commerce platforms capture granular user touchpoints across millions of daily events. Converting raw semi-structured clickstreams into strategic revenue insights requires structuring unnested JSON payloads, sessionizing user journeys, and isolating conversion bottlenecks.

### Key Analytical Objectives:
- **Event Modeling & Parameter Unnesting:** Query complex nested GA4 schemas and extract key event parameters (`ga_session_id`, `page_location`, `currency`).
- **Multi-Step Funnel Conversion:** Track progression and drop-off across sequential e-commerce steps: `session_start` ➔ `view_item` ➔ `add_to_cart` ➔ `begin_checkout` ➔ `purchase`.
- **Sessionization & User Journey:** Reconstruct full user sessions using Window Functions to determine landing pages, exit pages, session duration, and bounce behaviors.
- **Monetisation & Cart Abandonment:** Quantify cart abandonment rates and Average Order Value (AOV) broken down by device type and marketing channel.
- **Data Governance & Taxonomy:** Map all custom parameters to an enterprise-grade [Customer Tracking Plan](customer_tracking_plan.xlsx).

---

## 🗂️ Repository Structure

```
Google-BigQuery-SQL-Analytics/
├── sql/
│   ├── 01_ecommerce_funnel_analysis.sql     # Multi-step conversion funnel and stage drop-offs
│   ├── 02_sessionization_user_journey.sql   # Window functions for session duration, landing & bounce
│   └── 03_cart_abandonment_and_aov.sql      # Cart creation, abandonment rates, and revenue KPIs
├── customer_tracking_plan.xlsx              # Comprehensive event taxonomy & tracking plan
└── README.md                                # Architecture documentation and project walkthrough
```

---

## 🛠️ Advanced BigQuery SQL Techniques Applied

| Technique | Business Application in Queries |
| :--- | :--- |
| **`UNNEST(event_params)`** | Flattens repeated key-value pairs to extract session identifiers and page paths without Cartesian products. |
| **Common Table Expressions (CTEs)** | Modularizes multi-step data transformations into isolated, readable, and performant stages. |
| **Window Functions (`ROW_NUMBER()`)** | Flags first and last chronological interactions per session to determine landing vs. exit pages. |
| **Conditional Aggregations (`COUNTIF`, `MAX(IF(...))`)** | Efficiently pivots transactional event milestones into session-level binary flags. |
| **Safe Mathematics (`SAFE_DIVIDE`)** | Prevents zero-division errors when calculating ratios across low-volume traffic subsets. |

---

## 📊 Event Taxonomy & Tracking Plan

The repository includes [`customer_tracking_plan.xlsx`](customer_tracking_plan.xlsx), specifying:
- **Core Event Lifecycle:** `session_start`, `view_item`, `select_item`, `add_to_cart`, `begin_checkout`, `purchase`.
- **Parameter Governance:** Parameter names, required vs. optional constraints, valid data types, sample values, and analytics triggering rules.

---

## 🚀 Live Analytics Consoles & Dashboards

* 📄 **[Google Sheets Tracking Plan (Web Preview)](https://docs.google.com/spreadsheets/d/1V8iVNja8zCJ8DI5D0fSB6dX0J5nEGY0ezAHbVw67w2s/edit?usp=sharing)**
* 📈 **[Looker Studio Dynamic Dashboard](https://datastudio.google.com/s/pLO8WhKL5sQ)**
* 🎯 **[Amplitude Behavioral Analytics Dashboard](https://app.amplitude.com/analytics/demo/dashboard/wrndi0vx?source=copy+url)**

---

## 👤 Author

**Suat Amet**  
*Data Analyst & Business Intelligence Specialist*  
* 💼 [LinkedIn](https://www.linkedin.com/in/suatamet)  
* 📧 [Email](mailto:souataxmet@gmail.com)  
* 🌐 [GitHub Profile](https://github.com/Cpeloo)
