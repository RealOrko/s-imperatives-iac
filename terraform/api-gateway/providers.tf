provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.prefix
      ManagedBy   = "Terraform"
    }
  }
}