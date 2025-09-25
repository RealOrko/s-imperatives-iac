# API Gateway Infrastructure

This Terraform module creates an HTTP API Gateway using the `terraform-aws-apigateway-v2` module. The API Gateway provides endpoints for S3 file operations with Lambda authorizer integration.

## Architecture

The API Gateway includes:

- **HTTP API Gateway** - Main API endpoint with CORS configuration
- **Lambda Authorizer** - Custom authorization using the authoriser lambda function
- **S3 Files Routes** - CRUD operations (GET, POST, PUT, DELETE) for `/s3-files` endpoint
- **Path Parameter Support** - Routes with `{proxy+}` for handling nested paths

## Routes

| Method | Route | Description | Authorization |
|--------|-------|-------------|---------------|
| GET | `/s3-files` | Retrieve S3 files | Lambda Authorizer |
| POST | `/s3-files` | Create/upload S3 files | Lambda Authorizer |
| PUT | `/s3-files` | Update S3 files | Lambda Authorizer |
| DELETE | `/s3-files` | Delete S3 files | Lambda Authorizer |
| GET | `/s3-files/{proxy+}` | Retrieve specific S3 files with path | Lambda Authorizer |
| POST | `/s3-files/{proxy+}` | Create specific S3 files with path | Lambda Authorizer |
| PUT | `/s3-files/{proxy+}` | Update specific S3 files with path | Lambda Authorizer |
| DELETE | `/s3-files/{proxy+}` | Delete specific S3 files with path | Lambda Authorizer |

## Dependencies

This module requires the following remote state outputs:

### Lambda Functions
- **lambda_authoriser**: Provides the authorizer lambda function ARN and name
- **lambda_s3_files**: Provides the s3-files lambda function ARN and name

Remote state keys:
- `${var.environment}/lambda-iac/authoriser/terraform.tfstate`
- `${var.environment}/lambda-iac/s3-files/terraform.tfstate`

### IAM Roles
- **iam**: Provides IAM roles for lambda functions

Remote state key:
- `${var.environment}/iam/terraform.tfstate`

## Configuration

### Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `region` | AWS region | string | `eu-west-2` |
| `environment` | Environment name | string | `dev` |
| `prefix` | Resource prefix | string | `si-iac` |
| `domain_name` | Custom domain name (optional) | string | `null` |
| `certificate_arn` | ACM certificate ARN for custom domain | string | `null` |
| `stage_name` | API Gateway stage name | string | `$default` |
| `throttling_rate_limit` | API throttling rate limit | number | `100` |
| `throttling_burst_limit` | API throttling burst limit | number | `50` |

### Environment Configuration

The `envs/dev.hcl` file configures the Terraform backend:

```hcl
key            = "dev/api-gateway/terraform.tfstate"
bucket         = "si-iac-terraform-state-store"
region         = "eu-west-2"
encrypt        = true
```

## Deployment

### Prerequisites

1. Ensure the following Terraform modules are deployed first:
   - `terraform/iam/` - IAM roles and policies
   - `terraform/s3/lambda-packages/` - S3 bucket for lambda packages
   - `terraform/lambda/authoriser/` - Lambda authorizer function
   - `terraform/lambda/s3-files/` - Lambda s3-files function

### Deploy Steps

1. Initialize Terraform:
```bash
cd terraform/api-gateway
terraform init -backend-config="envs/dev.hcl"
```

2. Plan the deployment:
```bash
terraform plan -var-file="envs/dev.tfvars" # if using tfvars file
# or
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

## Outputs

| Output | Description |
|--------|-------------|
| `api_id` | The ID of the API Gateway |
| `api_arn` | The ARN of the API Gateway |
| `api_endpoint` | The URI of the API Gateway |
| `api_execution_arn` | The ARN prefix for lambda permissions |
| `stage_arn` | The default stage ARN |
| `stage_domain_name` | Domain name of the stage |
| `authorizer_id` | The ID of the Lambda authorizer |

## Usage Examples

### Making API Calls

Once deployed, you can make HTTP requests to the API endpoint:

```bash
# Get API endpoint from outputs
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Example requests (replace with actual authorization token)
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -X GET "${API_ENDPOINT}/s3-files"

curl -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -X POST "${API_ENDPOINT}/s3-files" \
     -d '{"filename": "example.txt", "content": "Hello World"}'
```

### Custom Domain (Optional)

To use a custom domain, set the variables:

```hcl
domain_name = "api.yourdomain.com"
certificate_arn = "arn:aws:acm:region:account:certificate/cert-id"
```

## Security

- All `/s3-files` routes require authorization via the Lambda authorizer
- CORS is configured to allow all origins (modify as needed for production)
- API Gateway automatically creates CloudWatch logs for monitoring

## Monitoring

The API Gateway includes:
- CloudWatch metrics for API performance
- Default throttling limits (configurable)
- Integration with AWS X-Ray for tracing (can be enabled)

## Troubleshooting

### Common Issues

1. **Lambda Permission Errors**: Ensure lambda functions are deployed and accessible
2. **Authorizer Failures**: Check authorizer lambda logs in CloudWatch
3. **CORS Issues**: Verify CORS configuration matches your client requirements
4. **State Dependencies**: Ensure all dependent infrastructure is deployed first