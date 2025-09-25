# Lambda Packages S3 Bucket

This Terraform configuration creates an S3 bucket for storing Lambda package artifacts.

## Backend Configuration

This configuration uses S3 for remote state storage with the following settings:
- **Bucket**: `si-iac-terraform-state`
- **Key**: `lambda-packages/terraform.tfstate`
- **Region**: `us-east-1` (update as needed)

## Prerequisites

1. Ensure the S3 bucket `si-iac-terraform-state` exists
2. Configure AWS credentials via environment variables or AWS CLI
3. Update the region in the backend configuration if needed

## Usage

### Initialize the Backend

After configuring the backend, run:

```bash
terraform init
```

If you're migrating from local state, Terraform will ask if you want to copy the existing state to the new backend.

### Plan and Apply

```bash
terraform plan
terraform apply
```

## Configuration

The following variables can be customized:

- `bucket_name`: Name of the S3 bucket (default: `si-iac-lambda-packages`)
- `force_destroy`: Allow destroying bucket with objects (default: `false`)
- `versioning_enabled`: Enable bucket versioning (default: `true`)
- `tags`: Resource tags

## Security

The bucket is configured with:
- Block all public access settings
- Versioning enabled
- Server-side encryption enabled for state files