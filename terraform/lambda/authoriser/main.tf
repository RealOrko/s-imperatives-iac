# Define local variables for versioning
locals {
  lambda_name = "${var.lambda_name}-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  source_dir  = "./lambda_code" # Directory containing Lambda code
  output_path = "./lambda_code/${local.lambda_name}.zip"
}

# Archive the Lambda function code into a zip file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = local.source_dir
  output_path = local.output_path
}

# Upload the zipped Lambda code to S3
resource "aws_s3_object" "lambda_code" {
  bucket = data.terraform_remote_state.lambda_packages.outputs.bucket_id
  key    = "${var.environment}/${var.lambda_name}/${local.lambda_name}.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = data.archive_file.lambda_zip.output_md5

  depends_on = [data.archive_file.lambda_zip]
}

# Define the Lambda function
resource "aws_lambda_function" "lambda" {
  function_name = "${var.prefix}-${var.environment}-${var.lambda_name}"
  s3_bucket     = data.terraform_remote_state.lambda_packages.outputs.bucket_id
  s3_key        = aws_s3_object.lambda_code.key
  handler       = "index.handler" # Adjust based on your Lambda handler
  runtime       = "nodejs22.x"    # Adjust based on your runtime
  role          = data.terraform_remote_state.iam.outputs.lambda_s3_files_role_arn

  depends_on = [aws_s3_object.lambda_code]

  lifecycle {
    ignore_changes = [ s3_key ] # Prevents recreation on code updates
  }
}

output "lambda_function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.lambda.arn
}
