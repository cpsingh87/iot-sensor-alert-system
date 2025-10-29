# Simple deployment script for IoT Sensor Alert System

Write-Host "Deploying IoT Sensor Alert System..." -ForegroundColor Green

# Variables
$REGION = "us-east-2"
$EMAIL = "risox72951@ametitas.com"

Write-Host "Email: $EMAIL" -ForegroundColor Cyan
Write-Host "Region: $REGION" -ForegroundColor Cyan

# 1. Create SNS Topics
Write-Host "Creating SNS topics..." -ForegroundColor Yellow
$SENSOR_TOPIC_ARN = aws sns create-topic --name iot-sensor-data --region $REGION --query 'TopicArn' --output text
$ALERT_TOPIC_ARN = aws sns create-topic --name iot-sensor-alerts --region $REGION --query 'TopicArn' --output text

Write-Host "Sensor Topic: $SENSOR_TOPIC_ARN" -ForegroundColor Green
Write-Host "Alert Topic: $ALERT_TOPIC_ARN" -ForegroundColor Green

# 2. Verify SES Email
Write-Host "Setting up SES email identity..." -ForegroundColor Yellow
aws ses verify-email-identity --email-address $EMAIL --region $REGION

# 3. Create DynamoDB Table
Write-Host "Creating DynamoDB table..." -ForegroundColor Yellow
aws dynamodb create-table --table-name sensor-readings --attribute-definitions AttributeName=sensor_id,AttributeType=S AttributeName=timestamp,AttributeType=N --key-schema AttributeName=sensor_id,KeyType=HASH AttributeName=timestamp,KeyType=RANGE --billing-mode PAY_PER_REQUEST --region $REGION

# 4. Create IAM Role for Lambda
Write-Host "Creating IAM role..." -ForegroundColor Yellow

$assumeRolePolicy = '{"Version": "2012-10-17","Statement": [{"Effect": "Allow","Principal": {"Service": "lambda.amazonaws.com"},"Action": "sts:AssumeRole"}]}'

$ROLE_ARN = aws iam create-role --role-name iot-lambda-role --assume-role-policy-document $assumeRolePolicy --query 'Role.Arn' --output text

Write-Host "Role ARN: $ROLE_ARN" -ForegroundColor Green

# Attach policies to the role
aws iam attach-role-policy --role-name iot-lambda-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam attach-role-policy --role-name iot-lambda-role --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
aws iam attach-role-policy --role-name iot-lambda-role --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
aws iam attach-role-policy --role-name iot-lambda-role --policy-arn arn:aws:iam::aws:policy/AmazonSESFullAccess

Write-Host "Waiting for IAM role to propagate..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# 5. Create Lambda Functions
Write-Host "Creating Lambda functions..." -ForegroundColor Yellow

# Sensor Processor Lambda
$PROCESSOR_ARN = aws lambda create-function --function-name iot-sensor-processor --runtime nodejs18.x --role $ROLE_ARN --handler index.handler --zip-file fileb://sensor_processor.zip --environment "Variables={DYNAMODB_TABLE=sensor-readings,ALERT_TOPIC_ARN=$ALERT_TOPIC_ARN}" --region $REGION --query 'FunctionArn' --output text

Write-Host "Processor Lambda: $PROCESSOR_ARN" -ForegroundColor Green

# Alert Sender Lambda
$ALERT_SENDER_ARN = aws lambda create-function --function-name iot-alert-sender --runtime nodejs18.x --role $ROLE_ARN --handler alert.handler --zip-file fileb://alert_sender.zip --environment "Variables={ALERT_EMAIL=$EMAIL}" --region $REGION --query 'FunctionArn' --output text

Write-Host "Alert Sender Lambda: $ALERT_SENDER_ARN" -ForegroundColor Green

# 6. Subscribe Lambda functions to SNS topics
Write-Host "Connecting SNS to Lambda..." -ForegroundColor Yellow

aws sns subscribe --topic-arn $SENSOR_TOPIC_ARN --protocol lambda --notification-endpoint $PROCESSOR_ARN --region $REGION
aws sns subscribe --topic-arn $ALERT_TOPIC_ARN --protocol lambda --notification-endpoint $ALERT_SENDER_ARN --region $REGION

# 7. Add Lambda permissions for SNS
Write-Host "Setting Lambda permissions..." -ForegroundColor Yellow

aws lambda add-permission --function-name iot-sensor-processor --statement-id sns-invoke --action lambda:InvokeFunction --principal sns.amazonaws.com --source-arn $SENSOR_TOPIC_ARN --region $REGION
aws lambda add-permission --function-name iot-alert-sender --statement-id sns-invoke --action lambda:InvokeFunction --principal sns.amazonaws.com --source-arn $ALERT_TOPIC_ARN --region $REGION

Write-Host ""
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "Sensor Topic ARN: $SENSOR_TOPIC_ARN" -ForegroundColor Cyan
Write-Host "Alert Topic ARN: $ALERT_TOPIC_ARN" -ForegroundColor Cyan
Write-Host "DynamoDB Table: sensor-readings" -ForegroundColor Cyan
Write-Host "Alert Email: $EMAIL" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test the system:" -ForegroundColor Yellow
Write-Host "py sensor_simulator.py --topic-arn $SENSOR_TOPIC_ARN" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANT: Verify your email in SES console!" -ForegroundColor Red
Write-Host "Monitor CloudWatch logs for processing details" -ForegroundColor Yellow