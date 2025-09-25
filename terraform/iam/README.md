# IAM Configuration

This Terraform module manages Identity and Access Management (IAM) resources for the S-Imperatives project. It creates roles, policies, and user groups with appropriate permissions for secure operation of Lambda functions and user access.

> 📖 **Part of**: [S-Imperatives Infrastructure as Code](../../README.md)  
> 🚀 **Deployment**: [Automation Scripts](../../bin/README.md)

## Architecture

The IAM module implements a security-first approach with least-privilege access:

- **Lambda Execution Roles**: Service roles for Lambda functions with minimal required permissions
- **User Groups**: Organized access control for developers and DevOps teams
- **S3 Access Policies**: Granular permissions for S3 bucket operations
- **Cross-Service Permissions**: Secure service-to-service communication

## Resources Created

### Lambda Function Roles

#### Authorizer Lambda Role
- **Resource**: `aws_iam_role.lambda_authoriser_role`
- **Purpose**: Execution role for the API Gateway authorizer function
- **Permissions**: Basic Lambda execution with CloudWatch logging
- **Trust Relationship**: Lambda service principal

#### S3 Files Lambda Role  
- **Resource**: `aws_iam_role.lambda_s3_files_role`
- **Purpose**: Execution role for the S3 file operations function
- **Permissions**: 
  - Basic Lambda execution
  - S3 bucket read/write access
  - CloudWatch logging
- **Trust Relationship**: Lambda service principal

### User Access Groups

#### Developer Group
- **Resource**: `aws_iam_group.developer_group` (optional)
- **Purpose**: Read-only access for development teams
- **Permissions**:
  - S3 bucket listing and object reading
  - CloudWatch logs read access
  - API Gateway read access

#### DevOps Group
- **Resource**: `aws_iam_group.devops_group` (optional)
- **Purpose**: Administrative access for operations teams
- **Permissions**:
  - Full S3 bucket management
  - Lambda function management
  - API Gateway administration
  - CloudWatch full access

### S3 Access Policies

#### Developer S3 Policy
- **Resource**: `aws_iam_policy.developer_policy_s3`
- **Scope**: Read-only access to project S3 buckets
- **Actions**:
  - `s3:ListBucket`
  - `s3:GetObject`
  - `s3:GetObjectVersion`

#### DevOps S3 Policy
- **Resource**: `aws_iam_policy.devops_policy_s3`  
- **Scope**: Full access to project S3 buckets
- **Actions**:
  - All S3 operations
  - Bucket management
  - Object lifecycle management

## Configuration

### Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `prefix` | string | `"si-iac"` | Resource naming prefix |
| `environment` | string | `"dev"` | Deployment environment |
| `create_access_groups` | bool | `false` | Whether to create user groups |
| `tags` | map | `{}` | Additional resource tags |

### Outputs

| Output | Description |
|--------|-------------|
| `lambda_authoriser_role_arn` | ARN of the authorizer Lambda execution role |
| `lambda_s3_files_role_arn` | ARN of the S3 files Lambda execution role |
| `developer_group_arn` | ARN of the developer group (if created) |
| `devops_group_arn` | ARN of the DevOps group (if created) |

## Usage

### Basic Deployment
```bash
cd terraform/iam
terraform init -backend-config="envs/dev.hcl"
terraform plan
terraform apply
```

### With User Groups
```bash
terraform apply -var="create_access_groups=true"
```

### Environment-Specific Deployment
```bash
# Development
terraform apply -var-file="envs/dev.tfvars"

# Production  
terraform apply -var-file="envs/prod.tfvars"
```

## Security Considerations

### Least Privilege Principle
- All roles have minimal required permissions
- Policies use resource-specific ARNs where possible
- No wildcard permissions unless absolutely necessary

### Resource Isolation
- Environment-specific resource naming prevents cross-environment access
- Bucket policies enforce environment boundaries
- IAM boundaries prevent privilege escalation

### Audit and Compliance
- All roles and policies are tagged for tracking
- CloudTrail integration for access logging
- Regular access reviews recommended

### Best Practices
- Use temporary credentials where possible
- Rotate access keys regularly
- Monitor IAM access analyzer findings
- Implement MFA for human users

## Dependencies

This module should be deployed first as other modules depend on the IAM roles:

1. **Lambda Modules**: Require execution roles from this module
2. **API Gateway**: Uses Lambda roles for integration permissions
3. **S3 Operations**: Rely on Lambda roles for bucket access

## File Structure

```
terraform/iam/
├── README.md                           # This documentation
├── data.tf                            # Data sources and lookups
├── group-developer-policy-s3.tf       # Developer group S3 policy
├── group-developer.tf                 # Developer IAM group
├── group-devops-policy-s3.tf         # DevOps group S3 policy  
├── group-devops.tf                    # DevOps IAM group
├── lambda-authoriser-role.tf          # Authorizer Lambda role
├── lambda-s3-files-role.tf           # S3 files Lambda role
├── outputs.tf                         # Module outputs
├── providers.tf                       # Provider configuration
├── variables.tf                       # Input variables
├── versions.tf                        # Terraform version constraints
└── envs/
    └── dev.hcl                       # Environment-specific backend config
```

## Related Documentation

- [API Authorizer Source](../../src/authoriser/README.md) - Lambda function using the authorizer role
- [S3 Files Source](../../src/s3-files/README.md) - Lambda function using the S3 files role  
- [Authorizer Lambda Infrastructure](../lambda/authoriser/README.md) - Infrastructure deployment using these roles
- [S3 Files Lambda Infrastructure](../lambda/s3-files/README.md) - Infrastructure deployment using these roles
- [API Gateway Configuration](../api-gateway/README.md) - API Gateway using Lambda integrations

---

*This module provides the foundational security configuration for the entire S-Imperatives project.*