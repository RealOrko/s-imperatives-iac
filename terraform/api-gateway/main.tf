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

  # Stage configuration
  create_stage = true
  stage_name   = var.stage_name

  # Access logging configuration
  stage_access_log_settings = {
    create_log_group = false # We create our own log group
    destination_arn  = aws_cloudwatch_log_group.api_gateway_access_logs.arn
    format = jsonencode({
      requestId              = "$context.requestId"
      ip                     = "$context.identity.sourceIp"
      requestTime            = "$context.requestTime"
      httpMethod             = "$context.httpMethod"
      routeKey               = "$context.routeKey"
      status                 = "$context.status"
      protocol               = "$context.protocol"
      responseLength         = "$context.responseLength"
      error                  = "$context.error.message"
      integration_error      = "$context.integration.error"
      integration_status     = "$context.integration.status"
      integration_latency    = "$context.integration.latency"
      integration_request_id = "$context.integration.requestId"
    })
  }

  # Default route settings
  stage_default_route_settings = {
    logging_level            = var.logging_level
    data_trace_enabled       = var.data_trace_enabled
    detailed_metrics_enabled = var.detailed_metrics_enabled
    throttling_rate_limit    = var.throttling_rate_limit
    throttling_burst_limit   = var.throttling_burst_limit
  }

  tags = {
    Name        = "${var.prefix}-${var.environment}-api"
    Environment = var.environment
    Project     = var.prefix
  }

  depends_on = [aws_cloudwatch_log_group.api_gateway_access_logs]
}
