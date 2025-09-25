# API Gateway Monitoring

This module includes comprehensive monitoring for the API Gateway deployment with CloudWatch logs and email alerts for errors.

## Features

- **CloudWatch Log Groups**: Separate log groups for API Gateway execution logs and access logs
- **Email Alerts**: Configurable email notifications for various error conditions
- **Configurable Thresholds**: Customizable alert thresholds for different metrics
- **Conditional Deployment**: Alerts can be enabled/disabled via configuration

## Monitoring Components

### CloudWatch Log Groups

1. **Execution Logs**: `/aws/apigateway/{prefix}-{environment}-api`
   - API Gateway execution logs
   - Configurable retention period

2. **Access Logs**: `/aws/apigateway/{prefix}-{environment}-api-access`
   - Detailed request/response information
   - JSON formatted logs with comprehensive request metadata

### CloudWatch Alarms

When alerts are enabled (`enable_alerts = true`) and an email is provided (`alert_email`), the following alarms are created:

1. **4xx Errors**: Monitors client errors
2. **5xx Errors**: Monitors server errors  
3. **Integration Errors**: Monitors backend integration failures
4. **High Latency**: Monitors response time performance

### SNS Integration

- SNS topic for email notifications
- Email subscription (requires confirmation)
- Alerts sent for both alarm and OK states

## Configuration

### Basic Configuration

```hcl
# Enable/disable monitoring alerts
enable_alerts = true
alert_email   = "alerts@yourcompany.com"

# Log retention (days)
log_retention_days = 14

# Logging configuration
logging_level            = "ERROR"  # OFF, ERROR, or INFO
data_trace_enabled       = false
detailed_metrics_enabled = true
```

### Alert Thresholds

```hcl
# Error thresholds (number of errors)
error_4xx_threshold         = 10
error_5xx_threshold         = 5
integration_error_threshold = 3

# Latency threshold (milliseconds)
latency_threshold_ms = 5000

# Evaluation periods and timing
error_alarm_evaluation_periods   = 2
error_alarm_period               = 300  # 5 minutes
latency_alarm_evaluation_periods = 2
latency_alarm_period             = 300  # 5 minutes
```

## Usage Examples

### Enable Alerts with Default Settings

```hcl
enable_alerts = true
alert_email   = "devops@company.com"
```

### Custom Alert Thresholds

```hcl
enable_alerts = true
alert_email   = "alerts@company.com"

# More sensitive error detection
error_4xx_threshold = 5
error_5xx_threshold = 1
latency_threshold_ms = 2000

# Faster alert response
error_alarm_evaluation_periods = 1
error_alarm_period = 60  # 1 minute
```

### Logging Only (No Alerts)

```hcl
enable_alerts          = false
logging_level          = "INFO"
data_trace_enabled     = true
log_retention_days     = 30
```

## Outputs

The monitoring configuration provides the following outputs:

- `log_group_arn`: CloudWatch log group ARN for execution logs
- `access_log_group_arn`: CloudWatch log group ARN for access logs
- `sns_topic_arn`: SNS topic ARN (if alerts enabled)
- `cloudwatch_alarms`: Map of alarm ARNs (if alerts enabled)

## Email Confirmation

After deployment with `enable_alerts = true`, you'll receive an email confirmation request at the configured `alert_email` address. You must confirm the subscription to receive alerts.

## Best Practices

1. **Start Conservatively**: Begin with higher thresholds and adjust based on actual traffic patterns
2. **Monitor Costs**: CloudWatch logs and alarms incur charges - set appropriate retention periods
3. **Test Alerts**: Trigger test errors to verify email delivery
4. **Environment-Specific Settings**: Use different thresholds for dev/staging/production
5. **Regular Review**: Periodically review and adjust thresholds based on application growth

## Troubleshooting

### No Alert Emails Received

1. Check if SNS subscription is confirmed
2. Verify email address is correct
3. Check spam/junk folders
4. Ensure alarms are being triggered (check CloudWatch console)

### High CloudWatch Costs

1. Reduce log retention period
2. Disable data tracing in production
3. Use ERROR level logging instead of INFO
4. Review log volume in CloudWatch console

### False Positive Alerts

1. Increase error thresholds
2. Increase evaluation periods
3. Adjust alarm period (longer periods smooth out spikes)