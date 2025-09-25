const { 
  S3Client, 
  GetObjectCommand, 
  PutObjectCommand, 
  DeleteObjectCommand, 
  ListObjectsV2Command,
  HeadObjectCommand 
} = require('@aws-sdk/client-s3');

// Environment variables configuration
const {
  S3_BUCKET_NAME,
  AWS_REGION = 'us-east-1',
  LOG_LEVEL = 'INFO'
} = process.env;

// Initialize S3 client
const s3Client = new S3Client({ 
  region: AWS_REGION,
  // Additional configuration can be added here
});

// Logging utility
const log = (level, message, data = null) => {
  const logLevels = { ERROR: 0, WARN: 1, INFO: 2, DEBUG: 3 };
  const currentLevel = logLevels[LOG_LEVEL] || 2;
  
  if (logLevels[level] <= currentLevel) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      ...(data && { data })
    };
    console.log(JSON.stringify(logEntry));
  }
};

// Validation utility
const validateBucketName = () => {
  if (!S3_BUCKET_NAME) {
    throw new Error('S3_BUCKET_NAME environment variable is required');
  }
  return S3_BUCKET_NAME;
};

const validateKey = (key) => {
  if (!key || typeof key !== 'string') {
    throw new Error('Object key is required and must be a string');
  }
  if (key.length === 0 || key.length > 1024) {
    throw new Error('Object key must be between 1 and 1024 characters');
  }
  return key;
};

// S3 Operations
const operations = {
  
  /**
   * Read a file from S3
   * @param {string} key - S3 object key
   * @param {string} encoding - Optional encoding (default: utf8)
   * @returns {Promise<Object>} File content and metadata
   */
  async readFile(key, encoding = 'utf8') {
    const bucketName = validateBucketName();
    const validKey = validateKey(key);
    
    log('INFO', 'Reading file from S3', { bucket: bucketName, key: validKey });
    
    try {
      const command = new GetObjectCommand({
        Bucket: bucketName,
        Key: validKey
      });
      
      const response = await s3Client.send(command);
      
      // Convert stream to string/buffer
      const chunks = [];
      for await (const chunk of response.Body) {
        chunks.push(chunk);
      }
      const buffer = Buffer.concat(chunks);
      
      const result = {
        content: encoding === 'binary' ? buffer : buffer.toString(encoding),
        contentType: response.ContentType,
        lastModified: response.LastModified,
        contentLength: response.ContentLength,
        etag: response.ETag,
        metadata: response.Metadata || {}
      };
      
      log('INFO', 'Successfully read file from S3', { key: validKey, size: result.contentLength });
      return result;
      
    } catch (error) {
      log('ERROR', 'Failed to read file from S3', { key: validKey, error: error.message });
      throw error;
    }
  },

  /**
   * Write a file to S3
   * @param {string} key - S3 object key
   * @param {string|Buffer} content - File content
   * @param {Object} options - Additional options
   * @returns {Promise<Object>} Upload result
   */
  async writeFile(key, content, options = {}) {
    const bucketName = validateBucketName();
    const validKey = validateKey(key);
    
    if (!content && content !== '') {
      throw new Error('Content is required');
    }
    
    log('INFO', 'Writing file to S3', { bucket: bucketName, key: validKey });
    
    try {
      const command = new PutObjectCommand({
        Bucket: bucketName,
        Key: validKey,
        Body: content,
        ContentType: options.contentType || 'application/octet-stream',
        Metadata: options.metadata || {},
        ...(options.acl && { ACL: options.acl }),
        ...(options.cacheControl && { CacheControl: options.cacheControl }),
        ...(options.expires && { Expires: options.expires }),
        ...(options.storageClass && { StorageClass: options.storageClass })
      });
      
      const response = await s3Client.send(command);
      
      const result = {
        etag: response.ETag,
        location: `s3://${bucketName}/${validKey}`,
        key: validKey,
        bucket: bucketName
      };
      
      log('INFO', 'Successfully wrote file to S3', result);
      return result;
      
    } catch (error) {
      log('ERROR', 'Failed to write file to S3', { key: validKey, error: error.message });
      throw error;
    }
  },

  /**
   * List files in S3 bucket
   * @param {Object} options - List options
   * @returns {Promise<Object>} List of objects
   */
  async listFiles(options = {}) {
    const bucketName = validateBucketName();
    const {
      prefix = '',
      maxKeys = 1000,
      continuationToken = null,
      delimiter = null
    } = options;
    
    log('INFO', 'Listing files in S3', { bucket: bucketName, prefix, maxKeys });
    
    try {
      const command = new ListObjectsV2Command({
        Bucket: bucketName,
        Prefix: prefix,
        MaxKeys: Math.min(maxKeys, 1000), // AWS limit is 1000
        ...(continuationToken && { ContinuationToken: continuationToken }),
        ...(delimiter && { Delimiter: delimiter })
      });
      
      const response = await s3Client.send(command);
      
      const result = {
        files: (response.Contents || []).map(obj => ({
          key: obj.Key,
          lastModified: obj.LastModified,
          etag: obj.ETag,
          size: obj.Size,
          storageClass: obj.StorageClass
        })),
        commonPrefixes: (response.CommonPrefixes || []).map(cp => cp.Prefix),
        isTruncated: response.IsTruncated || false,
        keyCount: response.KeyCount || 0,
        maxKeys: response.MaxKeys,
        ...(response.NextContinuationToken && { nextContinuationToken: response.NextContinuationToken })
      };
      
      log('INFO', 'Successfully listed files in S3', { 
        bucket: bucketName, 
        count: result.keyCount,
        isTruncated: result.isTruncated
      });
      return result;
      
    } catch (error) {
      log('ERROR', 'Failed to list files in S3', { bucket: bucketName, error: error.message });
      throw error;
    }
  },

  /**
   * Delete a file from S3
   * @param {string} key - S3 object key
   * @returns {Promise<Object>} Delete result
   */
  async deleteFile(key) {
    const bucketName = validateBucketName();
    const validKey = validateKey(key);
    
    log('INFO', 'Deleting file from S3', { bucket: bucketName, key: validKey });
    
    try {
      const command = new DeleteObjectCommand({
        Bucket: bucketName,
        Key: validKey
      });
      
      const response = await s3Client.send(command);
      
      const result = {
        deleted: true,
        key: validKey,
        bucket: bucketName,
        ...(response.DeleteMarker && { deleteMarker: response.DeleteMarker }),
        ...(response.VersionId && { versionId: response.VersionId })
      };
      
      log('INFO', 'Successfully deleted file from S3', result);
      return result;
      
    } catch (error) {
      log('ERROR', 'Failed to delete file from S3', { key: validKey, error: error.message });
      throw error;
    }
  },

  /**
   * Check if a file exists in S3
   * @param {string} key - S3 object key
   * @returns {Promise<Object>} File metadata if exists, null if not
   */
  async fileExists(key) {
    const bucketName = validateBucketName();
    const validKey = validateKey(key);
    
    log('DEBUG', 'Checking if file exists in S3', { bucket: bucketName, key: validKey });
    
    try {
      const command = new HeadObjectCommand({
        Bucket: bucketName,
        Key: validKey
      });
      
      const response = await s3Client.send(command);
      
      const result = {
        exists: true,
        contentType: response.ContentType,
        contentLength: response.ContentLength,
        lastModified: response.LastModified,
        etag: response.ETag,
        metadata: response.Metadata || {}
      };
      
      log('DEBUG', 'File exists in S3', { key: validKey, size: result.contentLength });
      return result;
      
    } catch (error) {
      if (error.name === 'NoSuchKey' || error.name === 'NotFound') {
        log('DEBUG', 'File does not exist in S3', { key: validKey });
        return { exists: false };
      }
      
      log('ERROR', 'Failed to check file existence in S3', { key: validKey, error: error.message });
      throw error;
    }
  }
};

// Lambda handler
exports.handler = async (event, context) => {
  log('INFO', 'Lambda function started', { 
    requestId: context.awsRequestId,
    operation: event.operation 
  });
  
  try {
    // Validate required parameters
    if (!event.operation) {
      throw new Error('Operation is required. Valid operations: read, write, list, delete, exists');
    }
    
    const { operation, key, content, options = {}, encoding } = event;
    
    let result;
    
    switch (operation.toLowerCase()) {
      case 'read':
        if (!key) throw new Error('Key is required for read operation');
        result = await operations.readFile(key, encoding);
        break;
        
      case 'write':
        if (!key) throw new Error('Key is required for write operation');
        if (content === undefined || content === null) throw new Error('Content is required for write operation');
        result = await operations.writeFile(key, content, options);
        break;
        
      case 'list':
        result = await operations.listFiles(options);
        break;
        
      case 'delete':
        if (!key) throw new Error('Key is required for delete operation');
        result = await operations.deleteFile(key);
        break;
        
      case 'exists':
        if (!key) throw new Error('Key is required for exists operation');
        result = await operations.fileExists(key);
        break;
        
      default:
        throw new Error(`Invalid operation: ${operation}. Valid operations: read, write, list, delete, exists`);
    }
    
    const response = {
      statusCode: 200,
      body: {
        success: true,
        operation,
        result,
        timestamp: new Date().toISOString()
      }
    };
    
    log('INFO', 'Lambda function completed successfully', { 
      operation,
      requestId: context.awsRequestId 
    });
    
    return response;
    
  } catch (error) {
    log('ERROR', 'Lambda function failed', {
      error: error.message,
      stack: error.stack,
      requestId: context.awsRequestId
    });
    
    return {
      statusCode: error.statusCode || 500,
      body: {
        success: false,
        error: error.message,
        operation: event.operation || 'unknown',
        timestamp: new Date().toISOString()
      }
    };
  }
};

// Export operations for testing
exports.operations = operations;