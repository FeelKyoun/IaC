terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}


# Create S3 Bucket
resource "aws_s3_bucket" "test_project" {
  bucket = "secure-project"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Provides a resource to manage S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.test_project.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Provides an S3 bucket ACL resource
resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]
  bucket = resource.aws_s3_bucket.test_project.id
  acl    = "private"
}