-- agg_delivery_performance.sql
-- Delivery performance by customer state: on-time rate, average delivery days.

{{ config(materialized='table') }}

select
    customer_state,
    count(distinct order_id)                            as total_orders,
    avg(delivery_days)                                  as avg_delivery_days,
    avg(estimated_delivery_days)                        as avg_estimated_delivery_days,
    avg(delivery_days - estimated_delivery_days)        as avg_delay_days,
    SUM(CASE WHEN is_on_time THEN 1 ELSE 0 END)         as on_time_deliveries,
    CASE
        WHEN count(distinct order_id) = 0 THEN NULL
        ELSE SUM(CASE WHEN is_on_time THEN 1 ELSE 0 END)::float
             / count(distinct order_id)
    END                                                 as on_time_rate,
    avg(review_score)                                   as avg_review_score

from {{ ref('fct_orders') }}
where customer_state is not null
  and delivery_days is not null
group by customer_state
order by total_orders desc
