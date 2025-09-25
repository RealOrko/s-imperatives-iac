# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${var.prefix}-${var.environment}-api"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.prefix}-${var.environment}-api-logs"
    Environment = var.environment
    Project     = var.prefix
  }
}

# CloudWatch Log Group for API Gateway access logs
resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = "/aws/apigateway/${var.prefix}-${var.environment}-api-access"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.prefix}-${var.environment}-api-access-logs"
    Environment = var.environment
    Project     = var.prefix
  }
}
