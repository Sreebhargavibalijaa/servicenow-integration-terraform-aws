output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "lambda_error_rate_alarms" {
  description = "Map of Lambda error rate alarms"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.lambda_error_rate : k => v
  }
}

output "lambda_duration_alarms" {
  description = "Map of Lambda duration alarms"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.lambda_duration : k => v
  }
}

output "api_gateway_4xx_errors_alarm" {
  description = "API Gateway 4XX errors alarm"
  value       = aws_cloudwatch_metric_alarm.api_gateway_4xx_errors
}

output "api_gateway_5xx_errors_alarm" {
  description = "API Gateway 5XX errors alarm"
  value       = aws_cloudwatch_metric_alarm.api_gateway_5xx_errors
}

output "dynamodb_throttled_requests_alarms" {
  description = "Map of DynamoDB throttled requests alarms"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.dynamodb_throttled_requests : k => v
  }
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.name
}

output "alarm_names" {
  description = "Names of all CloudWatch alarms"
  value = concat(
    [for k, v in aws_cloudwatch_metric_alarm.lambda_error_rate : v.alarm_name],
    [for k, v in aws_cloudwatch_metric_alarm.lambda_duration : v.alarm_name],
    [aws_cloudwatch_metric_alarm.api_gateway_4xx_errors.alarm_name],
    [aws_cloudwatch_metric_alarm.api_gateway_5xx_errors.alarm_name],
    [for k, v in aws_cloudwatch_metric_alarm.dynamodb_throttled_requests : v.alarm_name]
  )
} 