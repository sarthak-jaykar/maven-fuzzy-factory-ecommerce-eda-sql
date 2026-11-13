-- 02_validation/02_primary_keys.sql
-- Duplicate primary keys per table. Expect 0 for every row.
SELECT 'products' AS tbl, COUNT(*) - COUNT(DISTINCT product_id) AS duplicate_keys FROM raw.products UNION ALL
SELECT 'orders', COUNT(*) - COUNT(DISTINCT order_id) FROM raw.orders UNION ALL
SELECT 'order_items', COUNT(*) - COUNT(DISTINCT order_item_id) FROM raw.order_items UNION ALL
SELECT 'order_item_refunds', COUNT(*) - COUNT(DISTINCT order_item_refund_id) FROM raw.order_item_refunds UNION ALL
SELECT 'website_sessions', COUNT(*) - COUNT(DISTINCT website_session_id) FROM raw.website_sessions UNION ALL
SELECT 'website_pageviews', COUNT(*) - COUNT(DISTINCT website_pageview_id) FROM raw.website_pageviews;
