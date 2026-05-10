-- stg_orders.sql
-- Staging model: cleaned and typed Olist orders from the PostgreSQL raw layer.
-- Grain: one row per order item (matches orders_enriched table from Spark).

{{ config(materialized='view') }}

with source as (

    select * from {{ source('olist_raw', 'orders_enriched') }}

),

cleaned as (

    select
        cast(order_id                       as varchar)          as order_id,
        cast(order_item_id                  as integer)          as order_item_id,
        cast(order_status                   as varchar)          as order_status,
        cast(order_purchase_timestamp       as timestamp)        as order_purchase_timestamp,
        cast(order_purchase_date            as date)             as order_purchase_date,
        cast(order_purchase_year            as integer)          as order_purchase_year,
        cast(order_purchase_month           as integer)          as order_purchase_month,
        cast(order_delivered_customer_date  as timestamp)        as order_delivered_customer_date,
        cast(order_estimated_delivery_date  as timestamp)        as order_estimated_delivery_date,
        cast(delivery_days                  as double precision) as delivery_days,
        cast(estimated_delivery_days        as double precision) as estimated_delivery_days,
        cast(is_on_time                     as boolean)          as is_on_time,
        cast(customer_id                    as varchar)          as customer_id,
        cast(customer_unique_id             as varchar)          as customer_unique_id,
        cast(customer_city                  as varchar)          as customer_city,
        cast(customer_state                 as varchar)          as customer_state,
        cast(product_id                     as varchar)          as product_id,
        cast(product_category_name          as varchar)          as product_category_name,
        cast(product_category_name_english  as varchar)          as product_category_name_english,
        cast(seller_id                      as varchar)          as seller_id,
        cast(seller_city                    as varchar)          as seller_city,
        cast(seller_state                   as varchar)          as seller_state,
        cast(price                          as double precision) as price,
        cast(freight_value                  as double precision) as freight_value,
        cast(total_item_value               as double precision) as total_item_value,
        cast(payment_type                   as varchar)          as payment_type,
        cast(payment_value                  as double precision) as payment_value,
        cast(review_score                   as double precision) as review_score

    from source

)

select * from cleaned
