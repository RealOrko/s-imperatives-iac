module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = ">= 3.0.0"

  region        = var.region
  bucket        = "${var.prefix}-${var.environment}-${var.bucket_name}"
  force_destroy = var.force_destroy

  versioning = {
    enabled = var.versioning_enabled
  }

  # Block public access for security (appropriate for terraform state bucket)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Ownership controls to avoid issues with ACLs
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"
  expected_bucket_owner    = data.aws_caller_identity.current.account_id

  tags = var.tags
}

# IAM Groups for S3 bucket access control
resource "aws_iam_group" "developer" {
  count = var.create_access_groups ? 1 : 0
  name  = "${var.prefix}-${var.environment}-${var.bucket_name}-developers"
  path  = "/"
}

resource "aws_iam_group" "devops" {
  count = var.create_access_groups ? 1 : 0
  name  = "${var.prefix}-${var.environment}-${var.bucket_name}-devops"
  path  = "/"
}

# IAM Policy for Developer Group (Read-only access)
resource "aws_iam_policy" "developer_policy" {
  count       = var.create_access_groups ? 1 : 0
  name        = "${var.prefix}-${var.environment}-${var.bucket_name}-developer-policy"
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
        Resource = module.s3_bucket.s3_bucket_arn
      },
      {
        Sid    = "GetObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${module.s3_bucket.s3_bucket_arn}/*"
      }
    ]
  })
  
  tags = var.tags
}

# IAM Policy for DevOps Group (Read/Write access)
resource "aws_iam_policy" "devops_policy" {
  count       = var.create_access_groups ? 1 : 0
  name        = "${var.prefix}-${var.environment}-${var.bucket_name}-devops-policy"
  description = "Read/Write access to ${module.s3_bucket.s3_bucket_id} S3 bucket"
  
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
        Resource = module.s3_bucket.s3_bucket_arn
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
        Resource = "${module.s3_bucket.s3_bucket_arn}/*"
      }
    ]
  })
  
  tags = var.tags
}

# Attach policies to groups
resource "aws_iam_group_policy_attachment" "developer_policy_attachment" {
  count      = var.create_access_groups ? 1 : 0
  group      = aws_iam_group.developer[0].name
  policy_arn = aws_iam_policy.developer_policy[0].arn
}

resource "aws_iam_group_policy_attachment" "devops_policy_attachment" {
  count      = var.create_access_groups ? 1 : 0
  group      = aws_iam_group.devops[0].name
  policy_arn = aws_iam_policy.devops_policy[0].arn
}
