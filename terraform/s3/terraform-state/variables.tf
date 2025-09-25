variable "region" {
  description = "The AWS region to create the S3 bucket in."
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
  default     = "si-iac-terraform-state"
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable versioning on the bucket."
  type        = bool
  default     = true
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
