# Module 3 Reflections: Snowpark, Dynamic Tables, & UDFs

This is where things got really modern and exciting. I moved past traditional batch processing into Snowflake's latest features.

### What I actually did:
- I built **Dynamic Tables** (`hamburg_sales_dynamic_table.sql`)! This was awesome because I could just write the declarative `SELECT` statement and define my target lag, and Snowflake handled the incremental refreshes automatically.
- I used **Snowpark** in a Jupyter Notebook (`hamburg_sales_snowpark.ipynb`) to do dataframe-style manipulations in Python—pushing all the heavy compute down into Snowflake instead of my laptop.
- I also created custom **UDFs** (User Defined Functions) and set up **Streams** and **Stored Procedures** to handle complex Change Data Capture (CDC) scenarios.