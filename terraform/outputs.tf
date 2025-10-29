output "sensor_topic_arn" {
  description = "ARN of the sensor data SNS topic"
  value       = aws_sns_topic.sensor_data.arn
}

output "alert_topic_arn" {
  description = "ARN of the sensor alerts SNS topic"
  value       = aws_sns_topic.sensor_alerts.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for sensor readings"
  value       = aws_dynamodb_table.sensor_readings.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for sensor readings"
  value       = aws_dynamodb_table.sensor_readings.arn
}

output "sensor_processor_function_name" {
  description = "Name of the sensor processor Lambda function"
  value       = aws_lambda_function.sensor_processor.function_name
}

output "sensor_processor_function_arn" {
  description = "ARN of the sensor processor Lambda function"
  value       = aws_lambda_function.sensor_processor.arn
}

output "alert_sender_function_name" {
  description = "Name of the alert sender Lambda function"
  value       = aws_lambda_function.alert_sender.function_name
}

output "alert_sender_function_arn" {
  description = "ARN of the alert sender Lambda function"
  value       = aws_lambda_function.alert_sender.arn
}

output "ses_email_identity" {
  description = "SES email identity for sending alerts"
  value       = aws_ses_email_identity.alert_email.email
}

output "lambda_role_arn" {
  description = "ARN of the IAM role used by Lambda functions"
  value       = aws_iam_role.lambda_role.arn
}

output "region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "alert_email" {
  description = "Email address configured for alerts"
  value       = var.alert_email
  sensitive   = true
}

output "test_command" {
  description = "Command to test the system with sensor simulator"
  value       = "python sensor_simulator.py --topic-arn ${aws_sns_topic.sensor_data.arn} --region ${var.aws_region} --count 5"
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups for monitoring"
  value = {
    sensor_processor = "/aws/lambda/${aws_lambda_function.sensor_processor.function_name}"
    alert_sender     = "/aws/lambda/${aws_lambda_function.alert_sender.function_name}"
  }
}

output "monitoring_dashboard_url" {
  description = "URL to CloudWatch dashboard (manual setup required)"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:"
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    sns_topics = {
      sensor_data = aws_sns_topic.sensor_data.name
      alerts      = aws_sns_topic.sensor_alerts.name
    }
    lambda_functions = {
      processor = aws_lambda_function.sensor_processor.function_name
      alerter   = aws_lambda_function.alert_sender.function_name
    }
    dynamodb_table = aws_dynamodb_table.sensor_readings.name
    ses_email      = aws_ses_email_identity.alert_email.email
    region         = var.aws_region
  }
}