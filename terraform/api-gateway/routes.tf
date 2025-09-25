# Create a local map to flatten the routes for for_each
locals {
  # Create a lookup map for data sources
  lambda_function_data_sources = {
    lambda_s3_files   = data.terraform_remote_state.lambda_s3_files
    lambda_authoriser = data.terraform_remote_state.lambda_authoriser
    # Add more mappings as needed
  }

  # Flatten the routes from the nested structure to create unique keys
  flattened_routes = flatten([
    for integration_key, integration in var.api_routes : [
      for route in integration.routes : {
        key                = "${integration_key}_${lower(route.method)}_${replace(replace(route.path, "/", "_"), "{proxy+}", "proxy")}"
        integration_key    = integration_key
        method             = route.method
        path               = route.path
        authorization_type = integration.authorization_type
        use_authorizer     = integration.use_authorizer
      }
    ]
  ])

  # Convert to a map for for_each usage
  routes_map = {
    for route in local.flattened_routes : route.key => route
  }
}

# Create Lambda integrations using for_each
resource "aws_apigatewayv2_integration" "lambda_integrations" {
  for_each = var.api_routes

  api_id             = module.api_gateway.api_id
  integration_type   = each.value.integration_type
  integration_method = each.value.integration_method
  integration_uri    = local.lambda_function_data_sources[each.value.lambda_function_key].outputs.lambda_function_arn

  payload_format_version = each.value.payload_format_version
  timeout_milliseconds   = each.value.timeout_milliseconds
}

# Create routes using for_each
resource "aws_apigatewayv2_route" "api_routes" {
  for_each = local.routes_map

  api_id    = module.api_gateway.api_id
  route_key = "${each.value.method} ${each.value.path}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integrations[each.value.integration_key].id}"

  authorization_type = each.value.use_authorizer ? each.value.authorization_type : "NONE"
  authorizer_id      = each.value.use_authorizer ? aws_apigatewayv2_authorizer.lambda_authorizer.id : null
}

# Grant API Gateway permission to invoke Lambda functions using for_each
resource "aws_lambda_permission" "lambda_invoke_permissions" {
  for_each = var.api_routes

  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_function_data_sources[each.value.lambda_function_key].outputs.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*/*"
}
