# Module 1 Reflections: API Integrations

In this module, I really got my hands dirty with Snowflake's ability to communicate outside its own ecosystem. 

### What I actually did:
- I set up an **API integration** directly inside Snowflake. This allowed me to pull in external data (specifically, live weather data for Hamburg) without needing a heavy middleware tool.
- I worked on parsing JSON responses using Snowflake's native `VARIANT` data type, which is super convenient for semi-structured data.
- It felt great to see live data flowing directly into the warehouse, ensuring my downstream models always have the freshest context.