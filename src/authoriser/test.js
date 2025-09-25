const { handler } = require('./index');

// Test event that simulates what API Gateway sends to the authorizer
const testEvent = {
    type: 'TOKEN',
    authorizationToken: 'valid-token',
    methodArn: 'arn:aws:execute-api:us-east-1:123456789012:abcdefg/dev/GET/users'
};

const testContext = {
    requestId: 'test-request-id',
    functionName: 'test-authorizer',
    remainingTimeInMillis: 30000
};

async function runTest() {
    console.log('Testing Lambda Authorizer...\n');
    
    // Test 1: Valid token
    console.log('Test 1: Valid token');
    console.log('Input:', JSON.stringify(testEvent, null, 2));
    
    try {
        const result = await handler(testEvent, testContext);
        console.log('Output:', JSON.stringify(result, null, 2));
        console.log('✅ Test 1 passed\n');
    } catch (error) {
        console.error('❌ Test 1 failed:', error.message, '\n');
    }
    
    // Test 2: Invalid token
    console.log('Test 2: Invalid token');
    const invalidTokenEvent = {
        ...testEvent,
        authorizationToken: 'invalid-token'
    };
    console.log('Input:', JSON.stringify(invalidTokenEvent, null, 2));
    
    try {
        const result = await handler(invalidTokenEvent, testContext);
        console.log('Output:', JSON.stringify(result, null, 2));
        console.log('✅ Test 2 passed\n');
    } catch (error) {
        console.error('❌ Test 2 failed:', error.message, '\n');
    }
    
    // Test 3: Missing token
    console.log('Test 3: Missing token');
    const noTokenEvent = {
        ...testEvent,
        authorizationToken: undefined
    };
    console.log('Input:', JSON.stringify(noTokenEvent, null, 2));
    
    try {
        const result = await handler(noTokenEvent, testContext);
        console.log('Output:', JSON.stringify(result, null, 2));
        console.log('✅ Test 3 passed\n');
    } catch (error) {
        console.error('❌ Test 3 failed:', error.message, '\n');
    }
    
    // Test 4: Bearer token format
    console.log('Test 4: Bearer token format');
    const bearerTokenEvent = {
        ...testEvent,
        authorizationToken: 'Bearer valid-token'
    };
    console.log('Input:', JSON.stringify(bearerTokenEvent, null, 2));
    
    try {
        const result = await handler(bearerTokenEvent, testContext);
        console.log('Output:', JSON.stringify(result, null, 2));
        console.log('✅ Test 4 passed\n');
    } catch (error) {
        console.error('❌ Test 4 failed:', error.message, '\n');
    }
}

// Run the tests
runTest().catch(console.error);