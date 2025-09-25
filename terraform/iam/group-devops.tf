# IAM Groups for S3 bucket access control
resource "aws_iam_group" "devops" {
  count = var.create_access_groups ? 1 : 0
  name  = "${var.prefix}-${var.environment}-devops"
  path  = "/"
}
