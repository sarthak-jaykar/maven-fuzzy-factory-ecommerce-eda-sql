-- 03_views/03_order_enriched.sql
-- Grain: one row per order, with the session's channel and device, and total refunds for the order.
CREATE OR REPLACE VIEW analytics.v_order_enriched AS
SELECT
    o.order_id,
    o.created_at,
    o.website_session_id,
    o.items_purchased,
    o.price_usd,
    o.cogs_usd,
    (o.price_usd - o.cogs_usd)            AS gross_margin_usd,
    f.utm_source,
    f.utm_campaign,
    f.device_type,
    f.is_repeat_session,
    COALESCE(r.refund_usd, 0)             AS refund_usd
FROM raw.orders o
LEFT JOIN analytics.v_session_funnel f ON f.website_session_id = o.website_session_id
LEFT JOIN (
    SELECT oi.order_id, SUM(rf.refund_amount_usd) AS refund_usd
    FROM raw.order_item_refunds rf
    JOIN raw.order_items oi ON oi.order_item_id = rf.order_item_id
    GROUP BY oi.order_id
) r ON r.order_id = o.order_id;
