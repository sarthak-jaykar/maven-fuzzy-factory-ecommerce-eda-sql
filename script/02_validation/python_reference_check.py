"""
Independent Python reference check for the Maven Fuzzy Factory SQL project.

Recomputes the validation checks and Q1 to Q7 outputs with pandas, so the
pgAdmin results can be compared against them.

Usage (from the project root):
    python validation/python_reference_check.py

Reads CSVs from data/ and prints each result to the console.
Requires: pandas (pip install pandas)
"""
from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data"
def _show(obj):
    """Print a validation result to the console instead of saving it as a CSV."""
    print(obj.to_string() if hasattr(obj, "to_string") else obj)
    print()
    return obj

products = pd.read_csv(RAW / "products.csv", parse_dates=["created_at"])
orders = pd.read_csv(RAW / "orders.csv", parse_dates=["created_at"])
items = pd.read_csv(RAW / "order_items.csv", parse_dates=["created_at"])
refunds = pd.read_csv(RAW / "order_item_refunds.csv", parse_dates=["created_at"])
sessions = pd.read_csv(RAW / "website_sessions.csv", parse_dates=["created_at"])
pageviews = pd.read_csv(RAW / "website_pageviews.csv", parse_dates=["created_at"])

DETAIL = ["/the-original-mr-fuzzy", "/the-forever-love-bear",
          "/the-birthday-sugar-panda", "/the-hudson-river-mini-bear"]

# ---- Validation -----------------------------------------------------------
checks = {
    "row_counts": {
        "products": len(products), "orders": len(orders), "order_items": len(items),
        "order_item_refunds": len(refunds), "website_sessions": len(sessions),
        "website_pageviews": len(pageviews),
    },
    "items_purchased_mismatch": int(
        (orders.set_index("order_id")["items_purchased"]
         != items.groupby("order_id").size().reindex(orders["order_id"]).fillna(0).values).sum()),
    "order_price_vs_items_mismatch": int(
        (orders.set_index("order_id")["price_usd"].round(2)
         != items.groupby("order_id")["price_usd"].sum().reindex(orders["order_id"]).fillna(0).round(2).values).sum()),
    "items_refunded_more_than_once": int((refunds.groupby("order_item_id").size() > 1).sum()),
    "refund_amount_above_item_price": int(
        (refunds.merge(items[["order_item_id", "price_usd"]], on="order_item_id")
         .pipe(lambda d: d["refund_amount_usd"] > d["price_usd"])).sum()),
    "sessions_with_more_than_one_order": int((orders.groupby("website_session_id").size() > 1).sum()),
    "orphan_order_items_to_orders": int((~items["order_id"].isin(orders["order_id"])).sum()),
    "orphan_pageviews_to_sessions": int((~pageviews["website_session_id"].isin(sessions["website_session_id"])).sum()),
    "sessions_with_no_pageviews": int((~sessions["website_session_id"].isin(pageviews["website_session_id"])).sum()),
}
pd.DataFrame(
    [(k, v) for k, v in checks.items() if not isinstance(v, dict)],
    columns=["check", "python_result"],
).pipe(_show)
pd.Series(checks["row_counts"], name="python_rows").pipe(_show)

# ---- Session funnel (same logic as analytics.v_session_funnel) -----------
pv_flags = pageviews.assign(
    p_products=pageviews["pageview_url"].eq("/products"),
    p_detail=pageviews["pageview_url"].isin(DETAIL),
    p_cart=pageviews["pageview_url"].eq("/cart"),
    p_shipping=pageviews["pageview_url"].eq("/shipping"),
    p_billing=pageviews["pageview_url"].isin(["/billing", "/billing-2"]),
    p_thanks=pageviews["pageview_url"].eq("/thank-you-for-your-order"),
).groupby("website_session_id")[
    ["p_products", "p_detail", "p_cart", "p_shipping", "p_billing", "p_thanks"]].any()

funnel = sessions.set_index("website_session_id").join(pv_flags)
flag_cols = ["p_products", "p_detail", "p_cart", "p_shipping", "p_billing", "p_thanks"]
funnel[flag_cols] = funnel[flag_cols].fillna(False).astype(bool)
funnel["has_order"] = funnel.index.isin(orders["website_session_id"])
funnel["utm_source"] = funnel["utm_source"].fillna("(no utm)")
funnel["utm_campaign"] = funnel["utm_campaign"].fillna("(no utm)")

# ---- Q1 ------------------------------------------------------------------
steps = [("All sessions", len(funnel)),
         ("Product list page", int(funnel["p_products"].sum())),
         ("Product detail page", int(funnel["p_detail"].sum())),
         ("Cart", int(funnel["p_cart"].sum())),
         ("Shipping", int(funnel["p_shipping"].sum())),
         ("Billing", int(funnel["p_billing"].sum())),
         ("Thank-you (order confirmed)", int(funnel["p_thanks"].sum()))]
q1 = pd.DataFrame(steps, columns=["step", "sessions"])
q1.insert(0, "step_no", range(1, len(q1) + 1))
q1["pct_of_all_sessions"] = (100 * q1["sessions"] / q1["sessions"].iloc[0]).round(2)
q1["pct_of_previous_step"] = (100 * q1["sessions"] / q1["sessions"].shift(1)).round(2)
q1["sessions_lost_from_previous"] = q1["sessions"].shift(1) - q1["sessions"]
q1.pipe(_show)

# ---- Q2 ------------------------------------------------------------------
ord_ref = refunds.merge(items[["order_item_id", "order_id"]], on="order_item_id", suffixes=("", "_i"))
refund_by_order = ord_ref.groupby("order_id")["refund_amount_usd"].sum()
orders_x = orders.assign(refund_usd=orders["order_id"].map(refund_by_order).fillna(0))
ch = funnel.reset_index()[["website_session_id", "utm_source", "utm_campaign"]].merge(
    orders_x[["website_session_id", "order_id", "price_usd", "refund_usd"]],
    on="website_session_id", how="left")
q2 = ch.groupby(["utm_source", "utm_campaign"]).agg(
    sessions=("website_session_id", "nunique"),
    orders=("order_id", "count"),
    gross_revenue_usd=("price_usd", "sum"),
    refunds_usd=("refund_usd", "sum"),
).reset_index()
q2["conversion_pct"] = (100 * q2["orders"] / q2["sessions"]).round(2)
q2["net_revenue_usd"] = q2["gross_revenue_usd"] - q2["refunds_usd"]
q2["net_revenue_rank"] = q2["net_revenue_usd"].rank(ascending=False, method="min").astype(int)
q2.sort_values(["net_revenue_rank", "sessions"], ascending=[True, False]).pipe(_show)

# ---- Q3 ------------------------------------------------------------------
f3 = funnel.reset_index()
f3["month"] = f3["created_at"].dt.to_period("M").dt.to_timestamp().dt.date
q3 = f3.groupby(["device_type", "month"]).agg(
    sessions=("website_session_id", "count"), orders=("has_order", "sum")).reset_index()
q3["conversion_pct"] = (100 * q3["orders"] / q3["sessions"]).round(2)
q3.pipe(_show)
q3_all = f3.groupby("device_type").agg(
    sessions=("website_session_id", "count"), orders=("has_order", "sum")).reset_index()
q3_all["conversion_pct"] = (100 * q3_all["orders"] / q3_all["sessions"]).round(2)
q3_all.sort_values("sessions", ascending=False).pipe(_show)

# ---- Q4 ------------------------------------------------------------------
o4 = orders.assign(month=orders["created_at"].dt.to_period("M").dt.to_timestamp().dt.date,
                   margin=orders["price_usd"] - orders["cogs_usd"])
q4 = o4.groupby("month").agg(orders=("order_id", "count"), revenue_usd=("price_usd", "sum"),
                             gross_margin_usd=("margin", "sum")).reset_index()
q4["avg_order_value_usd"] = (q4["revenue_usd"] / q4["orders"]).round(2)
q4["gross_margin_pct"] = (100 * q4["gross_margin_usd"] / q4["revenue_usd"]).round(2)
q4["revenue_mom_pct"] = (100 * q4["revenue_usd"].pct_change()).round(2)
q4.pipe(_show)

# ---- Q5 ------------------------------------------------------------------
it = items.assign(is_refunded=items["order_item_id"].isin(refunds["order_item_id"]),
                  refund_usd=items["order_item_id"].map(refunds.groupby("order_item_id")["refund_amount_usd"].sum()).fillna(0),
                  month=items["created_at"].dt.to_period("M").dt.to_timestamp().dt.date)
it = it.merge(products[["product_id", "product_name"]], on="product_id")
q5a = it.groupby("product_name").agg(items_sold=("order_item_id", "count"),
                                     items_refunded=("is_refunded", "sum"),
                                     refund_usd=("refund_usd", "sum")).reset_index()
q5a["refund_rate_items_pct"] = (100 * q5a["items_refunded"] / q5a["items_sold"]).round(2)
q5a.sort_values("refund_rate_items_pct", ascending=False).pipe(_show)
q5b = it.groupby("month").agg(items_sold=("order_item_id", "count"), items_refunded=("is_refunded", "sum")).reset_index()
q5b["refund_rate_items_pct"] = (100 * q5b["items_refunded"] / q5b["items_sold"]).round(2)
q5b.pipe(_show)

# ---- Q6 ------------------------------------------------------------------
q6 = funnel.groupby("is_repeat_session").agg(sessions=("has_order", "size"),
                                             sessions_with_order=("has_order", "sum")).reset_index()
rev = orders_x.merge(funnel.reset_index()[["website_session_id", "is_repeat_session"]], on="website_session_id")
rev = rev.groupby("is_repeat_session").agg(orders=("order_id", "count"), revenue_usd=("price_usd", "sum")).reset_index()
q6 = q6.merge(rev, on="is_repeat_session", how="left")
q6["conversion_pct"] = (100 * q6["sessions_with_order"] / q6["sessions"]).round(2)
q6["avg_order_value_usd"] = (q6["revenue_usd"] / q6["orders"]).round(2)
q6.pipe(_show)

# ---- Q7 ------------------------------------------------------------------
orders["order_type"] = orders["items_purchased"].gt(1).map({True: "Multi-item order", False: "Single-item order"})
q7 = orders.groupby("order_type").agg(orders=("order_id", "count"), revenue_usd=("price_usd", "sum"),
                                      avg_order_value_usd=("price_usd", "mean"),
                                      avg_items_per_order=("items_purchased", "mean")).reset_index()
q7["pct_of_orders"] = (100 * q7["orders"] / q7["orders"].sum()).round(2)
q7["avg_order_value_usd"] = q7["avg_order_value_usd"].round(2)
q7["avg_items_per_order"] = q7["avg_items_per_order"].round(2)
q7.pipe(_show)

print("Validation:", {k: v for k, v in checks.items() if not isinstance(v, dict)})
print("Row counts:", checks["row_counts"])
print("\nQ1 funnel:\n", q1.to_string(index=False))
print("\nQ2 top channels:\n", q2.sort_values("net_revenue_rank").head(8).to_string(index=False))
print("\nQ5 by product:\n", q5a.sort_values("refund_rate_items_pct", ascending=False).to_string(index=False))
print("\nQ6:\n", q6.to_string(index=False))
print("\nQ7:\n", q7.to_string(index=False))
