-- fct_orders.sql
-- Order item fact table — one row per order item with surrogate key.
-- Indexes on order_purchase_date (time-range queries) and customer_state
-- (geography filters) — the PostgreSQL equivalents of partitioning and clustering.

{{ config(
    materialized='table',
    indexes=[
        {'columns': ['order_purchase_date'], 'type': 'btree'},
        {'columns': ['customer_state'],      'type': 'btree'},
        {'columns': ['product_category_name_english'], 'type': 'btree'}
    ]
) }}

with orders as (
    select
        *,
        row_number() over (
            partition by order_id, order_item_id
            order by order_purchase_timestamp
        ) as _dedup_rn
    from {{ ref('stg_orders') }}
    where order_purchase_date is not null
)

select
    {{ dbt_utils.generate_surrogate_key(['order_id', 'order_item_id']) }} as order_item_key,
    order_id,
    order_item_id,
    order_status,
    order_purchase_timestamp,
    order_purchase_date,
    order_purchase_year,
    order_purchase_month,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    delivery_days,
    estimated_delivery_days,
    is_on_time,
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    product_id,
    product_category_name,
    product_category_name_english,
    seller_id,
    seller_city,
    seller_state,
    price,
    freight_value,
    total_item_value,
    payment_type,
    payment_value,
    review_score

from orders
where _dedup_rn = 1
