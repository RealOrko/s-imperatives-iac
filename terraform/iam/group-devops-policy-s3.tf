# IAM Policy for DevOps Group (Read/Write access)
resource "aws_iam_policy" "devops_policy_s3" {
  count       = var.create_access_groups ? 1 : 0
  name        = "${var.prefix}-${var.environment}-devops-policy-s3"
  description = "Read/Write access to S3 bucket"

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
        Resource = "arn:aws:s3:::si-iac-${var.environment}-*"
      },
      {
        Sid    = "FullObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = "arn:aws:s3:::si-iac-${var.environment}-*/*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_group_policy_attachment" "devops_policy_attachment_s3" {
  count      = var.create_access_groups ? 1 : 0
  group      = aws_iam_group.devops[0].name
  policy_arn = aws_iam_policy.devops_policy_s3[0].arn
}
