# API Gateway Lambda Authorizer

This is a Lambda authorizer for use with AWS API Gateway. It validates incoming requests and returns an IAM policy that allows or denies access to API Gateway resources.

> 📖 **Part of**: [S-Imperatives Infrastructure as Code](../../README.md)  
> 🏗️ **Infrastructure**: [Authorizer Lambda Terraform Module](../../terraform/lambda/authoriser/README.md)  
> 🚀 **Deployment**: [Automation Scripts](../../bin/README.md)

## Overview

The Lambda authorizer is invoked by API Gateway before your API methods are executed. It receives an authorization token (typically from the `Authorization` header) and returns an IAM policy that determines whether the request should be allowed or denied.

This authorizer is designed to work with the [S3 Files API](../s3-files/README.md) and is deployed as part of the complete [API Gateway infrastructure](../../terraform/api-gateway/README.md).

## Files

- `index.js` - Main Lambda function handler
- `package.json` - Node.js dependencies and scripts
- `README.md` - This documentation

## How it Works

1. API Gateway receives a request with an authorization token
2. API Gateway invokes this Lambda function with the token and method ARN
3. The function validates the token using your custom logic
4. If valid, it returns an "Allow" policy; if invalid, it returns a "Deny" policy
5. API Gateway uses the policy to allow or deny the request

## Event Structure

The Lambda function receives an event with this structure:

```json
{
  "type": "TOKEN",
  "authorizationToken": "Bearer your-token-here",
  "methodArn": "arn:aws:execute-api:us-east-1:123456789012:abcdefg/dev/GET/users"
}
```

## Response Structure

The function returns a policy response:

```json
{
  "principalId": "user123",
  "policyDocument": {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "execute-api:Invoke",
        "Effect": "Allow",
        "Resource": "arn:aws:execute-api:us-east-1:123456789012:abcdefg/dev/GET/users"
      }
    ]
  },
  "context": {
    "userId": "user123",
    "timestamp": "2023-01-01T00:00:00.000Z"
  }
}
```

## Customization

To use this authorizer in production, you'll need to customize the `validateToken` function to implement your authentication logic:

### JWT Token Validation

```javascript
async function validateToken(token) {
    try {
        const cleanToken = token.replace(/^Bearer\s+/i, '');
        const decoded = jwt.verify(cleanToken, process.env.JWT_SECRET);
        return decoded.sub; // Return user ID from JWT subject
    } catch (error) {
        return null;
    }
}
```

### API Key Validation

```javascript
async function validateToken(token) {
    try {
        // Query your database or external service
        const user = await getUserByApiKey(token);
        return user ? user.id : null;
    } catch (error) {
        return null;
    }
}
```

### Environment Variables

Set these environment variables in your Lambda function:

- `JWT_SECRET` - Secret key for JWT validation (if using JWT)
- `API_KEY_TABLE` - DynamoDB table name for API key storage (if using DynamoDB)
- `LOG_LEVEL` - Logging level (DEBUG, INFO, WARN, ERROR)

## Testing Locally

You can test the function locally by creating a test event:

```javascript
const event = {
    type: 'TOKEN',
    authorizationToken: 'valid-token',
    methodArn: 'arn:aws:execute-api:us-east-1:123456789012:abcdefg/dev/GET/users'
};

const context = {};
const result = await require('./index').handler(event, context);
console.log(JSON.stringify(result, null, 2));
```

## Deployment

1. Install dependencies:
   ```bash
   npm install
   ```

2. Package the function:
   ```bash
   npm run package
   ```

3. Upload `authorizer.zip` to AWS Lambda or use your preferred deployment method (Terraform, SAM, etc.)

## API Gateway Configuration

1. Create a Lambda Authorizer in API Gateway
2. Set the authorizer type to "Lambda"
3. Select your Lambda function
4. Set the token source to "Authorization" header
5. Configure caching (optional but recommended)

## Security Considerations

- Always validate tokens thoroughly
- Use environment variables for secrets
- Implement proper error handling
- Consider token caching for performance
- Log authorization attempts for auditing
- Use least-privilege IAM policies

## Performance Tips

- Enable result caching in API Gateway (TTL based on your token expiry)
- Keep the function code minimal and dependencies light
- Use environment variables instead of hardcoded values
- Consider warming strategies for cold starts