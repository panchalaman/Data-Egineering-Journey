CREATE OR REPLACE DYNAMIC TABLE {{env}}_tasty_bytes.raw_pos.daily_sales_hamburg
WAREHOUSE = 'COMPUTE_WH'
TARGET_LAG = '1 minute'
AS
SELECT
    CAST(oh.ORDER_TS AS DATE) AS date,
    COALESCE(SUM(oh.ORDER_TOTAL), 0) AS total_sales
FROM
    {{env}}_tasty_bytes.raw_pos.order_header oh
JOIN
    {{env}}_tasty_bytes.raw_pos.location loc
ON
    oh.LOCATION_ID = loc.LOCATION_ID
WHERE
    loc.CITY = 'Hamburg'
    AND loc.COUNTRY = 'Germany'
GROUP BY
    CAST(oh.ORDER_TS AS DATE);