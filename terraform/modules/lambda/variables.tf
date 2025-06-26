variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Lambda functions"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Lambda functions"
  type        = list(string)
}

variable "lambda_security_group_id" {
  description = "Security group ID for Lambda functions"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
}

variable "log_level" {
  description = "Log level for Lambda functions"
  type        = string
  default     = "INFO"
  validation {
    condition     = contains(["DEBUG", "INFO", "WARN", "ERROR"], var.log_level)
    error_message = "Log level must be one of: DEBUG, INFO, WARN, ERROR."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "servicenow_credentials_secret_name" {
  description = "Name of the ServiceNow credentials secret"
  type        = string
}

variable "slack_webhook_secret_name" {
  description = "Name of the Slack webhook secret"
  type        = string
}

variable "email_config_secret_name" {
  description = "Name of the email configuration secret"
  type        = string
}

variable "incidents_table_name" {
  description = "Name of the incidents DynamoDB table"
  type        = string
}

variable "changes_table_name" {
  description = "Name of the changes DynamoDB table"
  type        = string
}

variable "users_table_name" {
  description = "Name of the users DynamoDB table"
  type        = string
}

variable "api_logs_table_name" {
  description = "Name of the API logs DynamoDB table"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 