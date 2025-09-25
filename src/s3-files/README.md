# S3 File Resource Lambda Function

A Node.js Lambda function for performing CRUD operations on files stored in Amazon S3. This function provides a unified interface for reading, writing, listing, deleting, and checking the existence of files in an S3 bucket.

> 📖 **Part of**: [S-Imperatives Infrastructure as Code](../../README.md)  
> 🏗️ **Infrastructure**: [S3 Files Lambda Terraform Module](../../terraform/lambda/s3-files/README.md)  
> 🚀 **Deployment**: [Automation Scripts](../../bin/README.md)  
> 🔐 **Security**: [API Authorizer](../authoriser/README.md)

## Features

- **Read Files**: Download and read file contents from S3
- **Write Files**: Upload files to S3 with customizable options
- **List Files**: List objects in S3 with pagination and filtering
- **Delete Files**: Remove files from S3
- **Check Existence**: Verify if a file exists in S3
- **Environment Variable Configuration**: Fully configurable via environment variables
- **Comprehensive Error Handling**: Detailed error messages and logging
- **Input Validation**: Validates all inputs before processing
- **Structured Logging**: JSON-formatted logs with configurable levels

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `S3_BUCKET_NAME` | Yes | - | The S3 bucket name to operate on |
| `AWS_REGION` | No | `us-east-1` | AWS region where the S3 bucket is located |
| `LOG_LEVEL` | No | `INFO` | Logging level: ERROR, WARN, INFO, DEBUG |

## Supported Operations

### 1. Read File

Reads a file from S3 and returns its content along with metadata.

**Parameters:**
- `operation`: `"read"`
- `key`: S3 object key (required)
- `encoding`: Content encoding - `"utf8"`, `"binary"`, etc. (optional, default: `"utf8"`)

**Example:**
```json
{
  "operation": "read",
  "key": "documents/example.txt",
  "encoding": "utf8"
}
```

**Response:**
```json
{
  "statusCode": 200,
  "body": {
    "success": true,
    "operation": "read",
    "result": {
      "content": "File content here...",
      "contentType": "text/plain",
      "lastModified": "2025-09-25T10:00:00.000Z",
      "contentLength": 1024,
      "etag": "\"d41d8cd98f00b204e9800998ecf8427e\"",
      "metadata": {}
    },
    "timestamp": "2025-09-25T10:00:00.000Z"
  }
}
```

### 2. Write File

Writes content to an S3 object.

**Parameters:**
- `operation`: `"write"`
- `key`: S3 object key (required)
- `content`: File content as string or Buffer (required)
- `options`: Write options (optional)
  - `contentType`: MIME type (default: `"application/octet-stream"`)
  - `metadata`: Custom metadata object
  - `acl`: Access control list
  - `cacheControl`: Cache control header
  - `expires`: Expiration date
  - `storageClass`: S3 storage class

**Example:**
```json
{
  "operation": "write",
  "key": "documents/new-file.txt",
  "content": "Hello, World!",
  "options": {
    "contentType": "text/plain",
    "metadata": {
      "author": "Lambda Function",
      "purpose": "example"
    },
    "acl": "private"
  }
}
```

**Response:**
```json
{
  "statusCode": 200,
  "body": {
    "success": true,
    "operation": "write",
    "result": {
      "etag": "\"d41d8cd98f00b204e9800998ecf8427e\"",
      "location": "s3://my-bucket/documents/new-file.txt",
      "key": "documents/new-file.txt",
      "bucket": "my-bucket"
    },
    "timestamp": "2025-09-25T10:00:00.000Z"
  }
}
```

### 3. List Files

Lists objects in the S3 bucket with optional filtering and pagination.

**Parameters:**
- `operation`: `"list"`
- `options`: List options (optional)
  - `prefix`: Object key prefix filter
  - `maxKeys`: Maximum number of keys to return (1-1000, default: 1000)
  - `continuationToken`: Token for pagination
  - `delimiter`: Delimiter for grouping keys

**Example:**
```json
{
  "operation": "list",
  "options": {
    "prefix": "documents/",
    "maxKeys": 100,
    "delimiter": "/"
  }
}
```

**Response:**
```json
{
  "statusCode": 200,
  "body": {
    "success": true,
    "operation": "list",
    "result": {
      "files": [
        {
          "key": "documents/example.txt",
          "lastModified": "2025-09-25T10:00:00.000Z",
          "etag": "\"d41d8cd98f00b204e9800998ecf8427e\"",
          "size": 1024,
          "storageClass": "STANDARD"
        }
      ],
      "commonPrefixes": ["documents/subfolder/"],
      "isTruncated": false,
      "keyCount": 1,
      "maxKeys": 100
    },
    "timestamp": "2025-09-25T10:00:00.000Z"
  }
}
```

### 4. Delete File

Deletes a file from S3.

**Parameters:**
- `operation`: `"delete"`
- `key`: S3 object key (required)

**Example:**
```json
{
  "operation": "delete",
  "key": "documents/old-file.txt"
}
```

**Response:**
```json
{
  "statusCode": 200,
  "body": {
    "success": true,
    "operation": "delete",
    "result": {
      "deleted": true,
      "key": "documents/old-file.txt",
      "bucket": "my-bucket"
    },
    "timestamp": "2025-09-25T10:00:00.000Z"
  }
}
```

### 5. Check File Existence

Checks if a file exists in S3 and returns its metadata.

**Parameters:**
- `operation`: `"exists"`
- `key`: S3 object key (required)

**Example:**
```json
{
  "operation": "exists",
  "key": "documents/check-me.txt"
}
```

**Response (file exists):**
```json
{
  "statusCode": 200,
  "body": {
    "success": true,
    "operation": "exists",
    "result": {
      "exists": true,
      "contentType": "text/plain",
      "contentLength": 1024,
      "lastModified": "2025-09-25T10:00:00.000Z",
      "etag": "\"d41d8cd98f00b204e9800998ecf8427e\"",
      "metadata": {}
    },
    "timestamp": "2025-09-25T10:00:00.000Z"
  }
}
```

**Response (file doesn't exist):**
```json
{
  "statusCode": 200,
  "body": {
    "success": true,
    "operation": "exists",
    "result": {
      "exists": false
    },
    "timestamp": "2025-09-25T10:00:00.000Z"
  }
}
```

## Error Handling

The function returns structured error responses with appropriate HTTP status codes:

```json
{
  "statusCode": 400,
  "body": {
    "success": false,
    "error": "Key is required for read operation",
    "operation": "read",
    "timestamp": "2025-09-25T10:00:00.000Z"
  }
}
```

Common error scenarios:
- Missing required parameters (400)
- Invalid S3 object keys (400)
- Missing environment variables (500)
- AWS service errors (varies)
- File not found (handled gracefully in exists operation)

## IAM Permissions

The Lambda function requires the following IAM permissions on the target S3 bucket:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:HeadObject"
      ],
      "Resource": [
        "arn:aws:s3:::your-bucket-name",
        "arn:aws:s3:::your-bucket-name/*"
      ]
    }
  ]
}
```

## Deployment

1. **Install Dependencies:**
   ```bash
   npm install
   ```

2. **Create Deployment Package:**
   ```bash
   npm run zip
   ```

3. **Deploy to AWS Lambda:**
   - Upload the `function.zip` file to your Lambda function
   - Set the handler to `index.handler`
   - Configure environment variables
   - Set appropriate IAM role with S3 permissions

4. **Test the Function:**
   Use the AWS Lambda console or AWS CLI to test with sample events.

## Logging

The function uses structured JSON logging with configurable levels:

- **ERROR**: Critical errors that prevent operation completion
- **WARN**: Warning conditions that don't prevent operation completion
- **INFO**: General operational information (default level)
- **DEBUG**: Detailed diagnostic information

Logs include:
- Timestamp
- Log level
- Message
- Contextual data (request ID, operation details, etc.)

## Security Considerations

1. **Environment Variables**: Store sensitive configuration in environment variables
2. **IAM Permissions**: Use least-privilege IAM policies
3. **Input Validation**: All inputs are validated before processing
4. **Error Handling**: Errors are logged but sensitive information is not exposed
5. **Object Key Validation**: Keys are validated for length and format

## Testing

A basic test file structure is provided. Run tests with:

```bash
npm test
```

## Version Requirements

- Node.js >= 18
- AWS SDK v3 (@aws-sdk/client-s3)

## License

ISC License