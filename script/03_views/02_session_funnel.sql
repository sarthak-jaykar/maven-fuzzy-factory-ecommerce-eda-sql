-- 03_views/02_session_funnel.sql
-- Grain: one row per website session. Each funnel step is TRUE if the session viewed that page at least once.
CREATE OR REPLACE VIEW analytics.v_session_funnel AS
SELECT
    s.website_session_id,
    s.created_at,
    s.user_id,
    s.is_repeat_session,
    COALESCE(s.utm_source, '(no utm)')   AS utm_source,
    COALESCE(s.utm_campaign, '(no utm)') AS utm_campaign,
    s.device_type,
    COALESCE(BOOL_OR(pv.pageview_url = '/products'), FALSE) AS reached_products,
    COALESCE(BOOL_OR(pv.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear',
                                         '/the-birthday-sugar-panda', '/the-hudson-river-mini-bear')), FALSE) AS reached_product_detail,
    COALESCE(BOOL_OR(pv.pageview_url = '/cart'), FALSE)     AS reached_cart,
    COALESCE(BOOL_OR(pv.pageview_url = '/shipping'), FALSE) AS reached_shipping,
    COALESCE(BOOL_OR(pv.pageview_url IN ('/billing', '/billing-2')), FALSE) AS reached_billing,
    COALESCE(BOOL_OR(pv.pageview_url = '/thank-you-for-your-order'), FALSE) AS reached_thank_you,
    EXISTS (SELECT 1 FROM raw.orders o WHERE o.website_session_id = s.website_session_id) AS has_order
FROM raw.website_sessions s
LEFT JOIN raw.website_pageviews pv ON pv.website_session_id = s.website_session_id
GROUP BY s.website_session_id, s.created_at, s.user_id, s.is_repeat_session,
         s.utm_source, s.utm_campaign, s.device_type;
