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

# S3 bucket policy
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DeveloperReadOnly"
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_group.developers.arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*"
        ]
      },
      {
        Sid       = "DevOpsReadWrite"
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_group.devops.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.example.arn,
          "${aws_s3_bucket.example.arn}/*"
        ]
      }
    ]
  })
}
