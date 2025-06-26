output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda.arn
}

output "lambda_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda.name
}

output "api_gateway_role_arn" {
  description = "ARN of the API Gateway role"
  value       = aws_iam_role.api_gateway.arn
}

output "api_gateway_role_name" {
  description = "Name of the API Gateway role"
  value       = aws_iam_role.api_gateway.name
}

output "cloudwatch_role_arn" {
  description = "ARN of the CloudWatch role"
  value       = aws_iam_role.cloudwatch.arn
}

output "cloudwatch_role_name" {
  description = "Name of the CloudWatch role"
  value       = aws_iam_role.cloudwatch.name
}

output "lambda_servicenow_policy_arn" {
  description = "ARN of the Lambda ServiceNow policy"
  value       = aws_iam_policy.lambda_servicenow.arn
}

output "api_gateway_cloudwatch_policy_arn" {
  description = "ARN of the API Gateway CloudWatch policy"
  value       = aws_iam_policy.api_gateway_cloudwatch.arn
}

output "cloudwatch_policy_arn" {
  description = "ARN of the CloudWatch policy"
  value       = aws_iam_policy.cloudwatch.arn
} 