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

# Monitoring Outputs
output "log_group_arn" {
  description = "ARN of the API Gateway CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_gateway_logs.arn
}

output "access_log_group_arn" {
  description = "ARN of the API Gateway access CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_gateway_access_logs.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts (if enabled)"
  value       = var.enable_alerts && var.alert_email != null ? aws_sns_topic.api_gateway_alerts[0].arn : null
}

output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarm ARNs"
  value = var.enable_alerts && var.alert_email != null ? {
    "4xx_errors"         = aws_cloudwatch_metric_alarm.api_gateway_4xx_errors[0].arn
    "5xx_errors"         = aws_cloudwatch_metric_alarm.api_gateway_5xx_errors[0].arn
    "high_latency"       = aws_cloudwatch_metric_alarm.api_gateway_high_latency[0].arn
    "integration_errors" = aws_cloudwatch_metric_alarm.api_gateway_integration_errors[0].arn
  } : {}
}