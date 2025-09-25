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