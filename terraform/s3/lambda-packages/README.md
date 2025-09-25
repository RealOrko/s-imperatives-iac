# Lambda Packages S3 Bucket

This Terraform configuration creates an S3 bucket for storing Lambda package artifacts with IAM-based access control.

## Features

- **S3 Bucket**: Secure bucket for Lambda packages with versioning enabled
- **IAM Groups**: Automatic creation of developer and devops access groups
- **Access Policies**: Role-based access control with different permission levels
  - **Developer Group**: Read-only access (list, get objects)
  - **DevOps Group**: Full read/write access (list, get, put, delete objects)

## Backend Configuration

This configuration uses S3 for remote state storage with the following settings:
- **Bucket**: `si-iac-terraform-state-store`
- **Key**: `dev/lambda-packages/terraform.tfstate`
- **Region**: `eu-west-2`

## Prerequisites

1. Ensure the Terraform state S3 bucket exists
2. Configure AWS credentials via environment variables or AWS CLI
3. Update the region in the backend configuration if needed

## Usage

### Initialize the Backend

After configuring the backend, run:

```bash
terraform init -backend-config="envs/${ENVIRONMENT}.hcl"
```

If you're migrating from local state, Terraform will ask if you want to copy the existing state to the new backend.

### Plan and Apply

```bash
terraform plan
terraform apply
```

## Configuration

The following variables can be customized:

- `region`: AWS region (default: `eu-west-2`)
- `environment`: Environment name (default: `dev`)
- `prefix`: Resource prefix (default: `si-iac`)
- `bucket_name`: S3 bucket name suffix (default: `lambda-packages`)
- `force_destroy`: Allow destroying bucket with objects (default: `false`)
- `versioning_enabled`: Enable bucket versioning (default: `true`)
- `create_access_groups`: Create IAM groups for access control (default: `true`)
- `tags`: Resource tags

### Example Usage with Custom Variables

```hcl
module "lambda_packages" {
  source = "./terraform/s3/lambda-packages"
  
  environment           = "prod"
  create_access_groups  = true
  force_destroy        = false
  
  tags = {
    Environment = "production"
    Team       = "platform"
    Project    = "lambda-deployment"
  }
}
```

## IAM Groups and Access Control

When `create_access_groups` is enabled (default), the module creates:

### Developer Group
- **Name**: `${prefix}-${environment}-${bucket_name}-developers`
- **Permissions**: Read-only access to S3 bucket
  - List bucket contents
  - Download objects and versions
  - Get bucket metadata

### DevOps Group
- **Name**: `${prefix}-${environment}-${bucket_name}-devops`
- **Permissions**: Full read/write access to S3 bucket
  - All developer permissions
  - Upload new objects
  - Delete objects and versions

### Adding Users to Groups

After applying the configuration, add users to the appropriate groups:

```bash
# Add user to developer group
aws iam add-user-to-group \
  --group-name si-iac-dev-lambda-packages-developers \
  --user-name developer-username

# Add user to devops group
aws iam add-user-to-group \
  --group-name si-iac-dev-lambda-packages-devops \
  --user-name devops-username
```

## Outputs

The module provides the following outputs:

- `bucket_id`: S3 bucket name
- `bucket_arn`: S3 bucket ARN
- `bucket_domain_name`: S3 bucket domain name
- `developer_group_name`: Developer IAM group name
- `developer_group_arn`: Developer IAM group ARN
- `devops_group_name`: DevOps IAM group name
- `devops_group_arn`: DevOps IAM group ARN
- `developer_policy_arn`: Developer IAM policy ARN
- `devops_policy_arn`: DevOps IAM policy ARN

## Security

The bucket is configured with:
- Block all public access settings
- Versioning enabled
- Object ownership controls
- IAM-based access control with principle of least privilege
- Server-side encryption enabled for state files
