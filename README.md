<p align="center">
  <img src="Project%20Images/Brand%20Images/fetch-wordmark-black-1024.png" alt="Fetch" width="400">
</p>

<h1 align="center">Fetch Business Intelligence</h1>

<p align="center">
  <em>From raw marketplace data to department-level decisions: sales, marketing, operations and customer intelligence.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Warehouse-BigQuery-4285F4?style=flat-square"/>
  <img src="https://img.shields.io/badge/SQL-Standard%20SQL-4479A1?style=flat-square"/>
  <img src="https://img.shields.io/badge/Python-pandas%20%C2%B7%20scikit--learn-3776AB?style=flat-square"/>
  <img src="https://img.shields.io/badge/Model-K--Means-EB6E4B?style=flat-square"/>
  <img src="https://img.shields.io/badge/BI-Tableau%20Public-E97627?style=flat-square"/>
</p>

---

## Contents

1. [About This Project](#1-about-this-project)
2. [The Business Question](#2-the-business-question)
3. [Executive Summary](#3-executive-summary)
4. [Key Findings](#4-key-findings)
5. [Recommendations to Fetch Leadership](#5-recommendations-to-fetch-leadership)
6. [Data Foundation](#6-data-foundation)
7. [Data Architecture and Tech Stack](#7-data-architecture-and-tech-stack)
8. [SQL Layer](#8-sql-layer)
9. [Tableau Dashboards](#9-tableau-dashboards)
10. [Descriptive Analytics by Department](#10-descriptive-analytics-by-department)
    - [10.1 Sales](#101-sales)
    - [10.2 Marketing](#102-marketing)
    - [10.3 Operations](#103-operations)
    - [10.4 Returns and Reviews](#104-returns-and-reviews)
11. [Marketing Ad-Spend Analysis](#11-marketing-ad-spend-analysis)
12. [Customer Segmentation (K-Means)](#12-customer-segmentation-k-means)
13. [Recommended Playbook](#13-recommended-playbook)
14. [Considered and Rejected](#14-considered-and-rejected)
15. [Limitations](#15-limitations)
16. [Deliverables](#16-deliverables)
17. [What I'd Do Next](#17-what-id-do-next)
18. [Author](#18-author)

---

## 1. About This Project

Fetch is a fast-growing UK multi-seller e-commerce marketplace. Orders and sellers have scaled quickly, but exposure to data has been limited, both in management and in day-to-day usage: leaders had no shared view of the numbers, teams used data little in their decisions, and machine learning had never been used. Fetch wants to use its data effectively.

This project builds that capability from the warehouse up, working as the analyst who joined the team. Fetch is a fictional brand.

Please read the summary deck for the project: [Fetch Analytics Portfolio](<Project Presentation/Fetch_Analytics_Portfolio.pdf>)

What was delivered:

- A BigQuery warehouse of 11 tables, with 6 joined views and a customer feature table on top
- A 15-question SQL narrative covering sales, marketing, operations, returns and customer behaviour
- Four Tableau dashboards: an overall KPI hub plus revenue, marketing and operations views
- A Python ad-spend analysis that separates channel efficiency from funnel quality
- K-Means customer segmentation, the first machine-learning use case at Fetch
- Three documented data-quality issues, each with a fix or a stated plan

![Tech stack](Project%20Images/fetch-tech-stack-flow.png)

---

## 2. The Business Question

Fetch could see orders and revenue, but not why the numbers moved. The analytics work was organised around one question per department:

- **Sales:** where does revenue come from, and how concentrated is it by category, seller and region?
- **Marketing:** which acquisition channels bring customers in efficiently, and what drives the cost differences?
- **Operations:** how reliable is delivery, and what does a late order cost in reviews and returns?
- **Customer intelligence:** who are the customers, and do they come back?

Sections 10 to 12 answer these in that order.

---

## 3. Executive Summary

Fetch's revenue grew from about £46K a month in October 2016 to about £985K a month by August 2018, without a single-category or single-seller dependency. The weak points sit elsewhere: 97% of customers buy once, a small share of late deliveries causes a large share of bad reviews, and most returns trace back to seller quality.

| Metric | Value |
|---|---|
| Period covered | Sep 2016 to Sep 2018 |
| Delivered orders | 96,478 (97.0% of all orders) |
| Revenue, delivered orders (price plus freight) | £15.4M |
| Average order value | £159.83 |
| Average review score | 4.1 out of 5 |
| Late delivery rate (date-level) | 12% |
| Return rate (items returned, of items sold) | 5.9% |
| Blended CAC (ad spend per order acquired) | £45.45 |
| Customers who buy once | 97% |


---

## 4. Key Findings

Five findings shaped the recommendations.

- **Late delivery does more damage than its volume suggests.** 12% of orders arrive late, yet they cause about 28% of all bad reviews. Late orders average a 2.27 review score against 4.29 for on-time orders, and are 6.7 times more likely to produce a bad review.
- **Retention is the largest gap.** 97% of customers buy once and 2.76% buy twice, against an indicative 25 to 40% repeat rate for mid-tier marketplaces. Growth is entirely acquisition-driven.
- **Revenue is concentrated by geography, not by seller or category.** One region produces 64.57% of revenue and the top three regions 81.5%. The top seller is only 1.6% of revenue and the top 20 categories hold about 85%.
- **Seller quality drives returns.** About 59% of returns are seller-preventable: defective product (23.45%), item not as described (21.63%) and wrong item shipped (14.14%).
- **Channel cost differences come from media prices, not funnel quality.** Click-through and conversion rates are identical across the three paid channels in this dataset, so CAC differs only through CPM. Email is the cheapest channel by a wide margin but also the smallest.

---

## 5. Recommendations to Fetch Leadership

These are areas to explore, drawn from the findings above, not fixed targets.

### 1. Build a post-purchase retention programme
With 97% of customers buying once, moving the repeat rate from 3% to 8% would roughly double the revenue base without extra acquisition spend. The largest segment, Satisfied Low-Spend (60.3% of customer records), has the best review scores and is the natural first audience for email re-engagement.

### 2. Treat late delivery as a customer-satisfaction problem first
Cutting the late rate by half would remove about 14% of all bad reviews. The first step is to find the seller, region and carrier combinations that account for most late orders.

### 3. Introduce a seller quality scorecard
Combine return reason mix, review scores and stockout frequency per seller, and use it to decide marketplace visibility. About 59% of returns are in the seller's control.

### 4. Fix stockout and reorder-point discipline
Estimated revenue at risk from stockouts is £4.5M (about 29% of realised revenue), an upper bound before substitution. Even assuming half of the missed demand is substituted, £1.8M to £2.7M remains at risk. The South East region accounts for 58% of stockout events.

### 5. Shift marketing effort towards lower-cost channels and negotiate CPM
Because funnel quality is equal across paid channels, the only lever on paid cost is media price. Email costs £2.20 per acquired order (CAC) against £43.83 for Paid Search, £57.85 for Paid Social and £76.47 for Display.

### 6. Reduce single-region exposure
64.57% of revenue from one region is a concentration risk. Track regional share monthly on the Sales dashboard.

### Areas to explore further
Three areas would need more data: repeat-purchase behaviour at person level (see Section 15), carrier-level delivery performance, and real, not synthetic, ad-funnel data.

---

## 6. Data Foundation

Fetch is a fictional brand and the data has been modelled to represent its business, covering September 2016 to September 2018. The returns, stockouts, inventory and ad-spend tables, plus the CRM and channel attributes, are synthetic and were generated to complete the business picture.

**Scope**
- 99,441 orders, 112,650 order items, 103,886 payment rows, 104,719 review rows
- 6,657 return rows, 4,077 stockout events, 363 weekly ad-spend rows
- 3,095 sellers, 32,951 products, 34,448 seller-product inventory rows
- `dim_customer` (99,441 rows) is loaded in BigQuery but is not in the `CSV Files` folder of this repo

**Data quality issues found and handled**

| # | Issue | Treatment |
|---|---|---|
| 1 | `fact_review` has the same `review_id` on more than one order, so its true grain is (order, review) | Deferred. Wrap in a dedup view with `ROW_NUMBER()` when one review per order is needed |
| 2 | `fact_ad_spend.week_start` is Tuesday-aligned, not Monday as the data dictionary stated | Join changed from `WEEK(MONDAY)` to `WEEK(TUESDAY)`: 363 unmatched rows became 62,297 matched rows |
| 3 | Delivery timestamps are batched: 14 of the 20 longest deliveries share one four-hour window on 2017-09-19, with a maximum of 210 days | Documented as a data artefact. Inflates mean delivery time by about a day. Cap to be applied in Python |

Raw tables: [`CSV Files`](<CSV Files>)

---

## 7. Data Architecture and Tech Stack

The warehouse lives in BigQuery. Analysis runs in SQL for descriptive work and in Google Colab for Python, and results are presented in Tableau Public.

| Layer | Tool | Role |
|---|---|---|
| Warehouse | BigQuery | 11 base tables plus a views layer |
| Analysis | SQL, Python (Colab) | Business questions, ad-spend analysis, K-Means |
| Presentation | Tableau Public | Four department dashboards |

| Type | Tables |
|---|---|
| **Facts** | `fact_orders`, `fact_order_items`, `fact_payment`, `fact_review`, `fact_returns`, `fact_stockouts`, `fact_ad_spend` |
| **Dimensions** | `dim_customer`, `dim_product`, `dim_seller`, `dim_inventory` |

Key joins: `fact_orders.customer_id` to `dim_customer`; `fact_order_items` to `fact_orders`, `dim_product` and `dim_seller`; `fact_payment` and `fact_review` to `fact_orders` on `order_id`. `customer_id` is generated per order, while `customer_unique_id` identifies the person.

---

## 8. SQL Layer

| File | Purpose |
|---|---|
| [`Data_exploration_cleaning.sql`](<SQL Files/Data_exploration_cleaning.sql>) | Row counts, null checks and data-quality profiling across the 11 tables |
| [`Table_Joins_Views.sql`](<SQL Files/Table_Joins_Views.sql>) | Six joined views: orders and items, payments, reviews, items and returns, inventory and stockouts, ad spend and orders |
| [`Bussiness_Question_Queries.sql`](<SQL Files/Bussiness_Question_Queries.sql>) | The 15 business-question queries behind Section 10 |
| [`Fetch Customer Behavior ML features.sql`](<SQL Files/Fetch Customer Behavior ML features.sql>) | Builds `customer_segmentation_features` for the K-Means model |

Exported view outputs used in Python are in [`CSV Files/Joins & Views SQL`](<CSV Files/Joins %26 Views SQL>).

---

## 9. Tableau Dashboards

Four dashboards: an overall KPI hub plus revenue, marketing and operations views, with KPI cards for the headline metrics. <!-- TODO: add Tableau Public URL -->

| Dashboard | Image |
|---|---|
| Overall KPI hub: revenue, AOV, CPC, CAC, return rate, review score | [View](<Project Images/Dasboards Tableau/fetch-business-overall-kpi-dashboar.png>) |
| Revenue and sales | [View](<Project Images/Dasboards Tableau/revenue-dashboard-fetch.png>) |
| Marketing efficiency | [View](<Project Images/Dasboards Tableau/marketing-dashboard-images.png>) |
| Operations and delivery | [View](<Project Images/Dasboards Tableau/fetch-operations-dashboard.png>) |

![Fetch KPI dashboard](Project%20Images/Dasboards%20Tableau/fetch-business-overall-kpi-dashboar.png)

Fetch Revenue Dashboard https://github.com/josephkennedy93jk-dotcom/Fetch-Business-Intelligence/blob/main/Project%20Images/Dasboards%20Tableau/revenue-dashboard-fetch.png

**Using the dashboards**

Fetch management had little prior exposure to dashboards, so each view is paired with a suggested owner, rhythm and first thing to check. These are suggestions for the team to adapt.

| Dashboard | Suggested owner | Review rhythm | First thing to check |
|---|---|---|---|
| Overall KPI hub | Leadership team | Monthly | Revenue, return rate and review score against the previous period |
| Revenue and sales | Sales | Monthly | Regional share of revenue and category mix |
| Marketing efficiency | Marketing | Weekly | CAC by channel and the share of orders from Organic and Direct |
| Operations and delivery | Operations | Weekly | Late delivery rate and its effect on review score |

---

## 10. Descriptive Analytics by Department

Fifteen SQL queries, grouped by the department that owns the question. Revenue queries filter to `order_status = 'delivered'` (97% of orders).

### 10.1 Sales

![Revenue by product category](Project%20Images/sales-revenue-by-product-category.png)

- Revenue grew from about £46K a month in October 2016 to about £985K a month by August 2018, with a Black Friday peak of about £1.15M in November 2017
- December 2016 shows a single order, most likely a pause or outage
- Average order value is flat at £155 to £170 across all seven acquisition channels, so channel choice is a volume and cost decision
- The top 20 categories hold about 85% of revenue and Health Beauty leads with 9%. Average order value ranges from about £132 (Bed Bath Table, 9,272 orders) to about £1,290 (Computers, 177 orders)
- Top seller is 1.6% of revenue and the top 20 sellers are 22%. 15 of the top 20 are in the largest region
- The largest region is 64.57% of revenue, the top three regions 81.5% and the top six about 95%

### 10.2 Marketing

![Orders by acquisition channel](Project%20Images/orders-by-aquisition-channel.png)

- Organic overtook Paid Search as the largest channel from April 2018
- Direct traffic grew about 40 times over the period, a proxy for brand recognition
- Every channel spiked on Black Friday 2017, about 53% above October 2017
- Revenue softened through the second quarter of 2018 after a May peak

### 10.3 Operations

![Review score distribution](Project%20Images/review-score-distribution.png)

- Median delivery time is 10 days and the mean 12.5, a right-skewed distribution. The 90th percentile is 23 days
- 12% of orders arrive late. A comparison with the Amazon Prime benchmark of about 95 to 96% on-time puts Fetch below benchmark. 
- Review scores follow a J-curve: 57.78% five-star and 11.51% one-star. The one-star bucket is 3.6 times the two-star bucket
- The NPS proxy is +34.85 and the mean review is 4.11
- Late orders average 2.27 against 4.29 on time, and 62.41% of late orders get a bad review against 9.28%

### 10.4 Returns and Reviews

![Return reasons](Project%20Images/return-reasons.png)

- Fashion categories have return rates of 14 to 21% and electronics 10 to 12%
- Computers have the highest cost per return (about £1,088). Watches and Gifts carry the largest total refund value (£123K)
- Return reasons: defective 23.45%, item not as described 21.63%, changed mind 21.21%, wrong item 14.14%, damaged in transit 12.41%, late delivery 4.43%, size or fit 2.73%
- Late delivery causes about 28% of bad reviews but only 4.43% of returns: customers keep a late item and rate the seller one star

Exploratory notebook: [`Fetch Exploratory Analysis- Returns & Reviews.ipynb`](<Python Scripts/Fetch Exploratory Analysis- Returns %26 Reviews.ipynb>)

---

## 11. Marketing Ad-Spend Analysis

Weekly ad-spend metrics are repeated on every order row after the join, so the Python step deduplicates on `(week_start, acquisition_channel)` before summing. Without that step, spend is overcounted many times over.

| Channel | Spend (£) | Orders acquired | Cost per click (£) | CAC (£) |
|---|---:|---:|---:|---:|
| Email | 22,750 | 10,319 | 0.73 | 2.20 |
| Paid Search | 1,076,309 | 24,555 | 1.10 | 43.83 |
| Paid Social | 1,133,147 | 19,588 | 1.45 | 57.85 |
| Display | 599,106 | 7,835 | 1.91 | 76.47 |

![Effective CAC by channel](Project%20Images/effective-cac-per-aquisition-channel.png)

![Clicks and impressions by channel](Project%20Images/clicks-and-impressions-per-aquisition-channeel.png)

CAC here is ad spend divided by orders acquired. Click-through rate (2.0%) and conversion rate (2.5%) are identical across the three paid channels, so CAC differs only through CPM (£22 to £38). Email runs at a 7.5% click-through rate and 33.3% conversion rate, but on a small volume. The identical paid-channel rates are an artefact of how the synthetic ad table was generated and would not be expected in real data.

---

## 12. Customer Segmentation (K-Means)

This was Fetch's first machine-learning use case. K-Means groups customer records by behaviour without needing a label.

**Method**
1. Build `customer_segmentation_features` in BigQuery (one row per `customer_id`, 99,441 rows)
2. Select 7 behavioural features: recency, total spend, average instalments, review score, return flag, refund amount and refund-to-spend ratio
3. Scale with `StandardScaler`
4. Choose k using the elbow method and silhouette scores: k = 4 scored 0.35, ahead of k = 5 and k = 6 at 0.33
5. Fit the final model and name each cluster from its mean profile

![Customer cluster profile](Project%20Images/k-means-heat-map-cluster-data.png)

| Segment | Records | Share | Avg review | Avg spend (£) | Defining trait |
|---|---:|---:|---:|---:|---|
| Satisfied Low-Spend | 59,998 | 60.3% | 4.75 | 115 | Happiest customers, smallest baskets |
| Dissatisfied Standard | 18,582 | 18.7% | 1.83 | 136 | Poor reviews, no returns: churn risk |
| High-Value Instalment | 14,314 | 14.4% | 4.26 | 379 | Highest spend, about 8 instalments |
| High-Return | 6,547 | 6.6% | 4.10 | 174 | Every record returned, 87% of spend refunded |

![Customer segment distribution](Project%20Images/fetch-customer-segments.png)

Recency is similar across segments (284 to 311 days on average), so it does not separate them. The segments are defined mainly by satisfaction, basket size, instalment use and returns.

Notebook: [`K-Means Customer Behavioral Segmentation.ipynb`](<Python Scripts/K-Means Customer Behavioral Segmentation.ipynb>)  
Scored file: [`customer_segments_final.csv`](<CSV Files/Joins %26 Views SQL/customer_segments_final.csv>)

---

## 13. Recommended Playbook

| Segment | Treatment | Expected effect |
|---|---|---|
| **Dissatisfied Standard** | Proactive service recovery after a bad review, with priority handling for late orders | Win back customers who left unhappy before they leave for good |
| **High-Return** | Review the sellers and categories behind these returns and apply the seller scorecard | Cut the operational cost of returns |
| **High-Value Instalment** | Retention contact and early access offers, since these customers carry the highest basket value | Protect the highest-value revenue |
| **Satisfied Low-Spend** | Post-purchase email sequence with category recommendations | Raise the repeat rate from the largest and happiest group |

---

## 14. Considered and Rejected

A model that only rediscovers what the data was built to contain is worse than no model.

| Considered | Verdict | Reason |
|---|---|---|
| Review-score prediction | Rejected | The dominant driver is already measured directly: late orders are 6.7 times more likely to get a bad review. A model would restate that finding |
| Churn or repeat-purchase prediction | Rejected | 97% of customers buy once, so the positive class is about 3%. The segmentation table is also keyed on `customer_id`, which is per order, so a person-level label does not exist yet |
| Return-probability model | Rejected | The returns table and its reasons are synthetic. A model trained on them would learn the generator, not customer behaviour |

**Description over prediction.** The value here is a measured, department-level view of the business, with segmentation as the first step into machine learning.

---

## 15. Limitations

- **Segmentation unit.** The 99,441 segmented records are one per `customer_id`, which is generated per order, not per person. Segment shares describe customer records, not unique people. The 97% one-time-buyer finding uses the person-level key and is not affected.
- **Synthetic tables.** Returns, stockouts, inventory, ad spend and CRM fields are generated. Findings built on them (return reasons, stockout revenue at risk, channel CAC) show the method, not real business results.
- **Identical paid-channel funnel rates** (2.0% click-through, 2.5% conversion) are a generation artefact.
- **Delivery timestamps** contain batched values (Section 6, issue 3), which inflate mean delivery time and average days late.
- **Benchmarks** quoted for repeat rate and on-time delivery are indicative.
- **Stockout revenue at risk** is an upper-bound estimate before substitution.

---

## 16. Deliverables

| Deliverable | File |
|---|---|
| Summary deck | [`Fetch_Analytics_Portfolio.pdf`](<Project Presentation/Fetch_Analytics_Portfolio.pdf>) |
| Data exploration and cleaning SQL | [`Data_exploration_cleaning.sql`](<SQL Files/Data_exploration_cleaning.sql>) |
| Joins and views SQL | [`Table_Joins_Views.sql`](<SQL Files/Table_Joins_Views.sql>) |
| Business-question SQL (15 queries) | [`Bussiness_Question_Queries.sql`](<SQL Files/Bussiness_Question_Queries.sql>) |
| K-Means feature SQL | [`Fetch Customer Behavior ML features.sql`](<SQL Files/Fetch Customer Behavior ML features.sql>) |
| Returns and reviews notebook | [`Fetch Exploratory Analysis- Returns & Reviews.ipynb`](<Python Scripts/Fetch Exploratory Analysis- Returns %26 Reviews.ipynb>) |
| K-Means notebook | [`K-Means Customer Behavioral Segmentation.ipynb`](<Python Scripts/K-Means Customer Behavioral Segmentation.ipynb>) |
| Segment file | [`customer_segments_final.csv`](<CSV Files/Joins %26 Views SQL/customer_segments_final.csv>) |
| Warehouse tables | [`CSV Files`](<CSV Files>) |
| Brand assets | [`Brand Images`](<Project Images/Brand Images>) |

---

## 17. What I'd Do Next

- **Carry `customer_unique_id` through the feature table** so segments describe people, not orders, and add real frequency and monetary features to the model.
- **Rank worst-performing seller, region and carrier combinations** for late delivery, then track them on the Operations dashboard.
- **Build the seller quality scorecard** from return reasons, review scores and stockout frequency.
- **Add a lifetime-value estimate per segment** to size retention spend.
- **Revisit prediction** once person-level repeat history and real ad data exist.

---

## 18. Author

**Joseph Kennedy**, Data Analyst

End-to-end delivery: data modelling in BigQuery, SQL analysis, Python analysis and K-Means segmentation, Tableau dashboards and stakeholder communication.
