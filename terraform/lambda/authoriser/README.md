# Lambda Authorizer Infrastructure

This Terraform module deploys the API Gateway Lambda authorizer function with all required infrastructure components including IAM roles, S3 package storage, and CloudWatch logging.

> 📖 **Part of**: [S-Imperatives Infrastructure as Code](../../../README.md)  
> 💻 **Source Code**: [Authorizer Function](../../../src/authoriser/README.md)  
> 🚀 **Deployment**: [Automation Scripts](../../../bin/README.md)  
> 🔑 **IAM**: [IAM Configuration](../../iam/README.md)

## Architecture

The Lambda authorizer provides custom authentication for the API Gateway:

```
API Gateway Request
       ↓
Lambda Authorizer ← Environment Variables
       ↓            ← IAM Role & Policies  
IAM Policy Response  ← CloudWatch Logs
       ↓
API Gateway (Allow/Deny)
```

## Resources Created

### Lambda Function
- **Resource**: `aws_lambda_function.authoriser`
- **Runtime**: Node.js 18.x
- **Memory**: 128 MB (configurable)
- **Timeout**: 30 seconds (configurable)
- **Environment**: Configurable via environment variables

### Infrastructure Components
- **IAM Role**: Execution role with CloudWatch logging permissions
- **S3 Package**: ZIP file deployment from S3 bucket
- **CloudWatch Logs**: Log group with retention policy
- **Lambda Permissions**: API Gateway invoke permissions

## Configuration

### Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `prefix` | string | `"si-iac"` | Resource naming prefix |
| `environment` | string | `"dev"` | Deployment environment |
| `lambda_memory_size` | number | `128` | Lambda memory allocation (MB) |
| `lambda_timeout` | number | `30` | Lambda timeout (seconds) |
| `log_retention_days` | number | `14` | CloudWatch log retention period |
| `lambda_environment_variables` | map | `{}` | Environment variables for Lambda |
| `tags` | map | `{}` | Additional resource tags |

### Backend Configuration
- **Backend Type**: S3
- **State Path**: `${environment}/lambda/authoriser/terraform.tfstate`
- **Backend Config**: `envs/${environment}.hcl`

### Outputs

| Output | Description |
|--------|-------------|
| `lambda_function_arn` | ARN of the deployed Lambda function |
| `lambda_function_name` | Name of the Lambda function |
| `lambda_invoke_arn` | Invoke ARN for API Gateway integration |
| `lambda_role_arn` | ARN of the Lambda execution role |

## Dependencies

This module requires the following resources to exist:

### Required Infrastructure
1. **IAM Module**: Provides execution role
   ```bash
   # Deploy first
   ./bin/iam.sh
   ```

2. **S3 Lambda Packages**: Provides package storage
   ```bash  
   # Deploy second
   ./bin/s3-lambda-packages.sh
   ```

### Remote State Dependencies
The module reads outputs from:
- **IAM Module**: `lambda_authoriser_role_arn`
- **S3 Module**: `lambda_packages_bucket_name`

## Deployment

### Manual Deployment
```bash
cd terraform/lambda/authoriser

# Initialize with environment-specific backend
terraform init -backend-config="envs/dev.hcl"

# Plan deployment
terraform plan

# Apply changes  
terraform apply
```

### Automated Deployment
```bash
# Deploy as part of full infrastructure
./bin/all-create.sh

# Or deploy individually
./bin/lambda-authoriser.sh
```

### Environment-Specific Deployment
```bash
# Development
terraform apply -var-file="envs/dev.tfvars"

# Production
terraform apply -var-file="envs/prod.tfvars"  
```

## Source Code Integration

### Code Packaging
The Lambda function code is automatically packaged from the source directory:
```
src/authoriser/
├── index.js          # Main handler function
├── package.json      # Node.js dependencies  
├── README.md         # Function documentation
└── test.js          # Unit tests
```

### Build Process
1. Install dependencies: `npm install`
2. Create ZIP package with all files
3. Upload to S3 lambda-packages bucket
4. Deploy Lambda with S3 object reference

## Environment Variables

The Lambda function can be configured with environment variables:

```hcl
lambda_environment_variables = {
  LOG_LEVEL = "INFO"
  AUTH_SECRET = "your-auth-secret"  
  TOKEN_EXPIRY = "3600"
}
```

## Monitoring and Logging

### CloudWatch Integration
- **Log Group**: `/aws/lambda/${prefix}-${environment}-authoriser`
- **Log Retention**: Configurable (default 14 days)
- **Log Streams**: Automatic per-execution logs

### Metrics Available
- Invocations
- Duration  
- Errors
- Throttles
- Concurrent Executions

### Debugging
```bash
# View logs
aws logs describe-log-groups --log-group-name-prefix="/aws/lambda/si-iac-dev-authoriser"

# Tail logs in real-time
aws logs tail /aws/lambda/si-iac-dev-authoriser --follow
```

## Security Considerations

### IAM Permissions
- **Principle of Least Privilege**: Only required permissions granted
- **Execution Role**: Separate role with minimal permissions
- **CloudWatch**: Write-only logging permissions

### Network Security  
- **VPC**: Optional VPC integration for private resources
- **Security Groups**: Configurable network access rules

### Code Security
- **Environment Variables**: Encrypted at rest
- **Secrets**: Use AWS Secrets Manager for sensitive data
- **Input Validation**: Validate all authorization tokens

## Troubleshooting

### Common Issues

1. **Deployment Fails - Missing Dependencies**
   ```bash
   # Ensure dependencies are deployed
   ./bin/iam.sh
   ./bin/s3-lambda-packages.sh
   ```

2. **Function Timeout**
   ```hcl
   lambda_timeout = 60  # Increase timeout
   ```

3. **Memory Issues**
   ```hcl
   lambda_memory_size = 256  # Increase memory
   ```

4. **Package Too Large**
   ```bash
   # Optimize package size
   cd src/authoriser
   npm install --production
   ```

### Debug Mode
Enable detailed logging:
```hcl
lambda_environment_variables = {
  LOG_LEVEL = "DEBUG"
}
```

## Related Documentation

- [Authorizer Source Code](../../../src/authoriser/README.md) - Lambda function implementation
- [API Gateway Integration](../../api-gateway/README.md) - How the authorizer integrates with API Gateway
- [IAM Configuration](../../iam/README.md) - IAM roles and policies used
- [S3 Lambda Packages](../../s3/lambda-packages/README.md) - Package storage configuration

---

*This module provides the infrastructure foundation for secure API authorization using AWS Lambda.*