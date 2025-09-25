output "api_id" {
  description = "The ID of the API Gateway"
  value       = module.api_gateway.api_id
}

output "api_arn" {
  description = "The ARN of the API Gateway"
  value       = module.api_gateway.api_arn
}

output "api_endpoint" {
  description = "The URI of the API Gateway"
  value       = module.api_gateway.api_endpoint
}

output "api_execution_arn" {
  description = "The ARN prefix to be used in an aws_lambda_permission's source_arn attribute"
  value       = module.api_gateway.api_execution_arn
}

output "stage_arn" {
  description = "The default stage ARN"
  value       = module.api_gateway.stage_arn
}

output "stage_domain_name" {
  description = "Domain name of the stage"
  value       = module.api_gateway.stage_domain_name
}

output "authorizer_id" {
  description = "The ID of the Lambda authorizer"
  value       = aws_apigatewayv2_authorizer.lambda_authorizer.id
}