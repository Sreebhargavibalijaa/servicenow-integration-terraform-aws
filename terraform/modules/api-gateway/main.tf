# API Gateway REST API
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-${var.environment}-api"
  description = var.api_gateway_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-api"
  })
}

# API Gateway Resource for root
resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = ""
}

# API Gateway Resource for health
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "health"
}

# API Gateway Resource for incidents
resource "aws_api_gateway_resource" "incidents" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "incidents"
}

# API Gateway Resource for specific incident
resource "aws_api_gateway_resource" "incident" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.incidents.id
  path_part   = "{id}"
}

# API Gateway Resource for changes
resource "aws_api_gateway_resource" "changes" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "changes"
}

# API Gateway Resource for specific change
resource "aws_api_gateway_resource" "change" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.changes.id
  path_part   = "{id}"
}

# API Gateway Resource for users
resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "users"
}

# Lambda Integration for health endpoint
resource "aws_api_gateway_integration" "health" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_functions["health"].invoke_arn
}

# Lambda Integration for incidents GET
resource "aws_api_gateway_integration" "incidents_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.incidents.id
  http_method = aws_api_gateway_method.incidents_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_functions["incidents"].invoke_arn
}

# Lambda Integration for incidents POST
resource "aws_api_gateway_integration" "incidents_post" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.incidents.id
  http_method = aws_api_gateway_method.incidents_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_functions["incidents"].invoke_arn
}

# Lambda Integration for specific incident GET
resource "aws_api_gateway_integration" "incident_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.incident.id
  http_method = aws_api_gateway_method.incident_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_functions["incidents"].invoke_arn
}

# Lambda Integration for specific incident PUT
resource "aws_api_gateway_integration" "incident_put" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.incident.id
  http_method = aws_api_gateway_method.incident_put.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_functions["incidents"].invoke_arn
}

# Lambda Integration for changes GET
resource "aws_api_gateway_integration" "changes_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.changes.id
  http_method = aws_api_gateway_method.changes_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_functions["changes"].invoke_arn
}

# Lambda Integration for changes POST
resource "aws_api_gateway_integration" "changes_post" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.changes.id
  http_method = aws_api_gateway_method.changes_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_functions["changes"].invoke_arn
}

# Lambda Integration for specific change GET
resource "aws_api_gateway_integration" "change_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.change.id
  http_method = aws_api_gateway_method.change_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_functions["changes"].invoke_arn
}

# Lambda Integration for users GET
resource "aws_api_gateway_integration" "users_get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.users_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_functions["users"].invoke_arn
}

# API Gateway Methods
resource "aws_api_gateway_method" "health" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "incidents_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.incidents.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "incidents_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.incidents.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "incident_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.incident.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "incident_put" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.incident.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "changes_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.changes.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "changes_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.changes.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "change_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.change.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "users_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "GET"
  authorization = "NONE"
}

# Lambda Permissions
resource "aws_lambda_permission" "health" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions["health"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "incidents" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions["incidents"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "changes" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions["changes"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "users" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions["users"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    aws_api_gateway_integration.health,
    aws_api_gateway_integration.incidents_get,
    aws_api_gateway_integration.incidents_post,
    aws_api_gateway_integration.incident_get,
    aws_api_gateway_integration.incident_put,
    aws_api_gateway_integration.changes_get,
    aws_api_gateway_integration.changes_post,
    aws_api_gateway_integration.change_get,
    aws_api_gateway_integration.users_get,
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.environment

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-stage"
  })
}

# API Gateway CloudWatch Log Group
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${aws_api_gateway_rest_api.main.name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-api-gateway-logs"
  })
}

# API Gateway Account Settings
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = var.api_gateway_role_arn
}

# API Gateway Method Settings
resource "aws_api_gateway_method_settings" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    data_trace_enabled     = true
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
} 