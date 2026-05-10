output "s3_data_lake_bucket" {
  description = "S3 data lake bucket name"
  value       = aws_s3_bucket.data_lake.bucket
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint (use as PG_HOST in .env)"
  value       = aws_db_instance.olist.address
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = 5432
}
