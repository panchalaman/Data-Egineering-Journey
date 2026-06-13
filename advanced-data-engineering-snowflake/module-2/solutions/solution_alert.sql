USE ROLE accountadmin;
USE DATABASE staging_tasty_bytes;
USE SCHEMA public;

CREATE TABLE staging_tasty_bytes.telemetry.data_quality_alerts (
  alert_time TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  alert_name VARCHAR,
  severity VARCHAR,
  message VARCHAR,
  record_count INTEGER
);

-- Create a serverless alert with a schedule
CREATE OR REPLACE ALERT order_data_quality_alert
  SCHEDULE = '30 MINUTE'
  IF (EXISTS (
    SELECT * FROM STAGING_TASTY_BYTES.RAW_POS.ORDER_HEADER 
    WHERE (ORDER_AMOUNT IS NULL OR ORDER_TOTAL IS NULL) 
    AND ORDER_TS > DATEADD(hour, -6, CURRENT_TIMESTAMP())
  ))
  THEN 
    BEGIN
      -- Insert a record into the table
      INSERT INTO staging_tasty_bytes.telemetry.data_quality_alerts
      (alert_name, severity, message, record_count)
      SELECT 
        'ORDER_HEADER_NULL_VALUES', 
        'ERROR', 
        'Data quality issue detected: missing amount or total values', 
        COUNT(*)
      FROM STAGING_TASTY_BYTES.RAW_POS.ORDER_HEADER 
      WHERE (ORDER_AMOUNT IS NULL OR ORDER_TOTAL IS NULL) 
      AND ORDER_TS > DATEADD(hour, -6, CURRENT_TIMESTAMP());
        
      -- Call stored procedure for notification
      -- CALL notify_data_quality_team();
    END;

-- Check alert status
SHOW ALERTS LIKE 'order_data_quality_alert';

-- Start the alert
ALTER ALERT order_data_quality_alert RESUME;

-- Execute the alert
EXECUTE ALERT order_data_quality_alert;

-- Insert dummy data with missing ORDER_AMOUNT or ORDER_TOTAL
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
    ORDER_AMOUNT,  -- Missing value (NULL)
    ORDER_TAX_AMOUNT,
    ORDER_DISCOUNT_AMOUNT,
    ORDER_TOTAL
) VALUES 
-- Record with missing ORDER_AMOUNT
(2001, 55, 142, 6001, NULL, 401, '09:00:00', '17:00:00', 'POS', 
 CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'USD', NULL, '2.50', '0.00', 30.45),

-- Record with missing ORDER_TOTAL
(2002, 55, 142, 6002, 'PROMO25', 401, '09:00:00', '17:00:00', 'MOBILE', 
 CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'USD', 24.95, '2.25', '6.24', NULL),

-- Record with both ORDER_AMOUNT and ORDER_TOTAL missing
(2003, 56, 143, 6003, NULL, 402, '10:00:00', '18:00:00', 'WEB', 
 CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'USD', NULL, '1.88', '0.00', NULL);

-- Check for alerts in data_quality_alerts table
USE DATABASE staging_tasty_bytes;
USE SCHEMA TELEMETRY;
SELECT * FROM data_quality_alerts;

-- Suspend the alert
ALTER ALERT order_data_quality_alert SUSPEND;