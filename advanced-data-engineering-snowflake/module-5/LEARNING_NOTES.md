# Module 5 Reflections: Task DAGs & Pipeline Orchestration

An enterprise data platform needs to run by itself. This module was focused on orchestration and tying everything together.

### What I actually did:
- I built a **Task DAG** (Directed Acyclic Graph) in Snowflake to connect multiple dependent tasks. If the parent task finishes successfully, the children trigger automatically. 
- I integrated automated email alerting directly into the task flow (`dag_email_integration.sql`) so stakeholders (and I) get notified immediately when the job is done.
- This proved to me that you can build highly robust, automated pipelining natively in Snowflake without necessarily relying on external tools like Airflow for every use case.