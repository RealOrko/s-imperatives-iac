variable "region" {
  description = "The AWS region to create the S3 bucket in."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "The environment for the S3 bucket (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "prefix" {
  description = "The prefix for the S3 bucket (e.g., dev, prod)."
  type        = string
  default     = "si-iac"
}

variable "tags" {
  description = "A map of tags to assign to the bucket."
  type        = map(string)
  default = {
    Company     = "strategic-imperatives"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

variable "create_access_groups" {
  description = "Whether to create IAM groups for accessing the S3 bucket (developer and devops groups)."
  type        = bool
  default     = true
}
