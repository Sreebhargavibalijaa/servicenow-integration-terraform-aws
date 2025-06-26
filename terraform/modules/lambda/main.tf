# Lambda function for ServiceNow incidents
resource "aws_lambda_function" "incidents" {
  filename         = data.archive_file.incidents_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-incidents"
  role            = var.lambda_role_arn
  handler         = "index.handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      ENVIRONMENT           = var.environment
      PROJECT_NAME          = var.project_name
      SERVICENOW_CREDENTIALS_SECRET = var.servicenow_credentials_secret_name
      INCIDENTS_TABLE_NAME  = var.incidents_table_name
      API_LOGS_TABLE_NAME   = var.api_logs_table_name
      LOG_LEVEL            = var.log_level
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-incidents"
  })
}

# Lambda function for ServiceNow changes
resource "aws_lambda_function" "changes" {
  filename         = data.archive_file.changes_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-changes"
  role            = var.lambda_role_arn
  handler         = "index.handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      ENVIRONMENT           = var.environment
      PROJECT_NAME          = var.project_name
      SERVICENOW_CREDENTIALS_SECRET = var.servicenow_credentials_secret_name
      CHANGES_TABLE_NAME    = var.changes_table_name
      API_LOGS_TABLE_NAME   = var.api_logs_table_name
      LOG_LEVEL            = var.log_level
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-changes"
  })
}

# Lambda function for ServiceNow users
resource "aws_lambda_function" "users" {
  filename         = data.archive_file.users_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-users"
  role            = var.lambda_role_arn
  handler         = "index.handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      ENVIRONMENT           = var.environment
      PROJECT_NAME          = var.project_name
      SERVICENOW_CREDENTIALS_SECRET = var.servicenow_credentials_secret_name
      USERS_TABLE_NAME      = var.users_table_name
      API_LOGS_TABLE_NAME   = var.api_logs_table_name
      LOG_LEVEL            = var.log_level
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-users"
  })
}

# Lambda function for health check
resource "aws_lambda_function" "health" {
  filename         = data.archive_file.health_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-health"
  role            = var.lambda_role_arn
  handler         = "index.handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  environment {
    variables = {
      ENVIRONMENT = var.environment
      PROJECT_NAME = var.project_name
      LOG_LEVEL   = var.log_level
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-health"
  })
}

# Lambda function for notifications
resource "aws_lambda_function" "notifications" {
  filename         = data.archive_file.notifications_zip.output_path
  function_name    = "${var.project_name}-${var.environment}-notifications"
  role            = var.lambda_role_arn
  handler         = "index.handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  environment {
    variables = {
      ENVIRONMENT           = var.environment
      PROJECT_NAME          = var.project_name
      SLACK_WEBHOOK_SECRET  = var.slack_webhook_secret_name
      EMAIL_CONFIG_SECRET   = var.email_config_secret_name
      LOG_LEVEL            = var.log_level
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-notifications"
  })
}

# Archive files for Lambda functions
data "archive_file" "incidents_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/lambda/servicenow-api/incidents"
  output_path = "${path.module}/../../dist/incidents.zip"
}

data "archive_file" "changes_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/lambda/servicenow-api/changes"
  output_path = "${path.module}/../../dist/changes.zip"
}

data "archive_file" "users_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/lambda/servicenow-api/users"
  output_path = "${path.module}/../../dist/users.zip"
}

data "archive_file" "health_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/lambda/health"
  output_path = "${path.module}/../../dist/health.zip"
}

data "archive_file" "notifications_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/lambda/notifications"
  output_path = "${path.module}/../../dist/notifications.zip"
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "incidents" {
  name              = "/aws/lambda/${aws_lambda_function.incidents.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-incidents-logs"
  })
}

resource "aws_cloudwatch_log_group" "changes" {
  name              = "/aws/lambda/${aws_lambda_function.changes.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-changes-logs"
  })
}

resource "aws_cloudwatch_log_group" "users" {
  name              = "/aws/lambda/${aws_lambda_function.users.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-users-logs"
  })
}

resource "aws_cloudwatch_log_group" "health" {
  name              = "/aws/lambda/${aws_lambda_function.health.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-health-logs"
  })
}

resource "aws_cloudwatch_log_group" "notifications" {
  name              = "/aws/lambda/${aws_lambda_function.notifications.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-notifications-logs"
  })
} 