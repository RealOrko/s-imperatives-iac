# IAM role for Lambda execution
resource "aws_iam_role" "lambda_authoriser_role" {
  name = "${var.prefix}-${var.environment}-authoriser-role"

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
resource "aws_iam_role_policy_attachment" "lambda_authoriser_policy" {
  role       = aws_iam_role.lambda_authoriser_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

