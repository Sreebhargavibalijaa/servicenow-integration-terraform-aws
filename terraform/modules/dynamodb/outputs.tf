output "incidents_table_name" {
  description = "Name of the incidents table"
  value       = aws_dynamodb_table.incidents.name
}

output "incidents_table_arn" {
  description = "ARN of the incidents table"
  value       = aws_dynamodb_table.incidents.arn
}

output "changes_table_name" {
  description = "Name of the changes table"
  value       = aws_dynamodb_table.changes.name
}

output "changes_table_arn" {
  description = "ARN of the changes table"
  value       = aws_dynamodb_table.changes.arn
}

output "users_table_name" {
  description = "Name of the users table"
  value       = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  description = "ARN of the users table"
  value       = aws_dynamodb_table.users.arn
}

output "api_logs_table_name" {
  description = "Name of the API logs table"
  value       = aws_dynamodb_table.api_logs.name
}

output "api_logs_table_arn" {
  description = "ARN of the API logs table"
  value       = aws_dynamodb_table.api_logs.arn
}

output "table_names" {
  description = "Names of all DynamoDB tables"
  value = [
    aws_dynamodb_table.incidents.name,
    aws_dynamodb_table.changes.name,
    aws_dynamodb_table.users.name,
    aws_dynamodb_table.api_logs.name
  ]
}

output "table_arns" {
  description = "ARNs of all DynamoDB tables"
  value = [
    aws_dynamodb_table.incidents.arn,
    aws_dynamodb_table.changes.arn,
    aws_dynamodb_table.users.arn,
    aws_dynamodb_table.api_logs.arn
  ]
}

output "tables" {
  description = "Map of table names to table objects"
  value = {
    incidents = aws_dynamodb_table.incidents
    changes   = aws_dynamodb_table.changes
    users     = aws_dynamodb_table.users
    api_logs  = aws_dynamodb_table.api_logs
  }
} 