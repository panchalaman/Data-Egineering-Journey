-- Create the stored procedure, define its logic with Snowpark for Python, write sales to raw_pos.daily_sales_hamburg_t
CREATE OR REPLACE PROCEDURE {{env}}_tasty_bytes.raw_pos.process_order_headers_stream()
  RETURNS STRING
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.10'
  HANDLER ='process_order_headers_stream'
  PACKAGES = ('snowflake-snowpark-python')
AS
$$
import snowflake.snowpark.functions as F
from snowflake.snowpark import Session

def process_order_headers_stream(session: Session) -> float:
    # Query the stream
    recent_orders = session.table("order_header_stream").filter(F.col("METADATA$ACTION") == "INSERT")
    
    # Look up location of the orders in the stream using the LOCATIONS table
    locations = session.table("location")
    hamburg_orders = recent_orders.join(
        locations,
        recent_orders["LOCATION_ID"] == locations["LOCATION_ID"]
    ).filter(
        (locations["CITY"] == "Hamburg") &
        (locations["COUNTRY"] == "Germany")
    )
    
    # Calculate the sum of sales in Hamburg
    total_sales = hamburg_orders.group_by(F.date_trunc('DAY', F.col("ORDER_TS"))).agg(
        F.coalesce(F.sum("ORDER_TOTAL"), F.lit(0)).alias("total_sales")
    )
    
    # Select the columns with proper aliases and convert to date type
    daily_sales = total_sales.select(
        F.col("DATE_TRUNC('DAY', ORDER_TS)").cast("DATE").alias("DATE"),
        F.col("total_sales")
    )
    
    # Write the results to the DAILY_SALES_HAMBURG_T table
    total_sales.write.mode("append").save_as_table("raw_pos.daily_sales_hamburg_t")
    
    # Return a message indicating the operation was successful
    return "Daily sales for Hamburg, Germany have been successfully written to raw_pos.daily_sales_hamburg_t"
$$;
