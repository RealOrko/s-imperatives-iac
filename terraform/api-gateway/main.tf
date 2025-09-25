# Create the API Gateway using the terraform-aws-apigateway-v2 module
module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${var.prefix}-${var.environment}-api"
  description   = "HTTP API Gateway for ${var.environment} environment"
  protocol_type = "HTTP"

  # CORS configuration
  cors_configuration = {
    allow_headers     = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = ["date", "keep-alive"]
    max_age           = 86400
    allow_credentials = false
  }

  # Domain configuration - only create domain if domain_name is provided
  create_domain_name          = var.domain_name != null && var.domain_name != ""
  domain_name                 = var.domain_name != null ? var.domain_name : ""
  domain_name_certificate_arn = var.domain_name != null ? var.certificate_arn : null

  tags = {
    Name        = "${var.prefix}-${var.environment}-api"
    Environment = var.environment
    Project     = var.prefix
  }
}
