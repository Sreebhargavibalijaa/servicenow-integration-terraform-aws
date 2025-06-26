# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            for function_name, function in var.lambda_functions : [
              "AWS/Lambda",
              "Invocations",
              "FunctionName",
              function.function_name
            ]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Lambda Invocations"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            for function_name, function in var.lambda_functions : [
              "AWS/Lambda",
              "Duration",
              "FunctionName",
              function.function_name
            ]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "Lambda Duration"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            for function_name, function in var.lambda_functions : [
              "AWS/Lambda",
              "Errors",
              "FunctionName",
              function.function_name
            ]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Lambda Errors"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_gateway_name],
            [".", "4XXError", ".", "."],
            [".", "5XXError", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "API Gateway Requests"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            for table_name, table in var.dynamodb_tables : [
              "AWS/DynamoDB",
              "ConsumedReadCapacityUnits",
              "TableName",
              table.name
            ]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "DynamoDB Read Capacity"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            for table_name, table in var.dynamodb_tables : [
              "AWS/DynamoDB",
              "ConsumedWriteCapacityUnits",
              "TableName",
              table.name
            ]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "DynamoDB Write Capacity"
        }
      }
    ]
  })
}

# Lambda Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_error_rate" {
  for_each = var.lambda_functions

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Lambda function ${each.key} error rate is too high"
  alarm_actions       = var.alarm_actions

  dimensions = {
    FunctionName = each.value.function_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}-error-rate"
  })
}

# Lambda Duration Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  for_each = var.lambda_functions

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = var.lambda_duration_threshold
  alarm_description   = "Lambda function ${each.key} duration is too high"
  alarm_actions       = var.alarm_actions

  dimensions = {
    FunctionName = each.value.function_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}-duration"
  })
}

# API Gateway 4XX Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "api_gateway_4xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-api-gateway-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "API Gateway 4XX error rate is too high"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ApiName = var.api_gateway_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-api-gateway-4xx-errors"
  })
}

# API Gateway 5XX Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-api-gateway-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "API Gateway 5XX error rate is too high"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ApiName = var.api_gateway_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-api-gateway-5xx-errors"
  })
}

# DynamoDB Throttled Requests Alarm
resource "aws_cloudwatch_metric_alarm" "dynamodb_throttled_requests" {
  for_each = var.dynamodb_tables

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-throttled-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "DynamoDB table ${each.key} has throttled requests"
  alarm_actions       = var.alarm_actions

  dimensions = {
    TableName = each.value.name
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}-throttled-requests"
  })
}

# Custom Metrics for ServiceNow API Calls
resource "aws_cloudwatch_log_metric_filter" "servicenow_api_calls" {
  name           = "${var.project_name}-${var.environment}-servicenow-api-calls"
  pattern        = "[timestamp, level, message, ...]"
  log_group_name = var.lambda_log_group_names[0]

  metric_transformation {
    name      = "ServiceNowAPICalls"
    namespace = "ServiceNowIntegration"
    value     = "1"
  }
}

# Custom Metrics for ServiceNow API Errors
resource "aws_cloudwatch_log_metric_filter" "servicenow_api_errors" {
  name           = "${var.project_name}-${var.environment}-servicenow-api-errors"
  pattern        = "[timestamp, level=ERROR, message, ...]"
  log_group_name = var.lambda_log_group_names[0]

  metric_transformation {
    name      = "ServiceNowAPIErrors"
    namespace = "ServiceNowIntegration"
    value     = "1"
  }
}

# SNS Topic for Alarms
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-${var.environment}-alarms"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-alarms"
  })
}

# SNS Topic Subscription for Email
resource "aws_sns_topic_subscription" "email" {
  count     = length(var.alarm_email_addresses)
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email_addresses[count.index]
}

# Data source for current region
data "aws_region" "current" {} 