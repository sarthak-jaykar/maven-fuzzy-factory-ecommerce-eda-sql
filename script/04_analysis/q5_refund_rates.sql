-- Q5. Are refunds concentrated in a product, month or channel?
-- Refund rate by items: refunded items / items sold.
-- Part A: by product. Part B: by month of the item sale. Part C: by UTM source (order-item to session link).
SELECT
    product_name,
    COUNT(*)                                                       AS items_sold,
    SUM(is_refunded::int)                                          AS items_refunded,
    ROUND(100.0 * SUM(is_refunded::int) / COUNT(*), 2)             AS refund_rate_items_pct,
    SUM(price_usd)                                                 AS gross_usd,
    SUM(refund_amount_usd)                                         AS refund_usd,
    ROUND(100.0 * SUM(refund_amount_usd) / NULLIF(SUM(price_usd), 0), 2) AS refund_pct_of_value
FROM analytics.v_order_items_enriched
GROUP BY product_name
ORDER BY refund_rate_items_pct DESC;

SELECT
    DATE_TRUNC('month', e.created_at)::date                        AS month,
    COUNT(*)                                                       AS items_sold,
    SUM(e.is_refunded::int)                                        AS items_refunded,
    ROUND(100.0 * SUM(e.is_refunded::int) / COUNT(*), 2)           AS refund_rate_items_pct
FROM analytics.v_order_items_enriched e
GROUP BY DATE_TRUNC('month', e.created_at)
ORDER BY month;

SELECT
    f.utm_source,
    COUNT(*)                                                       AS items_sold,
    SUM(e.is_refunded::int)                                        AS items_refunded,
    ROUND(100.0 * SUM(e.is_refunded::int) / COUNT(*), 2)           AS refund_rate_items_pct
FROM analytics.v_order_items_enriched e
JOIN raw.orders o ON o.order_id = e.order_id
JOIN analytics.v_session_funnel f ON f.website_session_id = o.website_session_id
GROUP BY f.utm_source
ORDER BY refund_rate_items_pct DESC;
