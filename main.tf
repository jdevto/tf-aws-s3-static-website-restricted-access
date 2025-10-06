provider "aws" {
  region = "ap-southeast-2"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Get current user's public IP
data "http" "my_public_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  allowed_cidr = [
    "${trimspace(data.http.my_public_ip.response_body)}/32",
    "136.158.118.151/32"
  ]
}

# S3 bucket for static website hosting
resource "aws_s3_bucket" "website" {
  bucket = "static-website-${random_string.suffix.result}"

  tags = {
    Name        = "Static Website Bucket"
    Environment = "demo"
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Bucket policy to allow access only from specific IP
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowIPAccess"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = local.allowed_cidr
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# Upload sample index.html file
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  content      = file("${path.module}/index.html")
  content_type = "text/html"
}

# Upload sample error.html file
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.website.id
  key          = "error.html"
  content      = file("${path.module}/error.html")
  content_type = "text/html"
}

# Output the website URL
output "website_url" {
  description = "URL of the website"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

# Output the bucket name
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.bucket
}
