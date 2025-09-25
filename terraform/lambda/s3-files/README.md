# Lambda S3 Files Infrastructure

This Terraform module deploys the S3 file operations Lambda function with all required infrastructure components including IAM roles, S3 bucket permissions, and CloudWatch logging.

> 📖 **Part of**: [S-Imperatives Infrastructure as Code](../../../README.md)  
> 💻 **Source Code**: [S3 Files Function](../../../src/s3-files/README.md)  
> 🚀 **Deployment**: [Automation Scripts](../../../bin/README.md)  
> 🔑 **IAM**: [IAM Configuration](../../iam/README.md)

## Architecture

The S3 Files Lambda provides CRUD operations for S3 objects through API Gateway:

```
API Gateway Request
       ↓
Lambda S3 Files    ← Environment Variables
       ↓           ← IAM Role & S3 Policies
S3 Bucket          ← CloudWatch Logs
Operations         ← Error Handling
       ↓
JSON Response
```

## Resources Created

### Lambda Function
- **Resource**: `aws_lambda_function.s3_files`
- **Runtime**: Node.js 18.x
- **Memory**: 256 MB (configurable)
- **Timeout**: 60 seconds (configurable)
- **Environment**: S3 bucket configuration via environment variables

### Infrastructure Components
- **IAM Role**: Execution role with S3 and CloudWatch permissions
- **S3 Package**: ZIP file deployment from S3 bucket
- **CloudWatch Logs**: Log group with retention policy
- **Lambda Permissions**: API Gateway invoke permissions
- **S3 Permissions**: Read/write access to target S3 bucket

## Configuration

### Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `prefix` | string | `"si-iac"` | Resource naming prefix |
| `environment` | string | `"dev"` | Deployment environment |
| `lambda_memory_size` | number | `256` | Lambda memory allocation (MB) |
| `lambda_timeout` | number | `60` | Lambda timeout (seconds) |
| `log_retention_days` | number | `14` | CloudWatch log retention period |
| `s3_bucket_name` | string | `""` | Target S3 bucket for file operations |
| `lambda_environment_variables` | map | `{}` | Environment variables for Lambda |
| `tags` | map | `{}` | Additional resource tags |

### Backend Configuration
- **Backend Type**: S3
- **State Path**: `${environment}/lambda/s3-files/terraform.tfstate`
- **Backend Config**: `envs/${environment}.hcl`

### Outputs

| Output | Description |
|--------|-------------|
| `lambda_function_arn` | ARN of the deployed Lambda function |
| `lambda_function_name` | Name of the Lambda function |
| `lambda_invoke_arn` | Invoke ARN for API Gateway integration |
| `lambda_role_arn` | ARN of the Lambda execution role |
| `s3_bucket_name` | Name of the S3 bucket used for file operations |

## Dependencies

This module requires the following resources to exist:

### Required Infrastructure
1. **IAM Module**: Provides execution role with S3 permissions
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
- **IAM Module**: `lambda_s3_files_role_arn`
- **S3 Module**: `lambda_packages_bucket_name`

## Deployment

### Manual Deployment
```bash
cd terraform/lambda/s3-files

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
./bin/lambda-s3-files.sh
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
src/s3-files/
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

The Lambda function requires specific environment variables:

```hcl
lambda_environment_variables = {
  S3_BUCKET_NAME = "your-target-bucket"
  AWS_REGION = "us-east-1"
  LOG_LEVEL = "INFO"
}
```

### Required Variables
- `S3_BUCKET_NAME`: Target S3 bucket for file operations
- `AWS_REGION`: AWS region for S3 operations  

### Optional Variables
- `LOG_LEVEL`: Logging verbosity (ERROR, WARN, INFO, DEBUG)

## Supported Operations

The Lambda function supports comprehensive S3 operations:

### File Operations
- **READ**: Download and read file contents
- **WRITE**: Upload files with metadata
- **LIST**: List objects with pagination  
- **DELETE**: Remove files and folders
- **EXISTS**: Check file existence

### API Integration
Each operation is accessible through API Gateway endpoints:
- `GET /s3-files` - List files
- `POST /s3-files` - Upload file
- `PUT /s3-files` - Update file
- `DELETE /s3-files` - Delete file
- Path parameters supported for nested operations

## Monitoring and Logging

### CloudWatch Integration
- **Log Group**: `/aws/lambda/${prefix}-${environment}-s3-files`
- **Log Retention**: Configurable (default 14 days)
- **Structured Logging**: JSON format with operation context

### Metrics Available
- Invocations per operation type
- Duration by operation
- Error rates by error type
- S3 operation success/failure rates

### Custom Metrics
- File upload/download sizes
- Operation latency
- Concurrent S3 operations

### Debugging
```bash
# View logs
aws logs describe-log-groups --log-group-name-prefix="/aws/lambda/si-iac-dev-s3-files"

# Tail logs in real-time
aws logs tail /aws/lambda/si-iac-dev-s3-files --follow

# Filter by operation  
aws logs filter-events --log-group-name "/aws/lambda/si-iac-dev-s3-files" \
  --filter-pattern "{ $.operation = \"READ\" }"
```

## Security Considerations

### IAM Permissions
- **S3 Access**: Scoped to specific bucket and paths
- **Execution Role**: Minimal required permissions
- **Cross-Account**: Support for cross-account S3 access

### S3 Security
- **Bucket Policies**: Enforce encryption and access patterns  
- **Object ACLs**: Configurable per-object permissions
- **Encryption**: Server-side encryption enabled

### Input Validation
- **Path Sanitization**: Prevents directory traversal
- **File Type Validation**: Configurable allowed file types
- **Size Limits**: Configurable maximum file sizes

## Performance Optimization

### Memory and Timeout
```hcl
lambda_memory_size = 512  # Increase for large files
lambda_timeout = 300      # Increase for large uploads
```

### Concurrent Executions
- **Reserved Concurrency**: Prevent resource exhaustion
- **Provisioned Concurrency**: Reduce cold starts

### S3 Performance
- **Multipart Uploads**: Automatic for large files
- **Transfer Acceleration**: Configurable for global access

## Troubleshooting

### Common Issues

1. **S3 Access Denied**
   ```bash
   # Check IAM permissions
   aws iam get-role-policy --role-name si-iac-dev-s3-files-role --policy-name S3Access
   ```

2. **File Size Limits**
   ```hcl
   lambda_timeout = 900      # Max 15 minutes
   lambda_memory_size = 3008 # Max memory for large files
   ```

3. **Package Size Issues**
   ```bash
   # Optimize dependencies
   cd src/s3-files  
   npm install --production --omit=dev
   ```

4. **Regional Issues**
   ```hcl
   lambda_environment_variables = {
     AWS_REGION = "same-as-s3-bucket"
   }
   ```

### Debug Mode
Enable detailed logging:
```hcl
lambda_environment_variables = {
  LOG_LEVEL = "DEBUG"
}
```

## Testing

### Unit Tests
```bash
cd src/s3-files
npm test
```

### Integration Testing
```bash
# Test through API Gateway
curl -X GET https://your-api-gateway-url/s3-files \
  -H "Authorization: Bearer your-token"
```

### Load Testing  
```bash
# Use artillery or similar tools
artillery run load-test-config.yml
```

## Related Documentation

- [S3 Files Source Code](../../../src/s3-files/README.md) - Lambda function implementation
- [API Gateway Integration](../../api-gateway/README.md) - API Gateway routing and integration
- [IAM Configuration](../../iam/README.md) - IAM roles and S3 policies
- [S3 Lambda Packages](../../s3/lambda-packages/README.md) - Package storage configuration

---

*This module provides the core file management capabilities for the S-Imperatives API platform.*