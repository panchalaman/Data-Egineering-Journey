terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {}
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------
# S3 Bucket — Data Lake
# ---------------------------------------------------------------
resource "aws_s3_bucket" "data_lake" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  rule {
    id     = "expire-old-objects"
    status = "Enabled"
    filter {}
    expiration {
      days = 90
    }
  }
}

# ---------------------------------------------------------------
# IAM Role — used by load script to access S3
# ---------------------------------------------------------------
resource "aws_iam_role" "rds_s3_role" {
  name = "olist-rds-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_s3" {
  role       = aws_iam_role.rds_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# ---------------------------------------------------------------
# Security Group — allow port 5432 for RDS PostgreSQL
# ---------------------------------------------------------------
resource "aws_security_group" "rds_sg" {
  name        = "olist-rds-sg"
  description = "Allow PostgreSQL access on port 5432"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "PostgreSQL access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------
# RDS PostgreSQL — db.t3.micro (free tier eligible)
# ---------------------------------------------------------------
resource "aws_db_instance" "olist" {
  identifier             = "olist-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.pg_db_name
  username               = var.pg_admin_username
  password               = var.pg_admin_password
  publicly_accessible    = true
  skip_final_snapshot    = true
  deletion_protection    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
