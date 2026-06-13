USE ROLE accountadmin;
USE DATABASE staging_tasty_bytes;
USE SCHEMA raw_pos;

-- Configure logging level:

-- Create the stored procedure, define its logic with Snowpark for Python, write sales to raw_pos.daily_sales_hamburg_t
CREATE OR REPLACE PROCEDURE staging_tasty_bytes.raw_pos.process_order_headers_stream()
  RETURNS STRING
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.10'
  HANDLER ='process_order_headers_stream'
  PACKAGES = ('snowflake-snowpark-python')
AS
$$
import snowflake.snowpark.functions as F
from snowflake.snowpark import Session
import logging

def process_order_headers_stream(session: Session) -> float:
    logger = logging.getLogger('order_headers_stream_sproc')
    
    # Log procedure start:
    
    
    try:
        # Query the stream
        logger.info("Querying order_header_stream for new records")
        recent_orders = session.table("order_header_stream").filter(F.col("METADATA$ACTION") == "INSERT")
        
        # Look up location of the orders in the stream using the LOCATIONS table
        logger.info("Filtering orders for Hamburg, Germany")
        locations = session.table("location")
        hamburg_orders = recent_orders.join(
            locations,
            recent_orders["LOCATION_ID"] == locations["LOCATION_ID"]
        ).filter(
            (locations["CITY"] == "Hamburg") &
            (locations["COUNTRY"] == "Germany")
        )
        
        # Log the count of filtered records:
        hamburg_count = hamburg_orders.count()
        
        
        '''
        # Calculate the sum of sales in Hamburg
        logger.info("Calculating daily sales aggregates")
        total_sales = hamburg_orders.group_by(F.date_trunc('DAY', F.col("ORDER_TS"))).agg(
            F.coalesce(F.sum("ORDER_TOTAL"), F.lit(0)).alias("total_sales")
        )
        
        # Select the columns with proper aliases and convert to date type
        daily_sales = total_sales.select(
            F.date_trunc('DAY', F.col("ORDER_TS")).cast("DATE").alias("DATE"),
            F.col("total_sales")
        )
        
        # Write the results to the DAILY_SALES_HAMBURG_T table
        logger.info("Writing results to raw_pos.daily_sales_hamburg_t")
        daily_sales.write.mode("append").save_as_table("raw_pos.daily_sales_hamburg_t")
        '''
        # Log successful completion:
        
        return "Daily sales for Hamburg, Germany have been successfully written to raw_pos.daily_sales_hamburg_t"
    
    except Exception as e:
        # Log any errors that occur
        logger.error(f"Error processing orders: {str(e)}")
        raise
$$;

CALL staging_tasty_bytes.raw_pos.process_order_headers_stream();

USE DATABASE staging_tasty_bytes;
USE SCHEMA TELEMETRY;
SELECT * FROM pipeline_events;

-- Insert dummy data into ORDER_HEADER table
INSERT INTO STAGING_TASTY_BYTES.RAW_POS.ORDER_HEADER (
    ORDER_ID,
    TRUCK_ID,
    LOCATION_ID,
    CUSTOMER_ID,
    DISCOUNT_ID,
    SHIFT_ID,
    SHIFT_START_TIME,
    SHIFT_END_TIME,
    ORDER_CHANNEL,
    ORDER_TS,
    SERVED_TS,
    ORDER_CURRENCY,
    ORDER_AMOUNT,
    ORDER_TAX_AMOUNT,
    ORDER_DISCOUNT_AMOUNT,
    ORDER_TOTAL
) VALUES 
-- Hamburg Order 1
(1001, 42, 137, 5001, NULL, 301, '08:00:00', '16:00:00', 'POS', 
 CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'EUR', 25.50, '3.83', '0.00', 29.33),

-- Hamburg Order 2
(1002, 42, 137, 5002, 'SUMMER10', 301, '08:00:00', '16:00:00', 'MOBILE', 
 DATEADD(hour, -1, CURRENT_TIMESTAMP()), DATEADD(minute, -45, CURRENT_TIMESTAMP()), 'EUR', 42.75, '6.41', '4.28', 44.88),

-- Hamburg Order 3
(1003, 43, 137, 5003, NULL, 302, '10:00:00', '18:00:00', 'POS', 
 DATEADD(hour, -3, CURRENT_TIMESTAMP()), DATEADD(hour, -3, CURRENT_TIMESTAMP()), 'EUR', 18.20, '2.73', '0.00', 20.93);
 
CALL staging_tasty_bytes.raw_pos.process_order_headers_stream();

SELECT * FROM pipeline_events;

SELECT * FROM pipeline_events WHERE record_type = 'LOG';
