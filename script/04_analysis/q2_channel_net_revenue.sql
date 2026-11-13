-- Q2. Which marketing channels bring in revenue that survives refunds?
-- Grain of output: one row per UTM source and campaign.
WITH ord AS (
    SELECT website_session_id, order_id, price_usd, refund_usd FROM analytics.v_order_enriched
)
SELECT
    f.utm_source,
    f.utm_campaign,
    COUNT(DISTINCT f.website_session_id)                                            AS sessions,
    COUNT(o.order_id)                                                               AS orders,
    ROUND(100.0 * COUNT(o.order_id) / NULLIF(COUNT(DISTINCT f.website_session_id), 0), 2) AS conversion_pct,
    COALESCE(SUM(o.price_usd), 0)                                                   AS gross_revenue_usd,
    COALESCE(SUM(o.refund_usd), 0)                                                  AS refunds_usd,
    COALESCE(SUM(o.price_usd), 0) - COALESCE(SUM(o.refund_usd), 0)                  AS net_revenue_usd,
    ROUND(100.0 * COALESCE(SUM(o.refund_usd), 0) / NULLIF(SUM(o.price_usd), 0), 2)  AS refund_pct_of_gross,
    RANK() OVER (ORDER BY COALESCE(SUM(o.price_usd), 0) - COALESCE(SUM(o.refund_usd), 0) DESC) AS net_revenue_rank
FROM analytics.v_session_funnel f
LEFT JOIN ord o ON o.website_session_id = f.website_session_id
GROUP BY f.utm_source, f.utm_campaign
ORDER BY net_revenue_rank, sessions DESC;
