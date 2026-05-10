-- dim_customer.sql
-- Customer dimension with geographic and purchase statistics by state and city.

{{ config(materialized='table') }}

select
    customer_state,
    customer_city,
    count(distinct customer_unique_id) as unique_customers,
    count(distinct order_id)           as total_orders,
    sum(total_item_value)              as total_revenue,
    avg(total_item_value)              as avg_order_item_value,
    avg(review_score)                  as avg_review_score,
    avg(delivery_days)                 as avg_delivery_days

from {{ ref('stg_orders') }}
where customer_state is not null

group by customer_state, customer_city
order by total_orders desc
