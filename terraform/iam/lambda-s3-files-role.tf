# IAM role for Lambda execution
resource "aws_iam_role" "lambda_s3_files_role" {
  name = "${var.prefix}-${var.environment}-s3-files-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach basic execution policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_files_policy" {
  role       = aws_iam_role.lambda_s3_files_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# S3 policy for foo-bar bucket operations
resource "aws_iam_policy" "lambda_s3_files_bucket_policy" {
  name = "${var.prefix}-${var.environment}-s3-files-bucket-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::si-iac-${var.environment}-lambda-packages"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::si-iac-${var.environment}-lambda-packages/*"
      }
    ]
  })
}

# Attach S3 policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_files_bucket_policy_attachment" {
  role       = aws_iam_role.lambda_s3_files_role.name
  policy_arn = aws_iam_policy.lambda_s3_files_bucket_policy.arn
}

