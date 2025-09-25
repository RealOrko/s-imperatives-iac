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
output "developer_policy_arn_s3" {
  description = "The ARN of the developer IAM policy for S3."
  value       = var.create_access_groups ? aws_iam_policy.developer_policy[0].arn : null
}

output "devops_policy_arn_s3" {
  description = "The ARN of the devops IAM policy for S3."
  value       = var.create_access_groups ? aws_iam_policy.devops_policy[0].arn : null
}
