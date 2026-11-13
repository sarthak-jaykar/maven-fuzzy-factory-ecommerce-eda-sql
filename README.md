# Maven Fuzzy Factory: E-Commerce Funnel and Revenue Analysis

Where an online toy store loses visitors, which marketing channels earn revenue after refunds, and what to fix first. Built in PostgreSQL on the Maven Fuzzy Factory dataset.

!\[PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql\&logoColor=white)
!\[pgAdmin](https://img.shields.io/badge/pgAdmin-4-336791)
!\[SQL](https://img.shields.io/badge/SQL-CTEs%20%7C%20Window%20Functions-informational)
!\[Domain](https://img.shields.io/badge/Domain-Business%20Analysis-success)
!\[Data Model](https://img.shields.io/badge/Data%20Model-Relational-blue)

\---

## Project Overview

An online toy store sold four products between 2012 and 2015 and ran paid and organic traffic campaigns. Growth has slowed, and the marketing and merchandising teams need to decide where to spend the next budget and what to fix first.

The analysis answers these business questions:

1. Where do we lose the most visitors on the path to purchase?
2. Which marketing channels bring in revenue that survives refunds?
3. Does device type change conversion enough to act on?
4. Did product launches add revenue, or move existing sales?
5. Are refunds concentrated in one product, month or channel?
6. Do repeat customers behave differently from new ones?
7. Does ordering more than one item lift order value?

Scope covers sessions, page views, orders, items, refunds, products, UTM channels and devices from January 2012 to March 2015. Customer profit, inventory, shipping cost and causes are out of scope.

## Dataset

**Dataset:** Maven Fuzzy Factory e-commerce sample, six related tables covering website sessions, pageviews, orders, order items, products and refunds.

**Dataset note:** Secondary dataset obtained from publicly available online educational material and used for learning and portfolio analysis. The six source CSV files are included in `data/`.

## Key Metrics (19 March 2012 to 19 March 2015)

|KPI|Result|
|-|-|
|Sessions|**472,871**|
|Orders|**32,313**|
|Overall conversion (session to order)|**6.83%**|
|Desktop conversion / mobile conversion|**8.50%** / **3.09%**|
|Items refunded|**1,731** (4.3% of 40,025 items sold); refunds are 4.4% of gross revenue|
|Orders with more than one item|**23.87%** (average order value $89.25 against $50.82 for single-item orders)|

## Key Findings

These findings describe the sample data. They show where drop-off, refunds and channel differences sit, not why, and they do not establish causal effects.

1. **The largest loss is between product detail and cart.** Of 210,214 sessions that view a product, only 94,953 (45.2%) reach the cart. That step loses 115,261 sessions, the largest loss in absolute terms.
2. **Desktop converts about 2.75 times as well as mobile.** Desktop converts at 8.50% and mobile at 3.09%. Mobile is 31% of sessions.
3. **Refund rates differ by product.** The Birthday Sugar Panda loses 6.04% of items to refunds, The Original Mr. Fuzzy 5.11%, The Forever Love Bear 2.23% and The Hudson River Mini bear 1.28%.
4. **Channel size is not channel quality.** gsearch nonbrand earns the most net revenue ($1.07M), but the socialbook pilot converts at 1.08% on 5,095 sessions. Sessions with no UTM tag convert at 7.34%.
5. **Multi-item orders carry a much higher order value.** They average $89.25 against $50.82 for single-item orders. This is an association; multi-item buyers may differ in other ways.
6. **Repeat sessions convert slightly better, but order values are similar.** Repeat sessions convert at 7.83% against 6.64% for new sessions. Average order values are $60.54 and $59.86.

## Recommended Actions

These are proposed management targets, not proven results.

|Priority|Area|Action|Proposed target|
|-|-|-|-|
|**P1**|Product page|Test clearer delivery, price and product detail on the product page.|Product detail to cart rate, tracked weekly|
|**P1**|Mobile checkout|Review the mobile journey before spending more on acquisition.|Mobile conversion rate, monthly|
|**P2**|Refunds|Review descriptions and quality complaints for the two highest-refund products before the next promotion.|Item refund rate by product, monthly|
|**P2**|Channel budget|Review socialbook pilot spend against its conversion before the next budget cycle.|Net revenue per session by channel|
|**P3**|Basket|Test an add-on offer at the cart against a control group.|Average order value per session, test against control|
|**P3**|Retention|Treat retention spend as a hypothesis to test, not a priority.|Repeat session share and conversion, monthly|

## Tools and Methodology

* **PostgreSQL and pgAdmin:** schemas, raw tables, views and seven analysis queries.
* **SQL techniques:** joins, CTEs, conditional aggregation, window functions (`RANK`, `LAG`, `FIRST\_VALUE`) and reusable views.
* **Independent check:** a pandas calculation of the same results (`script/02\_validation/`).

**Data model:** six raw tables keyed on their IDs. Orders relate to order items (one to many), items to refunds (one to at most one), sessions to orders (one to at most one) and sessions to page views (one to many). Three views rebuild the item, session and order grains, so joins do not inflate totals.

**Definitions**

* Conversion rate: sessions with an order divided by all sessions.
* Net revenue: gross revenue minus refunds, at item level.
* Refund rate: refunded items divided by items sold.
* Blank UTM fields are labelled "(no utm)" and kept, not dropped.

**Validation**

* Row counts, primary keys, orphan foreign keys and business rules are checked in `script/02\_validation/`.
* Nine of the eleven result files match the independent Python calculation, with differences only from rounding. The other two have no Python counterpart yet.

## Repository Structure

```text
maven-fuzzy-factory-ecommerce-sql/
├── README.md
├── data/                              Six source CSV files used by the analysis
├── documentation/
│   ├── 01\_business\_brief.md           Context, stakeholders, decisions, questions
│   ├── 02\_data\_and\_quality.md         Source, tables, quality decisions, checks
│   ├── 03\_findings\_and\_recommendations.md  KPI definitions, findings, actions
│   ├── how\_to\_run.txt                 Step-by-step pgAdmin guide (Windows)
├── results/                           Query outputs exported from PostgreSQL
├── screenshots/                       pgAdmin screenshots of the database and each question
└── script/
    ├── 00\_setup/                      Schemas and raw tables
    ├── 01\_load/                       Load the six CSV files
    ├── 02\_validation/                 Row counts, keys, orphans, business rules, and a Python cross-check
    ├── 03\_views/                      Order-item, session-funnel and order views
    └── 04\_analysis/                   One file per business question (Q1 to Q7)
```

## Analysis

|Business question|SQL file|Result file|
|-|-|-|
|Q1. Where do visitors drop off?|`script/04\_analysis/q1\_funnel\_drop\_off.sql`|`results/q1\_funnel.csv`|
|Q2. Which channels earn revenue after refunds?|`script/04\_analysis/q2\_channel\_net\_revenue.sql`|`results/q2\_channel.csv`|
|Q3. Does device change conversion?|`script/04\_analysis/q3\_device\_conversion.sql`|`results/q3\_device\_\*.csv`|
|Q4. Did launches add revenue or move it?|`script/04\_analysis/q4\_launches\_revenue\_margin.sql`|`results/q4\_\*.csv`|
|Q5. Where are refunds concentrated?|`script/04\_analysis/q5\_refund\_rates.sql`|`results/q5\_\*.csv`|
|Q6. Do repeat customers behave differently?|`script/04\_analysis/q6\_repeat\_vs\_new.sql`|`results/q6\_repeat.csv`|
|Q7. Does buying more than one item lift order value?|`script/04\_analysis/q7\_multi\_item\_orders.sql`|`results/q7\_multi\_item.csv`|

## Documentation

* [Business Brief](documentation/01_business_brief.md): stakeholders, decisions and questions
* [Data and Quality](documentation/02_data_and_quality.md): source, tables, quality decisions and checks
* [Findings and Recommendations](documentation/03_findings_and_recommendations.md): KPI definitions, findings and actions
* [How to Run](documentation/how_to_run.txt): step-by-step pgAdmin guide

## How to Reproduce

1. Create a PostgreSQL database named `fuzzy\_factory` in pgAdmin.
2. Place the six CSV files in `C:\\fuzzy\_factory\_raw` (see [documentation/how\_to\_run.txt](documentation/how_to_run.txt)).
3. Run the scripts in `script/` in folder order, following [documentation/how\_to\_run.txt](documentation/how_to_run.txt).
4. Optional: run `python script/02\_validation/python\_reference\_check.py` after placing the CSVs in `data/`, to recreate the expected values.

## Limitations

* Sample data from a fictional store, so the findings illustrate the method.
* No acquisition cost, so return on ad spend cannot be calculated.
* March 2012 and March 2015 are partial months and are not used to claim trends.
* Findings describe association. Multi-item and repeat-customer differences are not proof of cause.

## Author

[Sarthak Jaykar](https://www.linkedin.com/in/sarthak-jaykar/)

