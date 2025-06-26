const AWS = require('aws-sdk');
const https = require('https');
const { v4: uuidv4 } = require('uuid');

// Initialize AWS services
const dynamodb = new AWS.DynamoDB.DocumentClient();
const secretsManager = new AWS.SecretsManager();

// Environment variables
const ENVIRONMENT = process.env.ENVIRONMENT;
const PROJECT_NAME = process.env.PROJECT_NAME;
const SERVICENOW_CREDENTIALS_SECRET = process.env.SERVICENOW_CREDENTIALS_SECRET;
const INCIDENTS_TABLE_NAME = process.env.INCIDENTS_TABLE_NAME;
const API_LOGS_TABLE_NAME = process.env.API_LOGS_TABLE_NAME;
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

// Get ServiceNow credentials from Secrets Manager
async function getServiceNowCredentials() {
  try {
    const secretData = await secretsManager.getSecretValue({ SecretId: SERVICENOW_CREDENTIALS_SECRET }).promise();
    return JSON.parse(secretData.SecretString);
  } catch (error) {
    logger.error('Failed to get ServiceNow credentials', error);
    throw new Error('Unable to retrieve ServiceNow credentials');
  }
}

// Make HTTP request to ServiceNow
function makeServiceNowRequest(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const parsedData = JSON.parse(responseData);
          resolve({
            statusCode: res.statusCode,
            data: parsedData
          });
        } catch (error) {
          resolve({
            statusCode: res.statusCode,
            data: responseData
          });
        }
      });
    });
    
    req.on('error', (error) => {
      reject(error);
    });
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

// Log API request to DynamoDB
async function logApiRequest(requestId, endpoint, method, statusCode, responseTime, error = null) {
  try {
    const logItem = {
      request_id: requestId,
      timestamp: new Date().toISOString(),
      endpoint,
      method,
      status_code: statusCode.toString(),
      response_time: responseTime,
      environment: ENVIRONMENT,
      project_name: PROJECT_NAME,
      error: error ? error.message : null
    };
    
    await dynamodb.put({
      TableName: API_LOGS_TABLE_NAME,
      Item: logItem
    }).promise();
    
    logger.debug('API request logged', { requestId, endpoint, statusCode });
  } catch (error) {
    logger.error('Failed to log API request', error);
  }
}

// Get incidents from ServiceNow
async function getIncidents(credentials, queryParams = {}) {
  const startTime = Date.now();
  const requestId = uuidv4();
  
  try {
    const queryString = new URLSearchParams(queryParams).toString();
    const url = `${credentials.instance_url}/api/now/table/incident${queryString ? '?' + queryString : ''}`;
    
    const options = {
      hostname: new URL(credentials.instance_url).hostname,
      port: 443,
      path: `/api/now/table/incident${queryString ? '?' + queryString : ''}`,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${Buffer.from(`${credentials.username}:${credentials.password}`).toString('base64')}`
      }
    };
    
    logger.info('Fetching incidents from ServiceNow', { requestId, url });
    
    const response = await makeServiceNowRequest(options);
    
    const responseTime = Date.now() - startTime;
    await logApiRequest(requestId, '/api/now/table/incident', 'GET', response.statusCode, responseTime);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Store incidents in DynamoDB
      if (response.data.result && Array.isArray(response.data.result)) {
        for (const incident of response.data.result) {
          await storeIncident(incident);
        }
      }
      
      return {
        statusCode: 200,
        body: JSON.stringify({
          success: true,
          data: response.data.result || [],
          count: response.data.result ? response.data.result.length : 0
        })
      };
    } else {
      throw new Error(`ServiceNow API returned status ${response.statusCode}: ${JSON.stringify(response.data)}`);
    }
  } catch (error) {
    const responseTime = Date.now() - startTime;
    await logApiRequest(requestId, '/api/now/table/incident', 'GET', 500, responseTime, error);
    
    logger.error('Failed to get incidents', error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        success: false,
        error: 'Failed to retrieve incidents from ServiceNow',
        details: error.message
      })
    };
  }
}

// Create incident in ServiceNow
async function createIncident(credentials, incidentData) {
  const startTime = Date.now();
  const requestId = uuidv4();
  
  try {
    const options = {
      hostname: new URL(credentials.instance_url).hostname,
      port: 443,
      path: '/api/now/table/incident',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${Buffer.from(`${credentials.username}:${credentials.password}`).toString('base64')}`
      }
    };
    
    logger.info('Creating incident in ServiceNow', { requestId, incidentData });
    
    const response = await makeServiceNowRequest(options, incidentData);
    
    const responseTime = Date.now() - startTime;
    await logApiRequest(requestId, '/api/now/table/incident', 'POST', response.statusCode, responseTime);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Store incident in DynamoDB
      await storeIncident(response.data.result);
      
      return {
        statusCode: 201,
        body: JSON.stringify({
          success: true,
          data: response.data.result
        })
      };
    } else {
      throw new Error(`ServiceNow API returned status ${response.statusCode}: ${JSON.stringify(response.data)}`);
    }
  } catch (error) {
    const responseTime = Date.now() - startTime;
    await logApiRequest(requestId, '/api/now/table/incident', 'POST', 500, responseTime, error);
    
    logger.error('Failed to create incident', error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        success: false,
        error: 'Failed to create incident in ServiceNow',
        details: error.message
      })
    };
  }
}

// Get specific incident from ServiceNow
async function getIncident(credentials, incidentId) {
  const startTime = Date.now();
  const requestId = uuidv4();
  
  try {
    const options = {
      hostname: new URL(credentials.instance_url).hostname,
      port: 443,
      path: `/api/now/table/incident/${incidentId}`,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${Buffer.from(`${credentials.username}:${credentials.password}`).toString('base64')}`
      }
    };
    
    logger.info('Fetching incident from ServiceNow', { requestId, incidentId });
    
    const response = await makeServiceNowRequest(options);
    
    const responseTime = Date.now() - startTime;
    await logApiRequest(requestId, `/api/now/table/incident/${incidentId}`, 'GET', response.statusCode, responseTime);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Store incident in DynamoDB
      await storeIncident(response.data.result);
      
      return {
        statusCode: 200,
        body: JSON.stringify({
          success: true,
          data: response.data.result
        })
      };
    } else if (response.statusCode === 404) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          success: false,
          error: 'Incident not found'
        })
      };
    } else {
      throw new Error(`ServiceNow API returned status ${response.statusCode}: ${JSON.stringify(response.data)}`);
    }
  } catch (error) {
    const responseTime = Date.now() - startTime;
    await logApiRequest(requestId, `/api/now/table/incident/${incidentId}`, 'GET', 500, responseTime, error);
    
    logger.error('Failed to get incident', error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        success: false,
        error: 'Failed to retrieve incident from ServiceNow',
        details: error.message
      })
    };
  }
}

// Update incident in ServiceNow
async function updateIncident(credentials, incidentId, updateData) {
  const startTime = Date.now();
  const requestId = uuidv4();
  
  try {
    const options = {
      hostname: new URL(credentials.instance_url).hostname,
      port: 443,
      path: `/api/now/table/incident/${incidentId}`,
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${Buffer.from(`${credentials.username}:${credentials.password}`).toString('base64')}`
      }
    };
    
    logger.info('Updating incident in ServiceNow', { requestId, incidentId, updateData });
    
    const response = await makeServiceNowRequest(options, updateData);
    
    const responseTime = Date.now() - startTime;
    await logApiRequest(requestId, `/api/now/table/incident/${incidentId}`, 'PUT', response.statusCode, responseTime);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Store updated incident in DynamoDB
      await storeIncident(response.data.result);
      
      return {
        statusCode: 200,
        body: JSON.stringify({
          success: true,
          data: response.data.result
        })
      };
    } else if (response.statusCode === 404) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          success: false,
          error: 'Incident not found'
        })
      };
    } else {
      throw new Error(`ServiceNow API returned status ${response.statusCode}: ${JSON.stringify(response.data)}`);
    }
  } catch (error) {
    const responseTime = Date.now() - startTime;
    await logApiRequest(requestId, `/api/now/table/incident/${incidentId}`, 'PUT', 500, responseTime, error);
    
    logger.error('Failed to update incident', error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        success: false,
        error: 'Failed to update incident in ServiceNow',
        details: error.message
      })
    };
  }
}

// Store incident in DynamoDB
async function storeIncident(incident) {
  try {
    const incidentItem = {
      incident_id: incident.sys_id,
      created_at: incident.sys_created_on,
      updated_at: incident.sys_updated_on,
      number: incident.number,
      short_description: incident.short_description,
      description: incident.description,
      priority: incident.priority,
      impact: incident.impact,
      urgency: incident.urgency,
      state: incident.state,
      assigned_to: incident.assigned_to,
      category: incident.category,
      subcategory: incident.subcategory,
      caller_id: incident.caller_id,
      opened_by: incident.opened_by,
      closed_at: incident.closed_at,
      resolved_at: incident.resolved_at,
      environment: ENVIRONMENT,
      project_name: PROJECT_NAME
    };
    
    await dynamodb.put({
      TableName: INCIDENTS_TABLE_NAME,
      Item: incidentItem
    }).promise();
    
    logger.debug('Incident stored in DynamoDB', { incidentId: incident.sys_id });
  } catch (error) {
    logger.error('Failed to store incident in DynamoDB', error);
  }
}

// Main Lambda handler
exports.handler = async (event, context) => {
  logger.info('Lambda function invoked', { 
    functionName: context.functionName,
    requestId: context.awsRequestId,
    event: event
  });
  
  try {
    const credentials = await getServiceNowCredentials();
    
    // Parse the HTTP method and path
    const httpMethod = event.httpMethod;
    const path = event.path;
    const pathParameters = event.pathParameters || {};
    const queryStringParameters = event.queryStringParameters || {};
    const body = event.body ? JSON.parse(event.body) : {};
    
    logger.info('Processing request', { httpMethod, path, pathParameters, queryStringParameters });
    
    let response;
    
    switch (httpMethod) {
      case 'GET':
        if (pathParameters.id) {
          // GET /incidents/{id}
          response = await getIncident(credentials, pathParameters.id);
        } else {
          // GET /incidents
          response = await getIncidents(credentials, queryStringParameters);
        }
        break;
        
      case 'POST':
        // POST /incidents
        response = await createIncident(credentials, body);
        break;
        
      case 'PUT':
        if (pathParameters.id) {
          // PUT /incidents/{id}
          response = await updateIncident(credentials, pathParameters.id, body);
        } else {
          response = {
            statusCode: 400,
            body: JSON.stringify({
              success: false,
              error: 'Incident ID is required for updates'
            })
          };
        }
        break;
        
      default:
        response = {
          statusCode: 405,
          body: JSON.stringify({
            success: false,
            error: 'Method not allowed'
          })
        };
    }
    
    // Add CORS headers
    response.headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
      'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
    };
    
    logger.info('Request completed successfully', { 
      statusCode: response.statusCode,
      requestId: context.awsRequestId
    });
    
    return response;
    
  } catch (error) {
    logger.error('Lambda function failed', error);
    
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        success: false,
        error: 'Internal server error',
        details: error.message
      })
    };
  }
}; 