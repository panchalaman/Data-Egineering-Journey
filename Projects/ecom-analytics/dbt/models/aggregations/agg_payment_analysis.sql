-- agg_payment_analysis.sql
-- Payment method breakdown: volume, revenue, and average order value by payment type.

{{ config(materialized='table') }}

select
    payment_type,
    count(distinct order_id) as total_orders,
    count(*)                 as total_order_items,
    sum(payment_value)       as total_payment_value,
    avg(payment_value)       as avg_payment_value,
    avg(review_score)        as avg_review_score

from {{ ref('fct_orders') }}
where payment_type is not null
group by payment_type
order by total_payment_value desc
