-- agg_category_performance.sql
-- Product category performance: revenue, order count, and review scores.
-- SECONDARY DASHBOARD TILE: horizontal bar chart of top categories by revenue.

{{ config(materialized='table') }}

select
    coalesce(product_category_name_english, 'unknown')  as product_category_name_english,
    count(distinct order_id)                            as total_orders,
    count(*)                                            as total_order_items,
    sum(total_item_value)                               as total_revenue,
    avg(total_item_value)                               as avg_order_item_value,
    avg(review_score)                                   as avg_review_score,
    avg(delivery_days)                                  as avg_delivery_days,
    CASE
        WHEN count(distinct order_id) = 0 THEN NULL
        ELSE SUM(CASE WHEN is_on_time THEN 1 ELSE 0 END)::float
             / count(distinct order_id)
    END                                                 as on_time_rate

from {{ ref('fct_orders') }}
where product_category_name_english is not null
group by product_category_name_english
order by total_revenue desc
