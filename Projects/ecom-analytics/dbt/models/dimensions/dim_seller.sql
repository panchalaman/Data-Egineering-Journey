-- dim_seller.sql
-- Seller dimension with geographic and sales statistics.

{{ config(materialized='table') }}

select
    seller_id,
    seller_state,
    seller_city,
    count(distinct order_id) as total_orders,
    count(*)                 as total_order_items,
    sum(price)               as total_revenue,
    avg(price)               as avg_item_price,
    avg(review_score)        as avg_review_score,
    avg(delivery_days)       as avg_delivery_days

from {{ ref('stg_orders') }}
where seller_id is not null

group by seller_id, seller_state, seller_city
order by total_revenue desc
