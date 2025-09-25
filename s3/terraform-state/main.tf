terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  # AWS credentials and region will be read from environment variables:
  # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION
  skip_credentials_validation = false
  skip_metadata_api_check     = false
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = ">= 3.0.0"

  bucket = var.bucket_name
  force_destroy = var.force_destroy
  
  versioning = {
    enabled = var.versioning_enabled
  }
  
  # Block public access for security (appropriate for terraform state bucket)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  tags = var.tags
}
