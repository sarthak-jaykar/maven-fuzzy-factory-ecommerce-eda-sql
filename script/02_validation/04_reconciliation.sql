-- 02_validation/04_reconciliation.sql
-- Business-rule reconciliations. Each row shows the count of rows that break the rule (expect 0 unless noted).
WITH item_counts AS (
    SELECT order_id, COUNT(*) AS n_items, SUM(price_usd) AS item_price FROM raw.order_items GROUP BY order_id
)
SELECT 'orders.items_purchased <> count of order_items' AS rule,
       COUNT(*) FILTER (WHERE o.items_purchased <> COALESCE(ic.n_items, 0)) AS violating_rows
FROM raw.orders o LEFT JOIN item_counts ic USING (order_id)
UNION ALL
SELECT 'orders.price_usd <> sum of order_items.price_usd',
       COUNT(*) FILTER (WHERE o.price_usd <> COALESCE(ic.item_price, 0))
FROM raw.orders o LEFT JOIN item_counts ic USING (order_id)
UNION ALL
SELECT 'order_item refunded more than once (rows)',
       COUNT(*) FROM (SELECT order_item_id FROM raw.order_item_refunds GROUP BY order_item_id HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'refund amount greater than item price',
       COUNT(*) FROM raw.order_item_refunds r JOIN raw.order_items oi USING (order_item_id)
       WHERE r.refund_amount_usd > oi.price_usd
UNION ALL
SELECT 'sessions with more than one order (informational)',
       COUNT(*) FROM (SELECT website_session_id FROM raw.orders GROUP BY website_session_id HAVING COUNT(*) > 1) x
UNION ALL
SELECT 'orders whose timestamp is before their session start',
       COUNT(*) FROM raw.orders o JOIN raw.website_sessions s USING (website_session_id)
       WHERE o.created_at < s.created_at;

-- Date ranges per table (for the data quality log)
SELECT 'orders' AS tbl, MIN(created_at) AS first_ts, MAX(created_at) AS last_ts FROM raw.orders UNION ALL
SELECT 'website_sessions', MIN(created_at), MAX(created_at) FROM raw.website_sessions UNION ALL
SELECT 'order_item_refunds', MIN(created_at), MAX(created_at) FROM raw.order_item_refunds;
