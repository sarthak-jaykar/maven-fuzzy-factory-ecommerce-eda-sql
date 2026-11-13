-- Q6. Do repeat customers behave differently from new ones?
-- Grain of output: one row per session type (new or repeat).
WITH sess AS (
    SELECT is_repeat_session, COUNT(*) AS sessions, SUM(has_order::int) AS sessions_with_order
    FROM analytics.v_session_funnel
    GROUP BY is_repeat_session
),
ord AS (
    SELECT is_repeat_session, COUNT(*) AS orders, SUM(price_usd) AS revenue_usd
    FROM analytics.v_order_enriched
    GROUP BY is_repeat_session
)
SELECT
    CASE WHEN s.is_repeat_session = 1 THEN 'Repeat session' ELSE 'New session' END AS session_type,
    s.sessions,
    ROUND(100.0 * s.sessions / SUM(s.sessions) OVER (), 2)                AS pct_of_sessions,
    s.sessions_with_order,
    ROUND(100.0 * s.sessions_with_order / s.sessions, 2)                  AS conversion_pct,
    COALESCE(o.orders, 0)                                                 AS orders,
    ROUND(o.revenue_usd / NULLIF(o.orders, 0), 2)                         AS avg_order_value_usd
FROM sess s
LEFT JOIN ord o USING (is_repeat_session)
ORDER BY s.is_repeat_session;
