const AWS = require('aws-sdk');

// Environment variables
const ENVIRONMENT = process.env.ENVIRONMENT;
const PROJECT_NAME = process.env.PROJECT_NAME;
const LOG_LEVEL = process.env.LOG_LEVEL || 'INFO';

// Logger utility
const logger = {
  info: (message, data = {}) => {
    if (LOG_LEVEL === 'INFO' || LOG_LEVEL === 'DEBUG') {
      console.log(JSON.stringify({ level: 'INFO', message, ...data, timestamp: new Date().toISOString() }));
    }
  },
  error: (message, error = {}) => {
    console.error(JSON.stringify({ level: 'ERROR', message, error: error.message || error, timestamp: new Date().toISOString() }));
  },
  debug: (message, data = {}) => {
    if (LOG_LEVEL === 'DEBUG') {
      console.log(JSON.stringify({ level: 'DEBUG', message, ...data, timestamp: new Date().toISOString() }));
    }
  }
};

// Check AWS service connectivity
async function checkAWSServices() {
  const checks = {};
  
  try {
    // Check DynamoDB
    const dynamodb = new AWS.DynamoDB();
    await dynamodb.listTables().promise();
    checks.dynamodb = { status: 'healthy', message: 'DynamoDB connection successful' };
  } catch (error) {
    checks.dynamodb = { status: 'unhealthy', message: error.message };
  }
  
  try {
    // Check Secrets Manager
    const secretsManager = new AWS.SecretsManager();
    await secretsManager.listSecrets().promise();
    checks.secretsManager = { status: 'healthy', message: 'Secrets Manager connection successful' };
  } catch (error) {
    checks.secretsManager = { status: 'unhealthy', message: error.message };
  }
  
  try {
    // Check CloudWatch Logs
    const cloudwatchLogs = new AWS.CloudWatchLogs();
    await cloudwatchLogs.describeLogGroups().promise();
    checks.cloudwatchLogs = { status: 'healthy', message: 'CloudWatch Logs connection successful' };
  } catch (error) {
    checks.cloudwatchLogs = { status: 'unhealthy', message: error.message };
  }
  
  return checks;
}

// Get system information
function getSystemInfo() {
  return {
    environment: ENVIRONMENT,
    project: PROJECT_NAME,
    region: process.env.AWS_REGION || 'unknown',
    memory: process.env.AWS_LAMBDA_FUNCTION_MEMORY_SIZE || 'unknown',
    timeout: process.env.AWS_LAMBDA_FUNCTION_TIMEOUT || 'unknown',
    version: process.env.AWS_LAMBDA_FUNCTION_VERSION || 'unknown',
    runtime: process.env.AWS_EXECUTION_ENV || 'unknown',
    timestamp: new Date().toISOString()
  };
}

// Main Lambda handler
exports.handler = async (event, context) => {
  logger.info('Health check Lambda function invoked', { 
    functionName: context.functionName,
    requestId: context.awsRequestId,
    event: event
  });
  
  try {
    const startTime = Date.now();
    
    // Get system information
    const systemInfo = getSystemInfo();
    
    // Check AWS services
    const serviceChecks = await checkAWSServices();
    
    const responseTime = Date.now() - startTime;
    
    // Determine overall health status
    const allHealthy = Object.values(serviceChecks).every(check => check.status === 'healthy');
    const statusCode = allHealthy ? 200 : 503;
    
    const response = {
      statusCode: statusCode,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
        'Access-Control-Allow-Methods': 'GET,OPTIONS'
      },
      body: JSON.stringify({
        status: allHealthy ? 'healthy' : 'unhealthy',
        timestamp: new Date().toISOString(),
        responseTime: `${responseTime}ms`,
        system: systemInfo,
        services: serviceChecks,
        message: allHealthy ? 'All systems operational' : 'Some services are experiencing issues'
      })
    };
    
    logger.info('Health check completed', { 
      status: allHealthy ? 'healthy' : 'unhealthy',
      responseTime,
      requestId: context.awsRequestId
    });
    
    return response;
    
  } catch (error) {
    logger.error('Health check failed', error);
    
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        status: 'error',
        timestamp: new Date().toISOString(),
        error: 'Health check failed',
        details: error.message
      })
    };
  }
}; 