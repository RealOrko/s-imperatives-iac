# S3 Storage Configuration

This directory contains Terraform modules for managing S3 storage resources in the S-Imperatives project. It includes configurations for Lambda deployment packages and Terraform state management.

> 📖 **Part of**: [S-Imperatives Infrastructure as Code](../../README.md)  
> 🚀 **Deployment**: [Automation Scripts](../../bin/README.md)

## Module Structure

This S3 configuration is organized into specialized sub-modules:

```
terraform/s3/
├── README.md                    # This overview documentation
├── lambda-packages/            # Lambda deployment package storage
│   ├── main.tf
│   ├── outputs.tf
│   ├── README.md              # Lambda packages bucket documentation
│   └── ...
└── terraform-state/          # Terraform state management
    ├── main.tf
    ├── outputs.tf  
    ├── README.md             # State management documentation
    └── ...
```

## Sub-Modules

### Lambda Packages Storage
**Path**: `lambda-packages/`  
**Purpose**: S3 bucket for storing Lambda function deployment packages (ZIP files)

**Key Features**:
- Versioning enabled for deployment rollbacks
- Lifecycle policies for cost optimization
- Secure bucket policies
- Integration with Lambda deployment automation

**Documentation**: [Lambda Packages README](lambda-packages/README.md)

### Terraform State Management  
**Path**: `terraform-state/`  
**Purpose**: S3 bucket for storing Terraform state files with remote backend configuration

**Key Features**:
- State locking with DynamoDB
- Encryption at rest
- Versioning for state history
- Cross-environment isolation

**Documentation**: [Terraform State README](terraform-state/README.md)

## Deployment Order

The S3 modules have specific deployment dependencies:

1. **Terraform State** (Optional): Deploy first if using remote state
2. **Lambda Packages**: Required before Lambda function deployments

## Quick Deployment

### Deploy Lambda Packages Bucket
```bash
cd terraform/s3/lambda-packages
terraform init -backend-config="envs/dev.hcl"
terraform plan
terraform apply
```

### Deploy State Management Bucket
```bash  
cd terraform/s3/terraform-state
terraform init
terraform plan
terraform apply
```

## Integration with Other Modules

### Lambda Functions
The Lambda modules depend on the packages bucket:
- [Authorizer Lambda](../lambda/authoriser/README.md)
- [S3 Files Lambda](../lambda/s3-files/README.md)

### IAM Integration
S3 buckets work with IAM policies for secure access:
- [IAM Configuration](../iam/README.md)

### Automation Scripts
Deployment scripts manage S3 resources:
- [Automation Scripts](../../bin/README.md)

## Security Considerations

- **Bucket Policies**: Restrict access to specific IAM roles and users
- **Encryption**: All buckets use server-side encryption
- **Versioning**: Enabled for audit trails and rollback capability
- **Access Logging**: CloudTrail integration for access auditing

## Cost Optimization

- **Lifecycle Policies**: Automated transition to cheaper storage classes
- **Intelligent Tiering**: Automatic cost optimization for varying access patterns
- **Deletion Policies**: Automatic cleanup of old versions and incomplete uploads

## Monitoring

- **CloudWatch Metrics**: Bucket size, request metrics, and error rates
- **CloudTrail**: API call logging for security and compliance
- **Cost Tracking**: Resource tagging for detailed cost attribution

---

*For detailed configuration and usage information, see the individual sub-module README files.*