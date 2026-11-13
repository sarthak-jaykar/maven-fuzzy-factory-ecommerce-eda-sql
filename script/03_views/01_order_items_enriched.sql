-- 03_views/01_order_items_enriched.sql
-- Grain: one row per order item. Refunds are aggregated to the item first, so the join cannot fan out.
CREATE OR REPLACE VIEW analytics.v_order_items_enriched AS
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    p.product_name,
    oi.created_at,
    oi.is_primary_item,
    oi.price_usd,
    oi.cogs_usd,
    COALESCE(r.refund_amount_usd, 0)  AS refund_amount_usd,
    (r.order_item_id IS NOT NULL)     AS is_refunded
FROM raw.order_items oi
JOIN raw.products p ON p.product_id = oi.product_id
LEFT JOIN (
    SELECT order_item_id, SUM(refund_amount_usd) AS refund_amount_usd
    FROM raw.order_item_refunds
    GROUP BY order_item_id
) r ON r.order_item_id = oi.order_item_id;
