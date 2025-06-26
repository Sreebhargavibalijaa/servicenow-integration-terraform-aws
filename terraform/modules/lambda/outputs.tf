output "incidents_function_name" {
  description = "Name of the incidents Lambda function"
  value       = aws_lambda_function.incidents.function_name
}

output "incidents_function_arn" {
  description = "ARN of the incidents Lambda function"
  value       = aws_lambda_function.incidents.arn
}

output "incidents_invoke_arn" {
  description = "Invoke ARN of the incidents Lambda function"
  value       = aws_lambda_function.incidents.invoke_arn
}

output "changes_function_name" {
  description = "Name of the changes Lambda function"
  value       = aws_lambda_function.changes.function_name
}

output "changes_function_arn" {
  description = "ARN of the changes Lambda function"
  value       = aws_lambda_function.changes.arn
}

output "changes_invoke_arn" {
  description = "Invoke ARN of the changes Lambda function"
  value       = aws_lambda_function.changes.invoke_arn
}

output "users_function_name" {
  description = "Name of the users Lambda function"
  value       = aws_lambda_function.users.function_name
}

output "users_function_arn" {
  description = "ARN of the users Lambda function"
  value       = aws_lambda_function.users.arn
}

output "users_invoke_arn" {
  description = "Invoke ARN of the users Lambda function"
  value       = aws_lambda_function.users.invoke_arn
}

output "health_function_name" {
  description = "Name of the health Lambda function"
  value       = aws_lambda_function.health.function_name
}

output "health_function_arn" {
  description = "ARN of the health Lambda function"
  value       = aws_lambda_function.health.arn
}

output "health_invoke_arn" {
  description = "Invoke ARN of the health Lambda function"
  value       = aws_lambda_function.health.invoke_arn
}

output "notifications_function_name" {
  description = "Name of the notifications Lambda function"
  value       = aws_lambda_function.notifications.function_name
}

output "notifications_function_arn" {
  description = "ARN of the notifications Lambda function"
  value       = aws_lambda_function.notifications.arn
}

output "notifications_invoke_arn" {
  description = "Invoke ARN of the notifications Lambda function"
  value       = aws_lambda_function.notifications.invoke_arn
}

output "function_names" {
  description = "Names of all Lambda functions"
  value = [
    aws_lambda_function.incidents.function_name,
    aws_lambda_function.changes.function_name,
    aws_lambda_function.users.function_name,
    aws_lambda_function.health.function_name,
    aws_lambda_function.notifications.function_name
  ]
}

output "function_arns" {
  description = "ARNs of all Lambda functions"
  value = [
    aws_lambda_function.incidents.arn,
    aws_lambda_function.changes.arn,
    aws_lambda_function.users.arn,
    aws_lambda_function.health.arn,
    aws_lambda_function.notifications.arn
  ]
}

output "functions" {
  description = "Map of function names to function objects"
  value = {
    incidents     = aws_lambda_function.incidents
    changes       = aws_lambda_function.changes
    users         = aws_lambda_function.users
    health        = aws_lambda_function.health
    notifications = aws_lambda_function.notifications
  }
}

output "log_group_names" {
  description = "Names of all CloudWatch log groups"
  value = [
    aws_cloudwatch_log_group.incidents.name,
    aws_cloudwatch_log_group.changes.name,
    aws_cloudwatch_log_group.users.name,
    aws_cloudwatch_log_group.health.name,
    aws_cloudwatch_log_group.notifications.name
  ]
} 