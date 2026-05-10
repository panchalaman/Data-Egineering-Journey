FROM apache/airflow:2.9.1

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

USER airflow
RUN pip install --no-cache-dir \
    boto3>=1.34.0 \
    psycopg2-binary>=2.9.0 \
    pyspark>=3.5.0 \
    pyarrow>=14.0.0 \
    pandas>=2.0.0 \
    python-dotenv>=1.0.0 \
    requests>=2.31.0 \
    dbt-postgres>=1.8.0
