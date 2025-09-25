output "bucket_id" {
  description = "The name of the bucket."
  value       = module.s3_bucket.s3_bucket_id
}

output "bucket_arn" {
  description = "The ARN of the bucket."
  value       = module.s3_bucket.s3_bucket_arn
}

output "bucket_domain_name" {
  description = "The bucket domain name."
  value       = module.s3_bucket.s3_bucket_bucket_domain_name
}

# IAM Groups outputs
output "developer_group_name" {
  description = "The name of the developer IAM group."
  value       = var.create_access_groups ? aws_iam_group.developer[0].name : null
}

output "developer_group_arn" {
  description = "The ARN of the developer IAM group."
  value       = var.create_access_groups ? aws_iam_group.developer[0].arn : null
}

output "devops_group_name" {
  description = "The name of the devops IAM group."
  value       = var.create_access_groups ? aws_iam_group.devops[0].name : null
}

output "devops_group_arn" {
  description = "The ARN of the devops IAM group."
  value       = var.create_access_groups ? aws_iam_group.devops[0].arn : null
}

# IAM Policy outputs
output "developer_policy_arn" {
  description = "The ARN of the developer IAM policy."
  value       = var.create_access_groups ? aws_iam_policy.developer_policy[0].arn : null
}

output "devops_policy_arn" {
  description = "The ARN of the devops IAM policy."
  value       = var.create_access_groups ? aws_iam_policy.devops_policy[0].arn : null
}
