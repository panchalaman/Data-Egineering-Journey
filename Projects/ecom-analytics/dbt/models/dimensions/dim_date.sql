-- dim_date.sql
-- Calendar dimension derived from order purchase dates.

{{ config(materialized='table') }}

with date_spine as (

    select distinct order_purchase_date as date_key
    from {{ ref('stg_orders') }}
    where order_purchase_date is not null

)

select
    date_key,
    extract(year  from date_key)::int          as year,
    extract(month from date_key)::int          as month,
    extract(day   from date_key)::int          as day,
    extract(dow   from date_key)::int          as day_of_week,
    TO_CHAR(date_key, 'Day')                   as day_name,
    TO_CHAR(date_key, 'Month')                 as month_name,
    TO_CHAR(date_key, 'YYYY-MM')               as year_month,
    case
        when extract(dow from date_key) in (0, 6) then true
        else false
    end                                        as is_weekend

from date_spine
order by date_key
