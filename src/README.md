# Source Code

This directory contains the Node.js Lambda function source code for the S-Imperatives Infrastructure as Code project.

> 📖 **Part of**: [S-Imperatives Infrastructure as Code](../README.md)  
> 🚀 **Deployment**: [Automation Scripts](../bin/README.md)

## Lambda Functions

### API Gateway Authorizer
**Path**: `authoriser/`  
**Purpose**: Custom Lambda authorizer for API Gateway authentication

The authorizer validates incoming requests and returns IAM policies to allow or deny API access. It integrates with API Gateway to provide secure access control for all endpoints.

**Documentation**: [Authorizer Function README](authoriser/README.md)

### S3 File Operations  
**Path**: `s3-files/`  
**Purpose**: Lambda function for CRUD operations on S3 objects

Provides a unified interface for reading, writing, listing, deleting, and checking the existence of files in S3 buckets through API Gateway endpoints.

**Documentation**: [S3 Files Function README](s3-files/README.md)

## Development Workflow

### Local Development
Each function directory contains:
- `index.js` - Main Lambda handler function
- `package.json` - Node.js dependencies and scripts
- `README.md` - Function-specific documentation
- `test.js` - Unit tests

### Building and Testing
```bash
# Navigate to function directory
cd src/authoriser  # or src/s3-files

# Install dependencies
npm install

# Run tests
npm test

# Run local tests (if available)
npm run test:local
```

### Deployment Process
Functions are automatically packaged and deployed through the Terraform infrastructure:

1. **Source Code**: Written in function directories
2. **Packaging**: Automated ZIP creation with dependencies
3. **Upload**: ZIP files uploaded to S3 lambda-packages bucket
4. **Deployment**: Terraform deploys from S3 references
5. **Configuration**: Environment variables set through Terraform

### Dependencies
- **Node.js**: >= 18.x runtime
- **AWS SDK**: For AWS service interactions
- **Environment Variables**: Configuration through Lambda environment

## Integration with Infrastructure

### Terraform Modules
Each function has corresponding Terraform infrastructure:
- [Authorizer Lambda Infrastructure](../terraform/lambda/authoriser/README.md)
- [S3 Files Lambda Infrastructure](../terraform/lambda/s3-files/README.md)

### IAM Integration
Functions use IAM roles defined in:
- [IAM Configuration](../terraform/iam/README.md)

### API Gateway Integration  
Functions are exposed through:
- [API Gateway Configuration](../terraform/api-gateway/README.md)

## Architecture Patterns

### Handler Pattern
```javascript
exports.handler = async (event, context) => {
    // Input validation
    // Business logic
    // Error handling  
    // Response formatting
};
```

### Error Handling
- Structured error responses
- CloudWatch logging integration
- Graceful degradation

### Configuration Management
- Environment variables for configuration
- AWS Secrets Manager for sensitive data
- Parameter validation and defaults

## Best Practices

### Code Organization
- Single responsibility functions
- Modular code structure
- Clear error handling
- Comprehensive logging

### Security
- Input validation and sanitization
- Principle of least privilege IAM roles
- Secure environment variable handling
- No hardcoded credentials

### Performance
- Efficient memory usage
- Optimized cold start times
- Connection pooling where applicable
- Appropriate timeout values

### Testing
- Unit tests for business logic
- Integration tests for AWS services
- Error case coverage
- Performance testing

## Monitoring and Debugging

### CloudWatch Integration
- Automatic log collection
- Custom metrics publishing
- Error tracking and alerting

### Local Development
```bash
# Set up local environment
export AWS_REGION=us-east-1
export LOG_LEVEL=DEBUG

# Run function locally (with tools like SAM CLI)
sam local start-api
```

### Debug Logging
Functions support configurable log levels:
- `ERROR`: Error conditions only
- `WARN`: Warnings and errors
- `INFO`: General information (default)
- `DEBUG`: Detailed debugging information

---

*This directory contains the core application logic that powers the S-Imperatives serverless API platform.*