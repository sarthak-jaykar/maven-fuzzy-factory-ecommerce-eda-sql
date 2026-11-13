-- 02_validation/03_keys_and_orphans.sql
-- Foreign-key checks: rows whose parent does not exist. Expect 0 for every check.
SELECT 'order_items -> orders' AS check_name, COUNT(*) AS orphan_rows
FROM raw.order_items oi WHERE NOT EXISTS (SELECT 1 FROM raw.orders o WHERE o.order_id = oi.order_id)
UNION ALL
SELECT 'order_items -> products', COUNT(*)
FROM raw.order_items oi WHERE NOT EXISTS (SELECT 1 FROM raw.products p WHERE p.product_id = oi.product_id)
UNION ALL
SELECT 'orders -> website_sessions', COUNT(*)
FROM raw.orders o WHERE NOT EXISTS (SELECT 1 FROM raw.website_sessions s WHERE s.website_session_id = o.website_session_id)
UNION ALL
SELECT 'orders -> primary product', COUNT(*)
FROM raw.orders o WHERE NOT EXISTS (SELECT 1 FROM raw.products p WHERE p.product_id = o.primary_product_id)
UNION ALL
SELECT 'refunds -> order_items', COUNT(*)
FROM raw.order_item_refunds r WHERE NOT EXISTS (SELECT 1 FROM raw.order_items oi WHERE oi.order_item_id = r.order_item_id)
UNION ALL
SELECT 'pageviews -> website_sessions', COUNT(*)
FROM raw.website_pageviews pv WHERE NOT EXISTS (SELECT 1 FROM raw.website_sessions s WHERE s.website_session_id = pv.website_session_id)
UNION ALL
SELECT 'sessions with no pageviews (informational)', COUNT(*)
FROM raw.website_sessions s WHERE NOT EXISTS (SELECT 1 FROM raw.website_pageviews pv WHERE pv.website_session_id = s.website_session_id);
