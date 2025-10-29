variable "aws_region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "us-east-2"
}

variable "alert_email" {
  description = "Email address to receive sensor alerts"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.alert_email))
    error_message = "The alert_email must be a valid email address."
  }
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "iot-sensor-alert"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "lambda_timeout" {
  description = "Timeout for Lambda functions in seconds"
  type        = number
  default     = 30
  validation {
    condition     = var.lambda_timeout >= 3 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 3 and 900 seconds."
  }
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda functions in MB"
  type        = number
  default     = 128
  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory size must be between 128 and 10240 MB."
  }
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.dynamodb_billing_mode)
    error_message = "DynamoDB billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB table"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 14
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "temperature_high_threshold" {
  description = "High temperature threshold in Celsius"
  type        = number
  default     = 30
}

variable "temperature_low_threshold" {
  description = "Low temperature threshold in Celsius"
  type        = number
  default     = 10
}

variable "humidity_high_threshold" {
  description = "High humidity threshold in percentage"
  type        = number
  default     = 80
  validation {
    condition     = var.humidity_high_threshold >= 0 && var.humidity_high_threshold <= 100
    error_message = "Humidity threshold must be between 0 and 100."
  }
}

variable "humidity_low_threshold" {
  description = "Low humidity threshold in percentage"
  type        = number
  default     = 20
  validation {
    condition     = var.humidity_low_threshold >= 0 && var.humidity_low_threshold <= 100
    error_message = "Humidity threshold must be between 0 and 100."
  }
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "IoT Sensor Alert System"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}