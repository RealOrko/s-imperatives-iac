variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "The environment for resources (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "prefix" {
  description = "The prefix for resources."
  type        = string
  default     = "si-iac"
}

variable "domain_name" {
  description = "Custom domain name for the API Gateway (optional)."
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ACM certificate ARN for custom domain (required if domain_name is set)."
  type        = string
  default     = null
}

variable "stage_name" {
  description = "The stage name for the API Gateway deployment."
  type        = string
  default     = "$default"
}

variable "throttling_rate_limit" {
  description = "API throttling rate limit."
  type        = number
  default     = 100
}

variable "throttling_burst_limit" {
  description = "API throttling burst limit."
  type        = number
  default     = 50
}

variable "api_routes" {
  description = "Map of API routes and their configurations"
  type = map(object({
    integration_type    = string
    integration_method  = string
    lambda_function_key = string # Key to reference the lambda function from remote state
    routes = list(object({
      method = string
      path   = string
    }))
    timeout_milliseconds   = optional(number, 12000)
    payload_format_version = optional(string, "2.0")
    authorization_type     = optional(string, "CUSTOM")
    use_authorizer         = optional(bool, true)
  }))
  default = {
    s3_files = {
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      lambda_function_key    = "lambda_s3_files"
      timeout_milliseconds   = 12000
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      use_authorizer         = true
      routes = [
        {
          method = "GET"
          path   = "/s3-files"
        },
        {
          method = "POST"
          path   = "/s3-files"
        },
        {
          method = "PUT"
          path   = "/s3-files"
        },
        {
          method = "DELETE"
          path   = "/s3-files"
        },
        {
          method = "GET"
          path   = "/s3-files/{proxy+}"
        },
        {
          method = "POST"
          path   = "/s3-files/{proxy+}"
        },
        {
          method = "PUT"
          path   = "/s3-files/{proxy+}"
        },
        {
          method = "DELETE"
          path   = "/s3-files/{proxy+}"
        }
      ]
    }
  }
}

# Monitoring Variables
variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
}

variable "logging_level" {
  description = "Logging level for API Gateway (OFF, ERROR, INFO)"
  type        = string
  default     = "ERROR"
  validation {
    condition     = contains(["OFF", "ERROR", "INFO"], var.logging_level)
    error_message = "Logging level must be OFF, ERROR, or INFO."
  }
}

variable "data_trace_enabled" {
  description = "Enable data trace logging for API Gateway"
  type        = bool
  default     = false
}

variable "detailed_metrics_enabled" {
  description = "Enable detailed metrics for API Gateway"
  type        = bool
  default     = true
}

variable "enable_alerts" {
  description = "Enable CloudWatch alarms and email alerts"
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Email address to send alerts to (required if enable_alerts is true)"
  type        = string
  default     = null
}

variable "error_4xx_threshold" {
  description = "Threshold for 4xx error alarm"
  type        = number
  default     = 10
}

variable "error_5xx_threshold" {
  description = "Threshold for 5xx error alarm"
  type        = number
  default     = 5
}

variable "integration_error_threshold" {
  description = "Threshold for integration error alarm"
  type        = number
  default     = 3
}

variable "latency_threshold_ms" {
  description = "Threshold for latency alarm in milliseconds"
  type        = number
  default     = 5000
}

variable "error_alarm_evaluation_periods" {
  description = "Number of evaluation periods for error alarms"
  type        = number
  default     = 2
}

variable "error_alarm_period" {
  description = "Period in seconds for error alarm evaluation"
  type        = number
  default     = 300
}

variable "latency_alarm_evaluation_periods" {
  description = "Number of evaluation periods for latency alarms"
  type        = number
  default     = 2
}

variable "latency_alarm_period" {
  description = "Period in seconds for latency alarm evaluation"
  type        = number
  default     = 300
}