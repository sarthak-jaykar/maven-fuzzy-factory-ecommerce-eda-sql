-- Q1. Where do we lose the most visitors on the path to purchase?
-- Grain of output: one row per funnel step.
WITH f AS (
    SELECT
        COUNT(*)                                       AS n_sessions,
        SUM(reached_products::int)                     AS n_products,
        SUM(reached_product_detail::int)               AS n_detail,
        SUM(reached_cart::int)                         AS n_cart,
        SUM(reached_shipping::int)                     AS n_shipping,
        SUM(reached_billing::int)                      AS n_billing,
        SUM(reached_thank_you::int)                    AS n_thank_you
    FROM analytics.v_session_funnel
),
steps AS (
    SELECT 1 AS step_no, 'All sessions' AS step, n_sessions AS n FROM f UNION ALL
    SELECT 2, 'Product list page', n_products FROM f UNION ALL
    SELECT 3, 'Product detail page', n_detail FROM f UNION ALL
    SELECT 4, 'Cart', n_cart FROM f UNION ALL
    SELECT 5, 'Shipping', n_shipping FROM f UNION ALL
    SELECT 6, 'Billing', n_billing FROM f UNION ALL
    SELECT 7, 'Thank-you (order confirmed)', n_thank_you FROM f
)
SELECT
    step_no,
    step,
    n AS sessions,
    ROUND(100.0 * n / FIRST_VALUE(n) OVER (ORDER BY step_no), 2)          AS pct_of_all_sessions,
    ROUND(100.0 * n / NULLIF(LAG(n) OVER (ORDER BY step_no), 0), 2)       AS pct_of_previous_step,
    LAG(n) OVER (ORDER BY step_no) - n                                    AS sessions_lost_from_previous
FROM steps
ORDER BY step_no;
