# SQL scripts (run in this order)

| Step | File | Purpose |
|---|---|---|
| 1 | 00_setup/01_create_schemas.sql | Create schemas raw and analytics |
| 2 | 00_setup/02_create_raw_tables.sql | Create raw tables with primary keys |
| 3 | 01_load/01_load_raw.sql | Load six CSVs from C:/fuzzy_factory_raw/ |
| 4 | 02_validation/01_row_counts.sql | Row counts vs verified counts (expect PASS) |
| 5 | 02_validation/02_primary_keys.sql | Duplicate keys (expect 0) |
| 6 | 02_validation/03_keys_and_orphans.sql | Orphan foreign keys (expect 0) |
| 7 | 02_validation/04_reconciliation.sql | Business-rule checks and date ranges |
| 8 | 03_views/01_order_items_enriched.sql | View: one row per order item |
| 9 | 03_views/02_session_funnel.sql | View: one row per session with funnel flags |
| 10 | 03_views/03_order_enriched.sql | View: one row per order with channel and refunds |
| 11 | 04_analysis/q1_funnel_drop_off.sql | Q1 |
| 12 | 04_analysis/q2_channel_net_revenue.sql | Q2 |
| 13 | 04_analysis/q3_device_conversion.sql | Q3 |
| 14 | 04_analysis/q4_launches_revenue_margin.sql | Q4 |
| 15 | 04_analysis/q5_refund_rates.sql | Q5 |
| 16 | 04_analysis/q6_repeat_vs_new.sql | Q6 |
| 17 | 04_analysis/q7_multi_item_orders.sql | Q7 |

Note: the views in step 8 to 10 are in dependency order. Run 02_session_funnel before 03_order_enriched.
Note: the reconciliation file in step 7 returns two result sets. pgAdmin shows each in its own tab.
