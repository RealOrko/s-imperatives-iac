const { handler, operations } = require('./index');

// Mock AWS context
const createMockContext = () => ({
  awsRequestId: 'test-request-id-' + Math.random().toString(36).substr(2, 9),
  functionName: 's3-file-resource-lambda',
  functionVersion: '$LATEST',
  memoryLimitInMB: '128',
  remainingTimeInMS: () => 5000
});

// Test configuration
const TEST_CONFIG = {
  S3_BUCKET_NAME: 'test-bucket-name',
  AWS_REGION: 'us-east-1',
  LOG_LEVEL: 'DEBUG'
};

// Set environment variables for testing
Object.assign(process.env, TEST_CONFIG);

// Test cases
const testCases = [
  {
    name: 'Read File - Valid Request',
    event: {
      operation: 'read',
      key: 'test-files/example.txt',
      encoding: 'utf8'
    },
    shouldSucceed: true
  },
  {
    name: 'Read File - Missing Key',
    event: {
      operation: 'read',
      encoding: 'utf8'
    },
    shouldSucceed: false,
    expectedError: 'Key is required for read operation'
  },
  {
    name: 'Write File - Valid Request',
    event: {
      operation: 'write',
      key: 'test-files/new-file.txt',
      content: 'Hello, World! This is a test file.',
      options: {
        contentType: 'text/plain',
        metadata: {
          author: 'test-suite',
          purpose: 'unit-testing'
        }
      }
    },
    shouldSucceed: true
  },
  {
    name: 'Write File - Missing Content',
    event: {
      operation: 'write',
      key: 'test-files/empty-file.txt'
    },
    shouldSucceed: false,
    expectedError: 'Content is required for write operation'
  },
  {
    name: 'List Files - Valid Request',
    event: {
      operation: 'list',
      options: {
        prefix: 'test-files/',
        maxKeys: 50
      }
    },
    shouldSucceed: true
  },
  {
    name: 'List Files - All Files',
    event: {
      operation: 'list'
    },
    shouldSucceed: true
  },
  {
    name: 'Delete File - Valid Request',
    event: {
      operation: 'delete',
      key: 'test-files/to-delete.txt'
    },
    shouldSucceed: true
  },
  {
    name: 'Delete File - Missing Key',
    event: {
      operation: 'delete'
    },
    shouldSucceed: false,
    expectedError: 'Key is required for delete operation'
  },
  {
    name: 'File Exists - Valid Request',
    event: {
      operation: 'exists',
      key: 'test-files/check-existence.txt'
    },
    shouldSucceed: true
  },
  {
    name: 'Invalid Operation',
    event: {
      operation: 'invalid',
      key: 'test-files/some-file.txt'
    },
    shouldSucceed: false,
    expectedError: 'Invalid operation: invalid'
  },
  {
    name: 'Missing Operation',
    event: {
      key: 'test-files/some-file.txt'
    },
    shouldSucceed: false,
    expectedError: 'Operation is required'
  }
];

// Test runner
async function runTests() {
  console.log('🧪 Starting S3 File Resource Lambda Tests');
  console.log('==========================================\\n');
  
  let passedTests = 0;
  let totalTests = testCases.length;
  
  for (const testCase of testCases) {
    console.log(`🔍 Testing: ${testCase.name}`);
    
    try {
      const context = createMockContext();
      const result = await handler(testCase.event, context);
      
      if (testCase.shouldSucceed) {
        if (result.statusCode === 200 && result.body.success) {
          console.log(`✅ PASS: ${testCase.name}`);
          console.log(`   Result: ${JSON.stringify(result.body.result, null, 2).substring(0, 100)}...`);
          passedTests++;
        } else {
          console.log(`❌ FAIL: ${testCase.name}`);
          console.log(`   Expected success but got: ${JSON.stringify(result.body)}`);
        }
      } else {
        if (result.statusCode !== 200 && !result.body.success) {
          const errorMatches = !testCase.expectedError || 
                              result.body.error.includes(testCase.expectedError);
          if (errorMatches) {
            console.log(`✅ PASS: ${testCase.name}`);
            console.log(`   Expected error: ${result.body.error}`);
            passedTests++;
          } else {
            console.log(`❌ FAIL: ${testCase.name}`);
            console.log(`   Expected error containing "${testCase.expectedError}" but got: ${result.body.error}`);
          }
        } else {
          console.log(`❌ FAIL: ${testCase.name}`);
          console.log(`   Expected failure but got success: ${JSON.stringify(result.body)}`);
        }
      }
    } catch (error) {
      if (!testCase.shouldSucceed) {
        console.log(`✅ PASS: ${testCase.name} (threw expected error)`);
        console.log(`   Error: ${error.message}`);
        passedTests++;
      } else {
        console.log(`❌ FAIL: ${testCase.name}`);
        console.log(`   Unexpected error: ${error.message}`);
      }
    }
    
    console.log(''); // Empty line for readability
  }
  
  console.log('==========================================');
  console.log(`📊 Test Results: ${passedTests}/${totalTests} tests passed`);
  console.log(`${passedTests === totalTests ? '🎉 All tests passed!' : '⚠️  Some tests failed'}`);
  
  return passedTests === totalTests;
}

// Validation tests (these don't require AWS)
function runValidationTests() {
  console.log('🔧 Running Validation Tests');
  console.log('============================\\n');
  
  // Test environment variable validation
  const originalBucket = process.env.S3_BUCKET_NAME;
  delete process.env.S3_BUCKET_NAME;
  
  try {
    operations.readFile('test.txt');
    console.log('❌ FAIL: Should throw error when S3_BUCKET_NAME is missing');
  } catch (error) {
    if (error.message.includes('S3_BUCKET_NAME environment variable is required')) {
      console.log('✅ PASS: Validates missing S3_BUCKET_NAME');
    } else {
      console.log(`❌ FAIL: Wrong error message: ${error.message}`);
    }
  }
  
  // Restore bucket name
  process.env.S3_BUCKET_NAME = originalBucket;
  
  // Test key validation
  try {
    operations.readFile('');
    console.log('❌ FAIL: Should throw error for empty key');
  } catch (error) {
    if (error.message.includes('Object key must be between 1 and 1024 characters')) {
      console.log('✅ PASS: Validates empty key');
    } else {
      console.log(`❌ FAIL: Wrong error message: ${error.message}`);
    }
  }
  
  // Test long key validation
  try {
    const longKey = 'a'.repeat(1025);
    operations.readFile(longKey);
    console.log('❌ FAIL: Should throw error for key too long');
  } catch (error) {
    if (error.message.includes('Object key must be between 1 and 1024 characters')) {
      console.log('✅ PASS: Validates key length');
    } else {
      console.log(`❌ FAIL: Wrong error message: ${error.message}`);
    }
  }
  
  console.log('\\n✅ Validation tests completed\\n');
}

// Main execution
async function main() {
  console.log('S3 File Resource Lambda - Test Suite');
  console.log('=====================================\\n');
  
  // Check if we're in a real AWS environment
  if (!process.env.S3_BUCKET_NAME || process.env.S3_BUCKET_NAME === 'test-bucket-name') {
    console.log('⚠️  NOTE: Running in test mode with mock bucket name.');
    console.log('   Real AWS operations will fail, but the function logic will be tested.\\n');
  }
  
  // Run validation tests first (these don't need AWS)
  runValidationTests();
  
  // Run integration tests (these will fail without real AWS resources)
  const success = await runTests();
  
  console.log('\\n📝 Notes:');
  console.log('- Tests that interact with AWS will fail without proper AWS credentials and S3 bucket');
  console.log('- Set S3_BUCKET_NAME environment variable to a real bucket for full testing');
  console.log('- Ensure AWS credentials are configured (AWS CLI, IAM role, or environment variables)');
  
  process.exit(success ? 0 : 1);
}

// Run tests if this file is executed directly
if (require.main === module) {
  main().catch(error => {
    console.error('Test execution failed:', error);
    process.exit(1);
  });
}

module.exports = { runTests, runValidationTests };