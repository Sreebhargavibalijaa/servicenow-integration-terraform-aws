terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Terraform Cloud backend configuration
  cloud {
    organization = var.tf_organization
    workspaces {
      name = var.tf_workspace
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = "${var.project_name}-vpc"
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment          = var.environment
}

# IAM Roles and Policies
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  account_id   = data.aws_caller_identity.current.account_id
}

# DynamoDB Tables
module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment
}

# Secrets Manager
module "secrets" {
  source = "./modules/secrets"

  project_name = var.project_name
  environment  = var.environment
}

# Lambda Functions
module "lambda" {
  source = "./modules/lambda"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  lambda_role_arn     = module.iam.lambda_role_arn
  secrets_arn         = module.secrets.secrets_arn
  dynamodb_table_arns = module.dynamodb.table_arns

  depends_on = [
    module.vpc,
    module.iam,
    module.secrets,
    module.dynamodb
  ]
}

# API Gateway
module "api_gateway" {
  source = "./modules/api-gateway"

  project_name     = var.project_name
  environment      = var.environment
  lambda_functions = module.lambda.functions
  api_gateway_role_arn = module.iam.api_gateway_role_arn
}

# CloudWatch Monitoring
module "monitoring" {
  source = "./modules/monitoring"

  project_name    = var.project_name
  environment     = var.environment
  lambda_functions = module.lambda.functions
  api_gateway_id  = module.api_gateway.api_gateway_id
  dynamodb_tables = module.dynamodb.tables

  depends_on = [
    module.lambda,
    module.api_gateway,
    module.dynamodb
  ]
}

# Outputs
output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_gateway_url
}

output "lambda_functions" {
  description = "Lambda function ARNs"
  value       = module.lambda.function_arns
}

output "dynamodb_tables" {
  description = "DynamoDB table names"
  value       = module.dynamodb.table_names
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log group names"
  value       = module.monitoring.log_group_names
} 