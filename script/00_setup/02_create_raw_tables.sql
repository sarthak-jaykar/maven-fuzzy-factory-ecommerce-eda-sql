-- 00_setup/02_create_raw_tables.sql
-- Raw tables mirror the CSV files. Foreign keys are deliberately NOT enforced here so that
-- the load never fails; orphan checks are run in script/02_validation/03_keys_and_orphans.sql.
DROP TABLE IF EXISTS raw.order_item_refunds, raw.order_items, raw.orders, raw.website_pageviews,
                     raw.website_sessions, raw.products CASCADE;

CREATE TABLE raw.products (
    product_id     INTEGER PRIMARY KEY,
    created_at     TIMESTAMP,
    product_name   TEXT
);

CREATE TABLE raw.orders (
    order_id             INTEGER PRIMARY KEY,
    created_at           TIMESTAMP,
    website_session_id   INTEGER,
    user_id              INTEGER,
    primary_product_id   INTEGER,
    items_purchased      INTEGER,
    price_usd            NUMERIC(10,2),
    cogs_usd             NUMERIC(10,2)
);

CREATE TABLE raw.order_items (
    order_item_id    INTEGER PRIMARY KEY,
    created_at       TIMESTAMP,
    order_id         INTEGER,
    product_id       INTEGER,
    is_primary_item  SMALLINT,
    price_usd        NUMERIC(10,2),
    cogs_usd         NUMERIC(10,2)
);

CREATE TABLE raw.order_item_refunds (
    order_item_refund_id  INTEGER PRIMARY KEY,
    created_at            TIMESTAMP,
    order_item_id         INTEGER,
    order_id              INTEGER,
    refund_amount_usd     NUMERIC(10,2)
);

CREATE TABLE raw.website_sessions (
    website_session_id  INTEGER PRIMARY KEY,
    created_at          TIMESTAMP,
    user_id             INTEGER,
    is_repeat_session   SMALLINT,
    utm_source          TEXT,
    utm_campaign        TEXT,
    utm_content         TEXT,
    device_type         TEXT,
    http_referer        TEXT
);

CREATE TABLE raw.website_pageviews (
    website_pageview_id  INTEGER PRIMARY KEY,
    created_at           TIMESTAMP,
    website_session_id   INTEGER,
    pageview_url         TEXT
);
