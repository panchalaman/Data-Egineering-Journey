-- dim_product.sql
-- Product category dimension with order volume, revenue, and review statistics.

{{ config(materialized='table') }}

select
    coalesce(product_category_name_english, 'unknown') as product_category_name_english,
    product_category_name,
    count(distinct order_id)   as total_orders,
    count(*)                   as total_order_items,
    sum(price)                 as total_revenue,
    avg(price)                 as avg_item_price,
    avg(review_score)          as avg_review_score

from {{ ref('stg_orders') }}
where product_category_name_english is not null

group by product_category_name_english, product_category_name
order by total_revenue desc
