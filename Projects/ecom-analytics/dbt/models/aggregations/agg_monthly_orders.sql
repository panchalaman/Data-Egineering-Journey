-- agg_monthly_orders.sql
-- Monthly order volume, revenue, and delivery performance trend (2016–2018).
-- PRIMARY DASHBOARD TILE: temporal line/bar chart showing growth over time.

{{ config(materialized='table') }}

select
    order_purchase_year,
    order_purchase_month,
    TO_CHAR(order_purchase_date, 'YYYY-MM')             as year_month,
    count(distinct order_id)                            as total_orders,
    count(*)                                            as total_order_items,
    sum(total_item_value)                               as total_revenue,
    avg(total_item_value)                               as avg_order_item_value,
    avg(review_score)                                   as avg_review_score,
    avg(delivery_days)                                  as avg_delivery_days,
    SUM(CASE WHEN is_on_time THEN 1 ELSE 0 END)         as on_time_deliveries,
    CASE
        WHEN count(distinct order_id) = 0 THEN NULL
        ELSE SUM(CASE WHEN is_on_time THEN 1 ELSE 0 END)::float
             / count(distinct order_id)
    END                                                 as on_time_rate

from {{ ref('fct_orders') }}
group by order_purchase_year, order_purchase_month, year_month
order by order_purchase_year, order_purchase_month
