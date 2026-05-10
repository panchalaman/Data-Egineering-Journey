variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for the data lake (must be globally unique)"
  type        = string
}

variable "pg_db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "olist"
}

variable "pg_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "adminuser"
}

variable "pg_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "raw_schema" {
  description = "PostgreSQL schema for raw Spark output"
  type        = string
  default     = "olist_raw"
}

variable "prod_schema" {
  description = "PostgreSQL schema for dbt production models"
  type        = string
  default     = "olist_prod"
}
