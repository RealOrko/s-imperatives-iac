# S-Imperatives Infrastructure as Code

A comprehensive Infrastructure as Code (IaC) solution for building an S3 file management API using AWS services. This project implements a serverless architecture with API Gateway, Lambda functions, and proper IAM security configurations using Terraform.

## Architecture Overview

This project creates a complete serverless file management system with the following components:

- **API Gateway**: HTTP API with custom Lambda authorizer for secure access
- **Lambda Functions**: 
  - Authorizer function for API authentication
  - S3 files function for CRUD operations on S3 objects
- **S3 Buckets**: Storage for Lambda deployment packages and state management
- **IAM**: Comprehensive roles and policies for secure service interactions

## Project Structure

```
├── bin/                          # Automation scripts for deployment
├── src/                          # Lambda function source code
│   ├── authoriser/              # API Gateway authorizer function
│   └── s3-files/               # S3 file operations function
└── terraform/                   # Infrastructure as Code modules
    ├── api-gateway/            # HTTP API Gateway configuration
    ├── iam/                    # IAM roles and policies
    ├── lambda/                 # Lambda function deployments
    │   ├── authoriser/         # Authorizer function infrastructure
    │   └── s3-files/          # S3 files function infrastructure
    └── s3/                     # S3 bucket configurations
        ├── lambda-packages/    # Lambda deployment packages storage
        └── terraform-state/   # Terraform state management
```

## Quick Start

1. **Prerequisites**:
   - AWS CLI configured with appropriate credentials
   - Terraform >= 1.0
   - Node.js >= 18.x
   - Bash shell

2. **Environment Setup**:
   ```bash
   cp .env.example .env
   # Edit .env with your AWS configuration
   ```

3. **Deploy All Infrastructure**:
   ```bash
   ./bin/all-create.sh
   ```

4. **Destroy All Infrastructure**:
   ```bash
   ./bin/all-destroy.sh
   ```

## Component Documentation

### Automation Scripts
- [📁 Deployment Scripts](bin/README.md) - Automated deployment and management scripts

### Source Code
- [� Lambda Functions](src/README.md) - Overview of all Lambda function source code
- [�🔐 API Authorizer](src/authoriser/README.md) - Lambda function for API Gateway authorization
- [📁 S3 File Manager](src/s3-files/README.md) - Lambda function for S3 CRUD operations

### Infrastructure Modules

#### Overview
- [🏗️ Terraform Infrastructure](terraform/README.md) - Overview of all infrastructure modules

#### Core Services
- [🚪 API Gateway](terraform/api-gateway/README.md) - HTTP API with custom authorization
- [🔑 IAM Configuration](terraform/iam/README.md) - Roles and policies for service security

#### Lambda Functions
- [⚡ Authorizer Lambda](terraform/lambda/authoriser/README.md) - API Gateway authorizer deployment
- [📂 S3 Files Lambda](terraform/lambda/s3-files/README.md) - S3 operations function deployment

#### Storage & State
- [🗄️ S3 Buckets](terraform/s3/README.md) - Storage bucket configurations
- [📦 Lambda Packages](terraform/s3/lambda-packages/README.md) - Lambda deployment package storage
- [💾 Terraform State](terraform/s3/terraform-state/README.md) - Terraform state management

## Features

- **🔒 Secure by Design**: Custom Lambda authorizer with IAM policies
- **📁 Complete S3 Management**: Full CRUD operations on S3 objects
- **🚀 Serverless Architecture**: No infrastructure management overhead  
- **🔄 Automated Deployment**: One-command deployment and destruction
- **📋 Comprehensive Logging**: Structured logging across all components
- **🏗️ Modular Terraform**: Reusable, well-organized infrastructure modules
- **🧪 Environment Isolation**: Support for multiple deployment environments

## API Endpoints

Once deployed, the API provides the following endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/s3-files` | List S3 files |
| POST   | `/s3-files` | Upload new file |
| PUT    | `/s3-files` | Update existing file |
| DELETE | `/s3-files` | Delete file |
| GET    | `/s3-files/{path}` | Get specific file |
| POST   | `/s3-files/{path}` | Upload to specific path |
| PUT    | `/s3-files/{path}` | Update specific file |
| DELETE | `/s3-files/{path}` | Delete specific file |

## Environment Configuration

The project uses environment variables for configuration. Key variables include:

- `AWS_REGION`: Target AWS region for deployment
- `ENVIRONMENT`: Deployment environment (dev, staging, prod)
- `S3_BUCKET_NAME`: S3 bucket for file operations
- `LOG_LEVEL`: Application logging level

## Contributing

1. Follow the existing code structure and naming conventions
2. Update relevant README files when adding new components
3. Test thoroughly in a development environment before production deployment
4. Ensure all Terraform modules include proper variable definitions and outputs

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions or issues:
1. Check the component-specific README files linked above
2. Review the Terraform module documentation
3. Examine the Lambda function logs in CloudWatch
4. Verify IAM permissions and API Gateway configuration

---

*Generated on: $(date)*