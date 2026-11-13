# Data and Quality

## Source
| Field | Value |
|---|---|
| Dataset | Maven Fuzzy Factory (Maven Analytics) |
| Dataset context | Secondary dataset obtained from publicly available online educational material; used for educational and portfolio analysis. |
| Period | 19 March 2012 to 19 March 2015 |
| Files | six CSV files, listed in `documentation/how_to_run.txt` |

## Tables and row grain

| Table | Grain | Rows | Key |
|---|---|---|---|
| products | one product | 4 | product_id |
| orders | one order | 32,313 | order_id |
| order_items | one item in an order | 40,025 | order_item_id |
| order_item_refunds | one refunded item | 1,731 | order_item_refund_id |
| website_sessions | one visit | 472,871 | website_session_id |
| website_pageviews | one page view | 1,188,124 | website_pageview_id |

Relationships: orders → order_items (one to many); order_items → refunds (one to at most one in this data); sessions → orders (one to at most one); sessions → pageviews (one to many).

## Data quality decisions

| Issue | Rows affected | Decision |
|---|---|---|
| UTM source and campaign blank | 83,328 sessions | Kept, labelled "(no utm)". Not dropped, not assigned to a channel. |
| HTTP referrer blank | 39,917 sessions | Kept. Not used to infer channel. |
| Orders with more than one item | 7,712 orders | Revenue is summed at item level and orders counted at order level, never mixed. |
| Partial first and last month | March 2012, March 2015 | Shown but flagged; not used to claim trends. |

## Checks run

| Check | Result |
|---|---|
| Row counts match the profiled counts | Passed (author run in pgAdmin, `script/02_validation/01_row_counts.sql`) |
| Primary keys unique | Passed (author run, `02_primary_keys.sql`) |
| No orphan foreign keys | Passed (author run, `03_keys_and_orphans.sql`) |
| Items purchased matches item count per order; order price matches sum of item prices | Passed (author run, `04_reconciliation.sql`) |
| Result tables match an independent Python calculation | 9 of 11 files match, rounding only (`script/02_validation/python_reference_check.py`) |

Note on labels: one export shows `NULL` where the expected label is `(no utm)`. The numbers are identical. The label comes from `sql/03_views/02_session_funnel.sql`, so re-run that view if you see it.
