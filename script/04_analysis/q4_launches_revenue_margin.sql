-- Q4. How have product launches affected revenue and margin?
-- Part A: monthly orders, revenue, margin and month-on-month change. Part B: revenue by product by month.
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', created_at)::date AS month,
        COUNT(*)                               AS orders,
        SUM(price_usd)                         AS revenue_usd,
        SUM(gross_margin_usd)                  AS gross_margin_usd
    FROM analytics.v_order_enriched
    GROUP BY DATE_TRUNC('month', created_at)
)
SELECT
    m.month,
    m.orders,
    m.revenue_usd,
    ROUND(m.revenue_usd / m.orders, 2)                          AS avg_order_value_usd,
    m.gross_margin_usd,
    ROUND(100.0 * m.gross_margin_usd / NULLIF(m.revenue_usd, 0), 2) AS gross_margin_pct,
    ROUND(100.0 * (m.revenue_usd - LAG(m.revenue_usd) OVER (ORDER BY m.month))
          / NULLIF(LAG(m.revenue_usd) OVER (ORDER BY m.month), 0), 2) AS revenue_mom_pct,
    (SELECT STRING_AGG(p.product_name, ', ')
     FROM raw.products p
     WHERE DATE_TRUNC('month', p.created_at)::date = m.month)   AS product_launched_this_month
FROM monthly m
ORDER BY m.month;

-- Part B: revenue by product by month
SELECT
    DATE_TRUNC('month', created_at)::date AS month,
    product_name,
    COUNT(*)                               AS items_sold,
    SUM(price_usd)                         AS revenue_usd,
    SUM(price_usd - cogs_usd)              AS gross_margin_usd
FROM analytics.v_order_items_enriched
GROUP BY DATE_TRUNC('month', created_at), product_name
ORDER BY month, product_name;
