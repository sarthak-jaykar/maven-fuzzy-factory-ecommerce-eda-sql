-- Q3. Does device type change conversion, and is the gap large enough to act on?
-- Grain of output: one row per device and month.
SELECT
    device_type,
    DATE_TRUNC('month', created_at)::date                                  AS month,
    COUNT(*)                                                               AS sessions,
    SUM(has_order::int)                                                    AS orders,
    ROUND(100.0 * SUM(has_order::int) / COUNT(*), 2)                       AS conversion_pct,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY DATE_TRUNC('month', created_at)), 2)
                                                                           AS pct_of_month_sessions
FROM analytics.v_session_funnel
GROUP BY device_type, DATE_TRUNC('month', created_at)
ORDER BY month, device_type;

-- Overall by device (all months)
SELECT
    device_type,
    COUNT(*) AS sessions,
    SUM(has_order::int) AS orders,
    ROUND(100.0 * SUM(has_order::int) / COUNT(*), 2) AS conversion_pct
FROM analytics.v_session_funnel
GROUP BY device_type
ORDER BY sessions DESC;
