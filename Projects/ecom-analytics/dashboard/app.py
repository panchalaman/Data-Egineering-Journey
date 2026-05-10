"""
Olist Brazilian E-Commerce — Analytics Dashboard
6 tiles covering all 4 dbt aggregation models + KPI summary row.

Reads from RDS PostgreSQL olist_prod schema.
Secrets loaded from Streamlit Cloud secrets or environment variables.
"""

import os
import streamlit as st
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
import psycopg2
from dotenv import load_dotenv

load_dotenv()

# ---------------------------------------------------------------------------
# Page config
# ---------------------------------------------------------------------------
st.set_page_config(
    page_title="Olist E-Commerce Analytics",
    page_icon="🛒",
    layout="wide",
)

st.title("🛒 E-Commerce Analytics")
st.caption("Data: Sep 2016 – Oct 2018 · ~100k orders · Source: Kaggle olistbr/brazilian-ecommerce")

# ---------------------------------------------------------------------------
# DB connection
# ---------------------------------------------------------------------------
def get_conn():
    try:
        cfg = st.secrets["postgres"]
        return psycopg2.connect(
            host=cfg["host"],
            port=int(cfg.get("port", 5432)),
            dbname=cfg["dbname"],
            user=cfg["user"],
            password=cfg["password"],
            sslmode=cfg.get("sslmode", "require"),
            connect_timeout=10,
        )
    except (KeyError, FileNotFoundError):
        return psycopg2.connect(
            host=os.environ.get("PG_HOST", ""),
            port=int(os.environ.get("PG_PORT", 5432)),
            dbname=os.environ.get("PG_DB", "olist"),
            user=os.environ.get("PG_USER", ""),
            password=os.environ.get("PG_PASSWORD", ""),
            sslmode=os.environ.get("PG_SSLMODE", "disable"),
            connect_timeout=10,
        )


@st.cache_data(ttl=3600)
def load_monthly_orders():
    conn = get_conn()
    df = pd.read_sql(
        "SELECT * FROM olist_prod.agg_monthly_orders ORDER BY year_month",
        conn,
    )
    conn.close()
    return df


@st.cache_data(ttl=3600)
def load_category_performance():
    conn = get_conn()
    df = pd.read_sql(
        "SELECT * FROM olist_prod.agg_category_performance ORDER BY total_revenue DESC LIMIT 20",
        conn,
    )
    conn.close()
    return df


@st.cache_data(ttl=3600)
def load_delivery_performance():
    conn = get_conn()
    df = pd.read_sql(
        "SELECT * FROM olist_prod.agg_delivery_performance ORDER BY total_orders DESC",
        conn,
    )
    conn.close()
    return df


@st.cache_data(ttl=3600)
def load_payment_analysis():
    conn = get_conn()
    df = pd.read_sql(
        "SELECT * FROM olist_prod.agg_payment_analysis ORDER BY total_payment_value DESC",
        conn,
    )
    conn.close()
    return df


# ---------------------------------------------------------------------------
# KPI Summary Row
# ---------------------------------------------------------------------------
monthly = None
cats = None
deliv = None
pay = None

try:
    monthly = load_monthly_orders()
    cats    = load_category_performance()
    deliv   = load_delivery_performance()
    pay     = load_payment_analysis()

    k1, k2, k3, k4, k5 = st.columns(5)
    k1.metric("Total Orders",   f"{monthly['total_orders'].sum():,}")
    k2.metric("Total Revenue",  f"R$ {monthly['total_revenue'].sum():,.0f}")
    k3.metric("Avg Item Value", f"R$ {monthly['avg_order_item_value'].mean():.2f}")
    k4.metric("Avg Delivery",   f"{deliv['avg_delivery_days'].mean():.1f} days")
    k5.metric("On-Time Rate",   f"{deliv['on_time_rate'].mean()*100:.1f}%")
except Exception as e:
    st.error(f"KPI load error: {e}")

st.divider()

# ---------------------------------------------------------------------------
# Tile 1 — Monthly Orders & Revenue (combo bar + line)
# ---------------------------------------------------------------------------
st.subheader("📅 Tile 1: Monthly Orders & Revenue Trend")
try:
    if monthly is None:
        raise RuntimeError("Monthly dataset not loaded. Check DB connection/env vars.")

    fig1 = go.Figure()
    fig1.add_trace(go.Bar(
        x=monthly["year_month"], y=monthly["total_orders"],
        name="Total Orders", marker_color="#4C72B0", yaxis="y1",
    ))
    fig1.add_trace(go.Scatter(
        x=monthly["year_month"], y=monthly["total_revenue"],
        name="Revenue (R$)", mode="lines+markers",
        line=dict(color="#DD8452", width=2), yaxis="y2",
    ))
    fig1.update_layout(
        xaxis=dict(title="Month", tickangle=-45),
        yaxis=dict(title="Orders", side="left"),
        yaxis2=dict(title="Revenue (R$)", side="right", overlaying="y"),
        legend=dict(x=0.01, y=0.99), height=400, hovermode="x unified",
    )
    st.plotly_chart(fig1, use_container_width=True)
except Exception as e:
    st.error(f"Tile 1 error: {e}")

st.divider()

# ---------------------------------------------------------------------------
# Tile 2 — Top 20 Categories by Revenue (horizontal bar, colored by review)
# ---------------------------------------------------------------------------
st.subheader("📦 Tile 2: Top 20 Product Categories by Revenue")
try:
    if cats is None:
        raise RuntimeError("Category dataset not loaded. Check DB connection/env vars.")

    fig2 = px.bar(
        cats.sort_values("total_revenue"),
        x="total_revenue", y="product_category_name_english",
        orientation="h", color="avg_review_score",
        color_continuous_scale="RdYlGn",
        labels={
            "total_revenue": "Total Revenue (R$)",
            "product_category_name_english": "Category",
            "avg_review_score": "Avg Review ⭐",
        },
        height=520,
    )
    fig2.update_layout(yaxis=dict(tickfont=dict(size=11)))
    st.plotly_chart(fig2, use_container_width=True)
except Exception as e:
    st.error(f"Tile 2 error: {e}")

st.divider()

# ---------------------------------------------------------------------------
# Tile 3 — On-Time Delivery Rate by State (choropleth-style bar)
# ---------------------------------------------------------------------------
st.subheader("🗺️ Tile 3: Delivery Performance by Brazilian State")
try:
    if deliv is None:
        raise RuntimeError("Delivery dataset not loaded. Check DB connection/env vars.")

    col_a, col_b = st.columns(2)

    with col_a:
        fig3a = px.bar(
            deliv.sort_values("on_time_rate", ascending=False),
            x="customer_state", y="on_time_rate",
            color="on_time_rate", color_continuous_scale="RdYlGn",
            labels={"customer_state": "State", "on_time_rate": "On-Time Rate"},
            title="On-Time Delivery Rate by State",
            height=380,
        )
        fig3a.update_layout(coloraxis_showscale=False)
        st.plotly_chart(fig3a, use_container_width=True)

    with col_b:
        fig3b = px.scatter(
            deliv,
            x="avg_delivery_days", y="avg_review_score",
            size="total_orders", color="on_time_rate",
            color_continuous_scale="RdYlGn",
            hover_name="customer_state",
            labels={
                "avg_delivery_days": "Avg Delivery Days",
                "avg_review_score": "Avg Review Score",
                "on_time_rate": "On-Time Rate",
            },
            title="Delivery Days vs Review Score (bubble = order volume)",
            height=380,
        )
        st.plotly_chart(fig3b, use_container_width=True)
except Exception as e:
    st.error(f"Tile 3 error: {e}")

st.divider()

# ---------------------------------------------------------------------------
# Tile 4 — Payment Method Analysis (donut + bar)
# ---------------------------------------------------------------------------
st.subheader("💳 Tile 4: Payment Method Analysis")
try:
    if pay is None:
        raise RuntimeError("Payment dataset not loaded. Check DB connection/env vars.")

    col_c, col_d = st.columns(2)

    with col_c:
        fig4a = px.pie(
            pay, values="total_orders", names="payment_type",
            hole=0.45, title="Order Share by Payment Type",
            color_discrete_sequence=px.colors.qualitative.Set2,
            height=360,
        )
        st.plotly_chart(fig4a, use_container_width=True)

    with col_d:
        fig4b = px.bar(
            pay, x="payment_type", y="avg_payment_value",
            color="avg_review_score", color_continuous_scale="Blues",
            labels={
                "payment_type": "Payment Type",
                "avg_payment_value": "Avg Payment Value (R$)",
                "avg_review_score": "Avg Review ⭐",
            },
            title="Avg Payment Value & Review Score by Type",
            height=360,
        )
        st.plotly_chart(fig4b, use_container_width=True)
except Exception as e:
    st.error(f"Tile 4 error: {e}")

st.divider()

# ---------------------------------------------------------------------------
# Tile 5 — Monthly On-Time Rate trend
# ---------------------------------------------------------------------------
st.subheader("🚚 Tile 5: Monthly On-Time Delivery Rate")
try:
    if monthly is None:
        raise RuntimeError("Monthly dataset not loaded. Check DB connection/env vars.")

    fig5 = go.Figure()
    fig5.add_trace(go.Scatter(
        x=monthly["year_month"], y=monthly["on_time_rate"],
        mode="lines+markers", fill="tozeroy",
        line=dict(color="#2ca02c", width=2),
        name="On-Time Rate",
    ))
    fig5.update_layout(
        xaxis=dict(title="Month", tickangle=-45),
        yaxis=dict(title="On-Time Rate", tickformat=".0%", range=[0, 1]),
        height=320, hovermode="x unified",
    )
    st.plotly_chart(fig5, use_container_width=True)
except Exception as e:
    st.error(f"Tile 5 error: {e}")

st.divider()

# ---------------------------------------------------------------------------
# Tile 6 — Category bubble: orders vs revenue vs review
# ---------------------------------------------------------------------------
st.subheader("🔵 Tile 6: Category Deep-Dive (Orders vs Revenue vs Review)")
try:
    if cats is None:
        raise RuntimeError("Category dataset not loaded. Check DB connection/env vars.")

    fig6 = px.scatter(
        cats,
        x="total_orders", y="total_revenue",
        size="total_orders", color="avg_review_score",
        color_continuous_scale="RdYlGn",
        hover_name="product_category_name_english",
        labels={
            "total_orders": "Total Orders",
            "total_revenue": "Total Revenue (R$)",
            "avg_review_score": "Avg Review ⭐",
        },
        height=420,
    )
    st.plotly_chart(fig6, use_container_width=True)
except Exception as e:
    st.error(f"Tile 6 error: {e}")

st.divider()
st.caption("Built with Streamlit + Plotly · Data warehouse: AWS RDS PostgreSQL · Transformations: dbt · IaC: Terraform")
