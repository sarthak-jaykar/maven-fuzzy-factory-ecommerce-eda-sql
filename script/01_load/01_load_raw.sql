-- 01_load/01_load_raw.sql
-- Loads the six CSV files from C:/fuzzy_factory_raw/ into the raw schema.
-- Change the folder below only if you copied the files somewhere else.
-- Empty CSV fields are loaded as NULL (this is how the UTM and referrer nulls arrive).
COPY raw.products FROM 'C:/fuzzy_factory_raw/products.csv' WITH (FORMAT csv, HEADER true);
COPY raw.orders FROM 'C:/fuzzy_factory_raw/orders.csv' WITH (FORMAT csv, HEADER true);
COPY raw.order_items FROM 'C:/fuzzy_factory_raw/order_items.csv' WITH (FORMAT csv, HEADER true);
COPY raw.order_item_refunds FROM 'C:/fuzzy_factory_raw/order_item_refunds.csv' WITH (FORMAT csv, HEADER true);
COPY raw.website_sessions FROM 'C:/fuzzy_factory_raw/website_sessions.csv' WITH (FORMAT csv, HEADER true);
COPY raw.website_pageviews FROM 'C:/fuzzy_factory_raw/website_pageviews.csv' WITH (FORMAT csv, HEADER true);
ANALYZE raw.products;
ANALYZE raw.orders;
ANALYZE raw.order_items;
ANALYZE raw.order_item_refunds;
ANALYZE raw.website_sessions;
ANALYZE raw.website_pageviews;
