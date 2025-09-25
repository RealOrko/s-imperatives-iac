# Terraform Root Module for S3 Bucket (Terraform State)

This module deploys an S3 bucket for storing Terraform state using the [terraform-aws-modules/s3-bucket/aws](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket) module.

## Usage

1. Ensure your AWS credentials are set in your environment:

```
export AWS_ACCESS_KEY_ID=your-access-key-id
export AWS_SECRET_ACCESS_KEY=your-secret-access-key
export AWS_DEFAULT_REGION=us-east-1
```

2. Initialize and apply the module:

```
cd s3/terraform-state
terraform init
terraform apply
```

## Variables
- `bucket_name`: Name of the S3 bucket (default: `si-iac-terraform-state-store`)
- `force_destroy`: Force destroy bucket (default: `false`)
- `versioning_enabled`: Enable versioning (default: `true`)
- `tags`: Tags to apply (default: see `variables.tf`)

Note: AWS credentials and region are read directly from environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`).

## Outputs
- `bucket_id`: Name of the bucket
- `bucket_arn`: ARN of the bucket
- `bucket_domain_name`: Domain name of the bucket
