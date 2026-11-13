-- 02_validation/01_row_counts.sql
-- Compares loaded row counts with the counts verified during profiling.
WITH expected (tbl, n) AS (
    VALUES ('products', 4), ('orders', 32313), ('order_items', 40025),
           ('order_item_refunds', 1731), ('website_sessions', 472871), ('website_pageviews', 1188124)
),
actual AS (
    SELECT 'products' AS tbl, COUNT(*) AS n FROM raw.products UNION ALL
    SELECT 'orders', COUNT(*) FROM raw.orders UNION ALL
    SELECT 'order_items', COUNT(*) FROM raw.order_items UNION ALL
    SELECT 'order_item_refunds', COUNT(*) FROM raw.order_item_refunds UNION ALL
    SELECT 'website_sessions', COUNT(*) FROM raw.website_sessions UNION ALL
    SELECT 'website_pageviews', COUNT(*) FROM raw.website_pageviews
)
SELECT e.tbl, e.n AS expected_rows, a.n AS loaded_rows,
       CASE WHEN e.n = a.n THEN 'PASS' ELSE 'FAIL' END AS status
FROM expected e
JOIN actual a USING (tbl)
ORDER BY e.tbl;
