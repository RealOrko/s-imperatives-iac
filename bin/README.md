# Automation Scripts

This directory contains shell scripts for automated deployment and management of the S-Imperatives Infrastructure as Code project. These scripts orchestrate the deployment of multiple Terraform modules in the correct order to ensure proper dependency management.

## Prerequisites

Before running these scripts, ensure you have:

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- Node.js >= 18.x installed
- A `.env` file configured in the project root
- Bash shell environment

## Environment Configuration

All scripts read environment variables from a `.env` file in the project root. Required variables:

```bash
AWS_REGION=us-east-1
ENVIRONMENT=dev
S3_BUCKET_NAME=your-s3-bucket-name
# Add other environment-specific variables
```

## Scripts Overview

### Main Orchestration Scripts

#### `all-create.sh`
**Purpose**: Complete infrastructure deployment in correct dependency order

**Usage**:
```bash
./bin/all-create.sh
```

**Deployment Order**:
1. IAM roles and policies
2. S3 bucket for Lambda packages
3. Lambda authorizer function
4. Lambda S3 files function
5. API Gateway with integrations

**What it does**:
- Sources environment variables from `.env`
- Executes each component deployment script in sequence
- Ensures dependencies are met before deploying dependent resources
- Exits on any error (set -euo pipefail)

#### `all-destroy.sh`
**Purpose**: Complete infrastructure destruction in reverse dependency order

**Usage**:
```bash
./bin/all-destroy.sh
```

**Destruction Order**:
1. API Gateway (removes API endpoints)
2. Lambda S3 files function
3. Lambda authorizer function
4. IAM roles and policies
5. S3 Lambda packages bucket

**What it does**:
- Destroys resources in reverse order to avoid dependency conflicts
- Calls each component script with "destroy" parameter
- Removes all AWS resources created by this project

### Component Deployment Scripts

#### `iam.sh`
**Purpose**: Deploy or destroy IAM roles and policies

**Usage**:
```bash
./bin/iam.sh [destroy]
```

**Operations**:
- Formats Terraform files
- Initializes Terraform with backend configuration
- Plans and applies IAM resources
- Creates roles for Lambda functions and user groups

**Resources Created**:
- Lambda execution roles (authorizer, s3-files)
- IAM groups (developer, devops)
- S3 access policies
- Trust relationships

#### `s3-lambda-packages.sh`
**Purpose**: Deploy or destroy S3 bucket for Lambda deployment packages

**Usage**:
```bash
./bin/s3-lambda-packages.sh [destroy]
```

**Operations**:
- Creates S3 bucket for storing Lambda ZIP files
- Configures bucket policies and versioning
- Sets up lifecycle management

#### `lambda-authoriser.sh`
**Purpose**: Deploy or destroy the API Gateway authorizer Lambda function

**Usage**:
```bash
./bin/lambda-authoriser.sh [destroy]
```

**Operations**:
- Packages Node.js authorizer code
- Uploads ZIP file to S3
- Deploys Lambda function with proper IAM role
- Configures function settings and environment variables

**Dependencies**:
- IAM roles (from `iam.sh`)
- S3 Lambda packages bucket (from `s3-lambda-packages.sh`)

#### `lambda-s3-files.sh`
**Purpose**: Deploy or destroy the S3 file operations Lambda function

**Usage**:
```bash
./bin/lambda-s3-files.sh [destroy]
```

**Operations**:
- Packages Node.js S3 files code
- Uploads ZIP file to S3  
- Deploys Lambda function with S3 permissions
- Configures environment variables for S3 operations

**Dependencies**:
- IAM roles (from `iam.sh`)
- S3 Lambda packages bucket (from `s3-lambda-packages.sh`)

#### `api-gateway.sh`
**Purpose**: Deploy or destroy HTTP API Gateway with Lambda integrations

**Usage**:
```bash
./bin/api-gateway.sh [destroy]
```

**Operations**:
- Creates HTTP API Gateway
- Configures custom Lambda authorizer
- Sets up S3 files routes with proper integration
- Configures CORS and routing rules

**Dependencies**:
- Lambda authorizer function (from `lambda-authoriser.sh`)
- Lambda S3 files function (from `lambda-s3-files.sh`)

#### `s3-terraform-state.sh`
**Purpose**: Deploy or destroy S3 bucket for Terraform state management

**Usage**:
```bash
./bin/s3-terraform-state.sh [destroy]
```

**Operations**:
- Creates S3 bucket for Terraform remote state
- Configures versioning and encryption
- Sets up state locking with DynamoDB (if configured)

## Script Features

### Error Handling
- All scripts use `set -euo pipefail` for strict error handling
- Exit immediately on any command failure
- Fail on undefined variables
- Fail on pipe errors

### Environment Isolation
- Each script reads environment-specific configuration
- Terraform backend configuration uses environment-specific files
- Supports multiple deployment environments (dev, staging, prod)

### Terraform Best Practices
- Automatic `terraform fmt` formatting
- Conditional `terraform init` (only if needed)
- Always runs `terraform plan` before apply
- Auto-approval for scripted deployments

## Troubleshooting

### Common Issues

1. **Permission Errors**:
   - Verify AWS credentials are configured correctly
   - Check IAM permissions for Terraform operations
   - Ensure scripts have execute permissions: `chmod +x bin/*.sh`

2. **Dependency Errors**:
   - Run `all-create.sh` instead of individual scripts
   - Check that `.env` file is properly configured
   - Verify all prerequisites are installed

3. **Terraform State Issues**:
   - Ensure S3 backend is configured correctly
   - Check that Terraform state bucket exists
   - Verify environment-specific backend configuration files

4. **Environment Variable Issues**:
   - Verify `.env` file exists and contains required variables
   - Check that variables are exported correctly
   - Ensure no spaces around `=` in variable assignments

### Debug Mode
Add `set -x` to any script to enable verbose output for debugging:

```bash
#!/bin/bash
set -euo pipefail
set -x  # Enable debug mode
```

## Security Considerations

- Scripts should only be run in secure environments
- Ensure `.env` files are not committed to version control
- Use least-privilege IAM policies
- Regularly rotate AWS credentials
- Monitor CloudTrail for API calls

## Maintenance

- Keep Terraform version requirements updated
- Regularly review and update IAM policies
- Monitor AWS service limits and quotas
- Update Node.js runtime versions for Lambda functions

---

For more information about specific components, see the README files in their respective directories.