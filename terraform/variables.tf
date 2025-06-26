# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "servicenow-integration"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "devops-team"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

# Terraform Cloud Configuration
variable "tf_organization" {
  description = "Terraform Cloud organization name"
  type        = string
  default     = "your-organization"
}

variable "tf_workspace" {
  description = "Terraform Cloud workspace name"
  type        = string
  default     = "servicenow-integration-dev"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

# Lambda Configuration
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

# API Gateway Configuration
variable "api_gateway_name" {
  description = "Name for API Gateway"
  type        = string
  default     = "servicenow-api"
}

variable "api_gateway_description" {
  description = "Description for API Gateway"
  type        = string
  default     = "ServiceNow Integration API Gateway"
}

# DynamoDB Configuration
variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.dynamodb_billing_mode)
    error_message = "DynamoDB billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

# Monitoring Configuration
variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = true
}

variable "alarm_threshold_error_rate" {
  description = "Error rate threshold for alarms (percentage)"
  type        = number
  default     = 5.0
}

variable "alarm_threshold_latency" {
  description = "Latency threshold for alarms (milliseconds)"
  type        = number
  default     = 5000
}

# ServiceNow Configuration
variable "servicenow_instance_url" {
  description = "ServiceNow instance URL"
  type        = string
  default     = ""
  sensitive   = true
}

variable "servicenow_client_id" {
  description = "ServiceNow OAuth client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "servicenow_client_secret" {
  description = "ServiceNow OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

# Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "servicenow-integration"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "devops-team"
  }
} 