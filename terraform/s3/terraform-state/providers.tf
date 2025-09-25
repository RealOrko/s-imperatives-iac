provider "aws" {
  # AWS credentials and region will be read from environment variables:
  # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION
  skip_credentials_validation = false
  skip_metadata_api_check     = false
}

