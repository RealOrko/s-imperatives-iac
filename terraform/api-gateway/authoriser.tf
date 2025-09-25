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
