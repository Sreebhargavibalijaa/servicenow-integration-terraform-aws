variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "secrets_arn" {
  description = "ARN of the secrets in Secrets Manager"
  type        = string
  default     = ""
}

variable "dynamodb_table_arns" {
  description = "ARNs of DynamoDB tables"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 