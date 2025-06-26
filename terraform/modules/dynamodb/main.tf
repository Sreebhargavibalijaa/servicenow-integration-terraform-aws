# ServiceNow Incidents Table
resource "aws_dynamodb_table" "incidents" {
  name           = "${var.project_name}-${var.environment}-incidents"
  billing_mode   = var.billing_mode
  hash_key       = "incident_id"
  range_key      = "created_at"

  attribute {
    name = "incident_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "priority"
    type = "S"
  }

  attribute {
    name = "assigned_to"
    type = "S"
  }

  # Global Secondary Index for status queries
  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  # Global Secondary Index for priority queries
  global_secondary_index {
    name            = "PriorityIndex"
    hash_key        = "priority"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  # Global Secondary Index for assigned_to queries
  global_secondary_index {
    name            = "AssignedToIndex"
    hash_key        = "assigned_to"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-incidents"
  })
}

# ServiceNow Changes Table
resource "aws_dynamodb_table" "changes" {
  name           = "${var.project_name}-${var.environment}-changes"
  billing_mode   = var.billing_mode
  hash_key       = "change_id"
  range_key      = "created_at"

  attribute {
    name = "change_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  attribute {
    name = "state"
    type = "S"
  }

  attribute {
    name = "type"
    type = "S"
  }

  # Global Secondary Index for state queries
  global_secondary_index {
    name            = "StateIndex"
    hash_key        = "state"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  # Global Secondary Index for type queries
  global_secondary_index {
    name            = "TypeIndex"
    hash_key        = "type"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-changes"
  })
}

# ServiceNow Users Table
resource "aws_dynamodb_table" "users" {
  name           = "${var.project_name}-${var.environment}-users"
  billing_mode   = var.billing_mode
  hash_key       = "user_id"
  range_key      = "email"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "department"
    type = "S"
  }

  attribute {
    name = "active"
    type = "S"
  }

  # Global Secondary Index for department queries
  global_secondary_index {
    name            = "DepartmentIndex"
    hash_key        = "department"
    range_key       = "active"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-users"
  })
}

# API Request Logs Table
resource "aws_dynamodb_table" "api_logs" {
  name           = "${var.project_name}-${var.environment}-api-logs"
  billing_mode   = var.billing_mode
  hash_key       = "request_id"
  range_key      = "timestamp"

  attribute {
    name = "request_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "endpoint"
    type = "S"
  }

  attribute {
    name = "status_code"
    type = "S"
  }

  # Global Secondary Index for endpoint queries
  global_secondary_index {
    name            = "EndpointIndex"
    hash_key        = "endpoint"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  # Global Secondary Index for status code queries
  global_secondary_index {
    name            = "StatusCodeIndex"
    hash_key        = "status_code"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-api-logs"
  })
} 