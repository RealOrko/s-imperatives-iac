# SNS Topic for email alerts (only created if alerts are enabled and email is provided)
resource "aws_sns_topic" "api_gateway_alerts" {
  count = var.enable_alerts && var.alert_email != null ? 1 : 0
  name  = "${var.prefix}-${var.environment}-api-gateway-alerts"

  tags = {
    Name        = "${var.prefix}-${var.environment}-api-gateway-alerts"
    Environment = var.environment
    Project     = var.prefix
  }
}

# SNS Topic Subscription for email alerts
resource "aws_sns_topic_subscription" "email_alerts" {
  count     = var.enable_alerts && var.alert_email != null ? 1 : 0
  topic_arn = aws_sns_topic.api_gateway_alerts[0].arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Alarm for 4xx errors
resource "aws_cloudwatch_metric_alarm" "api_gateway_4xx_errors" {
  count = var.enable_alerts && var.alert_email != null ? 1 : 0

  alarm_name          = "${var.prefix}-${var.environment}-api-gateway-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.error_alarm_evaluation_periods
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = var.error_alarm_period
  statistic           = "Sum"
  threshold           = var.error_4xx_threshold
  alarm_description   = "This metric monitors 4xx errors on ${var.prefix}-${var.environment} API Gateway"
  alarm_actions       = [aws_sns_topic.api_gateway_alerts[0].arn]
  ok_actions          = [aws_sns_topic.api_gateway_alerts[0].arn]

  dimensions = {
    ApiName = module.api_gateway.api_id
  }

  tags = {
    Name        = "${var.prefix}-${var.environment}-api-gateway-4xx-alarm"
    Environment = var.environment
    Project     = var.prefix
  }
}

# CloudWatch Alarm for 5xx errors
resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx_errors" {
  count = var.enable_alerts && var.alert_email != null ? 1 : 0

  alarm_name          = "${var.prefix}-${var.environment}-api-gateway-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.error_alarm_evaluation_periods
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = var.error_alarm_period
  statistic           = "Sum"
  threshold           = var.error_5xx_threshold
  alarm_description   = "This metric monitors 5xx errors on ${var.prefix}-${var.environment} API Gateway"
  alarm_actions       = [aws_sns_topic.api_gateway_alerts[0].arn]
  ok_actions          = [aws_sns_topic.api_gateway_alerts[0].arn]

  dimensions = {
    ApiName = module.api_gateway.api_id
  }

  tags = {
    Name        = "${var.prefix}-${var.environment}-api-gateway-5xx-alarm"
    Environment = var.environment
    Project     = var.prefix
  }
}

# CloudWatch Alarm for high latency
resource "aws_cloudwatch_metric_alarm" "api_gateway_high_latency" {
  count = var.enable_alerts && var.alert_email != null ? 1 : 0

  alarm_name          = "${var.prefix}-${var.environment}-api-gateway-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.latency_alarm_evaluation_periods
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = var.latency_alarm_period
  statistic           = "Average"
  threshold           = var.latency_threshold_ms
  alarm_description   = "This metric monitors high latency on ${var.prefix}-${var.environment} API Gateway"
  alarm_actions       = [aws_sns_topic.api_gateway_alerts[0].arn]
  ok_actions          = [aws_sns_topic.api_gateway_alerts[0].arn]

  dimensions = {
    ApiName = module.api_gateway.api_id
  }

  tags = {
    Name        = "${var.prefix}-${var.environment}-api-gateway-latency-alarm"
    Environment = var.environment
    Project     = var.prefix
  }
}

# CloudWatch Alarm for Integration errors
resource "aws_cloudwatch_metric_alarm" "api_gateway_integration_errors" {
  count = var.enable_alerts && var.alert_email != null ? 1 : 0

  alarm_name          = "${var.prefix}-${var.environment}-api-gateway-integration-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.error_alarm_evaluation_periods
  metric_name         = "IntegrationError"
  namespace           = "AWS/ApiGateway"
  period              = var.error_alarm_period
  statistic           = "Sum"
  threshold           = var.integration_error_threshold
  alarm_description   = "This metric monitors integration errors on ${var.prefix}-${var.environment} API Gateway"
  alarm_actions       = [aws_sns_topic.api_gateway_alerts[0].arn]
  ok_actions          = [aws_sns_topic.api_gateway_alerts[0].arn]

  dimensions = {
    ApiName = module.api_gateway.api_id
  }

  tags = {
    Name        = "${var.prefix}-${var.environment}-api-gateway-integration-alarm"
    Environment = var.environment
    Project     = var.prefix
  }
}

# IAM role for API Gateway CloudWatch logs
resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = "${var.prefix}-${var.environment}-api-gateway-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "${var.prefix}-${var.environment}-api-gateway-cloudwatch-role"
    Environment = var.environment
    Project     = var.prefix
  }
}

# Attach policy to allow API Gateway to write to CloudWatch logs
resource "aws_iam_role_policy" "api_gateway_cloudwatch_policy" {
  name = "${var.prefix}-${var.environment}-api-gateway-cloudwatch-policy"
  role = aws_iam_role.api_gateway_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Set the CloudWatch logs role ARN in API Gateway account settings
resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
}