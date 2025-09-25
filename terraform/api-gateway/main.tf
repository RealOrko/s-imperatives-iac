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

# Create Lambda integration for s3-files
resource "aws_apigatewayv2_integration" "s3_files_lambda_integration" {
  api_id             = module.api_gateway.api_id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = data.terraform_remote_state.lambda_s3_files.outputs.lambda_function_arn

  payload_format_version = "2.0"
  timeout_milliseconds   = 12000
}

# Create routes for s3-files endpoint
resource "aws_apigatewayv2_route" "s3_files_get" {
  api_id    = module.api_gateway.api_id
  route_key = "GET /s3-files"
  target    = "integrations/${aws_apigatewayv2_integration.s3_files_lambda_integration.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
}

resource "aws_apigatewayv2_route" "s3_files_post" {
  api_id    = module.api_gateway.api_id
  route_key = "POST /s3-files"
  target    = "integrations/${aws_apigatewayv2_integration.s3_files_lambda_integration.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
}

resource "aws_apigatewayv2_route" "s3_files_put" {
  api_id    = module.api_gateway.api_id
  route_key = "PUT /s3-files"
  target    = "integrations/${aws_apigatewayv2_integration.s3_files_lambda_integration.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
}

resource "aws_apigatewayv2_route" "s3_files_delete" {
  api_id    = module.api_gateway.api_id
  route_key = "DELETE /s3-files"
  target    = "integrations/${aws_apigatewayv2_integration.s3_files_lambda_integration.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
}

# Create routes for s3-files with path parameters
resource "aws_apigatewayv2_route" "s3_files_get_proxy" {
  api_id    = module.api_gateway.api_id
  route_key = "GET /s3-files/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.s3_files_lambda_integration.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
}

resource "aws_apigatewayv2_route" "s3_files_post_proxy" {
  api_id    = module.api_gateway.api_id
  route_key = "POST /s3-files/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.s3_files_lambda_integration.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
}

resource "aws_apigatewayv2_route" "s3_files_put_proxy" {
  api_id    = module.api_gateway.api_id
  route_key = "PUT /s3-files/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.s3_files_lambda_integration.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
}

resource "aws_apigatewayv2_route" "s3_files_delete_proxy" {
  api_id    = module.api_gateway.api_id
  route_key = "DELETE /s3-files/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.s3_files_lambda_integration.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id
}

# Create custom authorizer using the authorizer lambda
resource "aws_apigatewayv2_authorizer" "lambda_authorizer" {
  api_id                            = module.api_gateway.api_id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${data.terraform_remote_state.lambda_authoriser.outputs.lambda_function_arn}/invocations"
  name                              = "${var.prefix}-${var.environment}-lambda-authorizer"
  authorizer_payload_format_version = "2.0"
  authorizer_result_ttl_in_seconds  = 300
  identity_sources                  = ["$request.header.Authorization"]

  depends_on = [module.api_gateway]
}

# Grant API Gateway permission to invoke the authorizer Lambda
resource "aws_lambda_permission" "authorizer_invoke_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.lambda_authoriser.outputs.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*/*"
}

# Grant API Gateway permission to invoke the s3-files Lambda
resource "aws_lambda_permission" "s3_files_invoke_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.lambda_s3_files.outputs.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*/*"
}