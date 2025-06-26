variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_functions" {
  description = "Map of Lambda functions"
  type        = map(any)
}

variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "dynamodb_tables" {
  description = "Map of DynamoDB tables"
  type        = map(any)
}

variable "lambda_log_group_names" {
  description = "Names of Lambda CloudWatch log groups"
  type        = list(string)
}

variable "lambda_duration_threshold" {
  description = "Threshold for Lambda duration alarm in milliseconds"
  type        = number
  default     = 30000
}

variable "alarm_actions" {
  description = "List of ARNs for alarm actions (SNS topics, etc.)"
  type        = list(string)
  default     = []
}

variable "alarm_email_addresses" {
  description = "List of email addresses to receive alarm notifications"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 