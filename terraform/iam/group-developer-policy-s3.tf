# IAM Policy for Developer Group (Read-only access)
resource "aws_iam_policy" "developer_policy_s3" {
  count       = var.create_access_groups ? 1 : 0
  name        = "${var.prefix}-${var.environment}-developer-policy-s3"
  description = "Read-only access to ${module.s3_bucket.s3_bucket_id} S3 bucket"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning"
        ]
        Resource = "arn:aws:s3:${var.region}:${data.aws_caller_identity.current.account_id}:si-iac-${var.environment}-*"
      },
      {
        Sid    = "GetObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:${var.region}:${data.aws_caller_identity.current.account_id}:si-iac-${var.environment}-*/*"
      }
    ]
  })
  
  tags = var.tags
}

# Attach policies to groups
resource "aws_iam_group_policy_attachment" "developer_policy_attachment_s3" {
  count      = var.create_access_groups ? 1 : 0
  group      = aws_iam_group.developer[0].name
  policy_arn = aws_iam_policy.developer_policy[0].arn
}
