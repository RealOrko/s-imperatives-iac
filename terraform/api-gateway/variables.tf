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