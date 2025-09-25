/**
 * AWS Lambda Authorizer for API Gateway
 * 
 * This function validates incoming requests and returns an IAM policy
 * that allows or denies access to API Gateway resources.
 */

exports.handler = async (event, context) => {
    console.log('Lambda Authorizer Event:', JSON.stringify(event, null, 2));
    
    try {
        // Extract the authorization token from the event
        const token = event.authorizationToken;
        const methodArn = event.methodArn;
        
        if (!token) {
            console.log('No authorization token provided');
            throw new Error('Unauthorized');
        }
        
        // Extract the principal user identifier from the token
        // This is a simplified example - in production, you would validate JWT tokens,
        // API keys, or other authentication mechanisms
        const principalId = await validateToken(token);
        
        if (!principalId) {
            console.log('Invalid token provided');
            throw new Error('Unauthorized');
        }
        
        // Generate the IAM policy based on the token validation result
        const policy = generatePolicy(principalId, 'Allow', methodArn);
        
        console.log('Generated policy:', JSON.stringify(policy, null, 2));
        return policy;
        
    } catch (error) {
        console.error('Authorization failed:', error.message);
        
        // Return a policy that denies access
        const policy = generatePolicy('user', 'Deny', event.methodArn);
        return policy;
    }
};

/**
 * Validates the authorization token
 * @param {string} token - The authorization token
 * @returns {Promise<string|null>} - Returns the principal ID if valid, null otherwise
 */
async function validateToken(token) {
    try {
        // Remove 'Bearer ' prefix if present
        const cleanToken = token.replace(/^Bearer\s+/i, '');
        
        // Example validation - replace with your actual token validation logic
        if (cleanToken === 'valid-token') {
            return 'user123'; // Return user identifier
        }
        
        // Example: Validate JWT token
        // const decoded = jwt.verify(cleanToken, process.env.JWT_SECRET);
        // return decoded.sub; // Return subject from JWT
        
        // Example: Validate API key against database
        // const user = await getUserByApiKey(cleanToken);
        // return user ? user.id : null;
        
        return null;
        
    } catch (error) {
        console.error('Token validation error:', error.message);
        return null;
    }
}

/**
 * Generates an IAM policy for API Gateway
 * @param {string} principalId - The principal user identifier
 * @param {string} effect - 'Allow' or 'Deny'
 * @param {string} resource - The method ARN
 * @returns {object} - The IAM policy object
 */
function generatePolicy(principalId, effect, resource) {
    const authResponse = {
        principalId: principalId,
    };
    
    if (effect && resource) {
        const policyDocument = {
            Version: '2012-10-17',
            Statement: [
                {
                    Action: 'execute-api:Invoke',
                    Effect: effect,
                    Resource: resource
                }
            ]
        };
        authResponse.policyDocument = policyDocument;
    }
    
    // Optional: Add context that can be accessed in the API Gateway integration
    authResponse.context = {
        userId: principalId,
        timestamp: new Date().toISOString(),
        // Add any additional context you want to pass to your API
    };
    
    return authResponse;
}

/**
 * Generates a policy that allows access to all methods in the API
 * @param {string} principalId - The principal user identifier
 * @param {string} methodArn - The method ARN to extract the API ARN from
 * @returns {object} - The IAM policy object
 */
function generateAllowAllPolicy(principalId, methodArn) {
    // Extract the API ARN by replacing the method and stage parts with wildcards
    const apiArn = methodArn.split('/').slice(0, 2).join('/') + '/*/*';
    
    return {
        principalId: principalId,
        policyDocument: {
            Version: '2012-10-17',
            Statement: [
                {
                    Action: 'execute-api:Invoke',
                    Effect: 'Allow',
                    Resource: apiArn
                }
            ]
        },
        context: {
            userId: principalId,
            timestamp: new Date().toISOString(),
        }
    };
}

/**
 * Generates a policy that denies access to all methods
 * @param {string} principalId - The principal user identifier
 * @returns {object} - The IAM policy object
 */
function generateDenyAllPolicy(principalId) {
    return {
        principalId: principalId,
        policyDocument: {
            Version: '2012-10-17',
            Statement: [
                {
                    Action: 'execute-api:Invoke',
                    Effect: 'Deny',
                    Resource: '*'
                }
            ]
        }
    };
}