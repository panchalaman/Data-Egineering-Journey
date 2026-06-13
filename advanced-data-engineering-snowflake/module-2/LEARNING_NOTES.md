# Module 2 Reflections: Logging, Alerts, & Notifications

You know that saying, 'If a data pipeline breaks and no one is notified, does it make a sound?' Well, this module was all about fixing exactly that problem.

### What I actually did:
- I implemented **Snowflake Alerts** to automatically monitor anomalous conditions, like failing tasks or weird data spikes.
- I set up **Notification Integrations** (`notification.sql`) so that when an alert triggers, an actual email or webhook gets fired off.
- I wrote proper **Stored Procedures** (`sproc.sql`) to handle complex logging and execution tracing. Now, instead of flying blind, I have full observability into pipeline health.