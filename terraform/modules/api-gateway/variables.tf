variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "api_gateway_description" {
  description = "Description for API Gateway"
  type        = string
  default     = "ServiceNow Integration API Gateway"
}

variable "lambda_functions" {
  description = "Map of Lambda functions"
  type        = map(any)
}

variable "api_gateway_role_arn" {
  description = "ARN of the API Gateway role"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
} 