"""
test_transform.py — Unit tests for the Olist PySpark transformation.

Tests that the transform function correctly joins all Olist CSV tables
and produces the expected output schema and row counts.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

import pytest

# Add spark/ to path so we can import transform_events
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "spark"))


@pytest.fixture(scope="session")
def spark():
    from pyspark.sql import SparkSession

    return (
        SparkSession.builder
        .master("local[1]")
        .appName("test-olist-transform")
        .config("spark.sql.parquet.enableVectorizedReader", "false")
        .getOrCreate()
    )


@pytest.fixture(scope="session")
def sample_data_dir(tmp_path_factory):
    """Create minimal sample CSV files matching the Olist schema."""
    d = tmp_path_factory.mktemp("raw")

    (d / "olist_orders_dataset.csv").write_text(
        "order_id,customer_id,order_status,order_purchase_timestamp,"
        "order_approved_at,order_delivered_carrier_date,"
        "order_delivered_customer_date,order_estimated_delivery_date\n"
        "order1,cust1,delivered,2017-10-02 10:56:33,2017-10-02 11:07:15,"
        "2017-10-04 19:55:00,2017-10-10 21:25:13,2017-10-18 00:00:00\n"
        "order2,cust2,delivered,2017-11-05 13:00:00,2017-11-05 14:00:00,"
        "2017-11-07 00:00:00,2017-11-15 12:00:00,2017-11-20 00:00:00\n"
    )

    (d / "olist_order_items_dataset.csv").write_text(
        "order_id,order_item_id,product_id,seller_id,shipping_limit_date,price,freight_value\n"
        "order1,1,prod1,seller1,2017-10-06 11:07:15,29.99,8.72\n"
        "order2,1,prod2,seller1,2017-11-10 14:00:00,59.90,13.29\n"
    )

    (d / "olist_products_dataset.csv").write_text(
        "product_id,product_category_name,product_name_lenght,product_description_lenght,"
        "product_photos_qty,product_weight_g,product_length_cm,product_height_cm,product_width_cm\n"
        "prod1,beleza_saude,40,287,1,225,16,10,14\n"
        "prod2,informatica_acessorios,32,400,2,800,30,15,20\n"
    )

    (d / "olist_customers_dataset.csv").write_text(
        "customer_id,customer_unique_id,customer_zip_code_prefix,customer_city,customer_state\n"
        "cust1,ucust1,14409,franca,SP\n"
        "cust2,ucust2,09790,sao-paulo,SP\n"
    )

    (d / "olist_sellers_dataset.csv").write_text(
        "seller_id,seller_zip_code_prefix,seller_city,seller_state\n"
        "seller1,14409,franca,SP\n"
    )

    (d / "olist_order_payments_dataset.csv").write_text(
        "order_id,payment_sequential,payment_type,payment_installments,payment_value\n"
        "order1,1,credit_card,1,38.71\n"
        "order2,1,boleto,1,73.19\n"
    )

    (d / "olist_order_reviews_dataset.csv").write_text(
        "review_id,order_id,review_score,review_comment_title,review_comment_message,"
        "review_creation_date,review_answer_timestamp\n"
        "rev1,order1,5,,Muito bom!,2017-10-12 00:00:00,2017-10-13 00:00:00\n"
        "rev2,order2,4,,,2017-11-18 00:00:00,2017-11-19 00:00:00\n"
    )

    (d / "product_category_name_translation.csv").write_text(
        "product_category_name,product_category_name_english\n"
        "beleza_saude,health_beauty\n"
        "informatica_acessorios,computers_accessories\n"
    )

    return str(d)


def test_transform_row_count(spark, sample_data_dir, tmp_path):
    from transform_events import transform

    output_path = str(tmp_path / "output")
    transform(spark, sample_data_dir, output_path)

    result = spark.read.parquet(output_path)
    assert result.count() == 2, f"Expected 2 rows, got {result.count()}"


def test_transform_schema(spark, sample_data_dir, tmp_path):
    from transform_events import transform

    output_path = str(tmp_path / "output_schema")
    transform(spark, sample_data_dir, output_path)

    result = spark.read.parquet(output_path)
    column_names = set(result.columns)

    required_columns = {
        "order_id", "order_item_id", "order_status",
        "order_purchase_date", "order_purchase_year", "order_purchase_month",
        "customer_state", "product_category_name_english",
        "price", "freight_value", "total_item_value",
        "payment_type", "payment_value", "review_score",
        "delivery_days", "is_on_time",
    }
    missing = required_columns - column_names
    assert not missing, f"Missing columns in output: {missing}"


def test_transform_no_null_purchase_date(spark, sample_data_dir, tmp_path):
    from transform_events import transform

    output_path = str(tmp_path / "output_nulls")
    transform(spark, sample_data_dir, output_path)

    result = spark.read.parquet(output_path)
    null_count = result.filter(result.order_purchase_date.isNull()).count()
    assert null_count == 0, f"Found {null_count} rows with null order_purchase_date"


def test_transform_category_translation(spark, sample_data_dir, tmp_path):
    from transform_events import transform

    output_path = str(tmp_path / "output_cat")
    transform(spark, sample_data_dir, output_path)

    result = spark.read.parquet(output_path)
    categories = {row.product_category_name_english for row in result.select("product_category_name_english").collect()}
    assert "health_beauty" in categories
    assert "computers_accessories" in categories
