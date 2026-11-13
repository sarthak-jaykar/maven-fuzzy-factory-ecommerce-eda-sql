-- Q7. Does ordering more than one item lift order value?
-- Grain of output: one row per order type (single-item or multi-item).
SELECT
    CASE WHEN items_purchased > 1 THEN 'Multi-item order' ELSE 'Single-item order' END AS order_type,
    COUNT(*)                                                             AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)                   AS pct_of_orders,
    SUM(price_usd)                                                       AS revenue_usd,
    ROUND(AVG(price_usd), 2)                                             AS avg_order_value_usd,
    ROUND(AVG(items_purchased), 2)                                       AS avg_items_per_order
FROM raw.orders
GROUP BY CASE WHEN items_purchased > 1 THEN 'Multi-item order' ELSE 'Single-item order' END
ORDER BY order_type;
