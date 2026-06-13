USE ROLE accountadmin;
USE DATABASE staging_tasty_bytes;
USE SCHEMA public;

-- Create an email integration 

TYPE = 
ENABLED = TRUE
ALLOWED_RECIPIENTS = ('ADD EMAIL ADDRESS');  -- Update the recipient's email here

CREATE OR REPLACE PROCEDURE
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'notify_data_quality_team'
AS 
$$
import snowflake.snowpark.functions as F
from snowflake.snowpark import Session
from datetime import datetime

def notify_data_quality_team(session: Session) -> str:
    # Query the records with NULL values
    records = session.table("STAGING_TASTY_BYTES.RAW_POS.ORDER_HEADER") \
                            .filter((F.col("ORDER_AMOUNT").is_null()) | (F.col("ORDER_TOTAL").is_null())) \
                            .filter("ORDER_TS > DATEADD(hour, -6, CURRENT_TIMESTAMP())") \
                            .select(
                                F.col("ORDER_ID"),
                                F.col("TRUCK_ID"),
                                F.col("LOCATION_ID"),
                                F.col("ORDER_TS"),
                                F.col("ORDER_AMOUNT"),
                                F.col("ORDER_TOTAL")
                            )
    
    # Get a count of the problematic records
    record_count = records.count()
    
    if record_count == 0:
        return "No data quality issues found"

    # Convert the DataFrame to pandas for HTML formatting
    records_pd = records.to_pandas()
    
    # Convert the DataFrame to an HTML table with styling
    html_table = records_pd.to_html(index=False, classes='styled-table', na_rep='NULL')

    # Define the email content
    email_content = f"""
    <html>
    <head>
        <style>
            body {{
                font-family: Arial, sans-serif;
            }}
            h2 {{
                color: #FF4500;
            }}
            .alert-box {{
                background-color: #FFF0F0;
                border-left: 5px solid #FF4500;
                padding: 10px 15px;
                margin-bottom: 20px;
            }}
            .styled-table {{
                border-collapse: collapse;
                margin: 25px 0;
                font-size: 0.9em;
                font-family: 'Trebuchet MS', 'Lucida Sans Unicode', 'Lucida Grande', 'Lucida Sans', Arial, sans-serif;
                min-width: 400px;
                border-radius: 5px 5px 0 0;
                overflow: hidden;
                box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
            }}
            .styled-table thead tr {{
                background-color: #FF4500;
                color: #ffffff;
                text-align: left;
                font-weight: bold;
            }}
            .styled-table th,
            .styled-table td {{
                padding: 12px 15px;
            }}
            .styled-table tbody tr {{
                border-bottom: 1px solid #dddddd;
            }}
            .styled-table tbody tr:nth-of-type(even) {{
                background-color: #f3f3f3;
            }}
            .null-value {{
                color: #FF4500;
                font-weight: bold;
            }}
            .styled-table tbody tr:last-of-type {{
                border-bottom: 2px solid #FF4500;
            }}
        </style>
    </head>
    <body>
        <h2>⚠️ NULL values detected: ORDER_AMOUNT, ORDER_TOTAL </h2>
        <div class="alert-box">
            <p><strong>Alert Time:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
            <p><strong>Issue:</strong> {record_count} order(s) found with missing ORDER_AMOUNT or ORDER_TOTAL values in the past 6 hours</p>
        </div>
        <p>The following orders have NULL values that require attention:</p>
        {html_table}
        <p><i>Please investigate these records and update the missing values as soon as possible. NULL financial values can impact revenue reporting and analytics.</i></p>
    </body>
    </html>
    """
    
    # Send the email:
    session.call("",
                 "",
                 "ADD EMAIL ADDRESS",
                 f"ALERT: {record_count} orders with NULL values detected",
                 email_content,
                 "text/html")
    
    # Return a success message with the count of problematic records
    return f"Data quality alert sent successfully. {record_count} records reported."
$$;

-- Run the alert:

-- Check alert status
SHOW ALERTS LIKE 'order_data_quality_alert';

-- Start the alert
ALTER ALERT order_data_quality_alert RESUME;

-- Execute the alert, go check your email
EXECUTE ALERT order_data_quality_alert;

-- Suspend the alert after confirming email receipt
ALTER ALERT order_data_quality_alert SUSPEND;

-- Drop the alert
DROP ALERT order_data_quality_alert;