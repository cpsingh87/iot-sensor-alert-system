#!/bin/bash

# Simple deployment script for IoT Sensor Alert System
# This will create the AWS resources using AWS CLI

set -e

echo "🚀 Deploying IoT Sensor Alert System..."

# Variables
REGION="us-east-2"
EMAIL="risox72951@ametitas.com"

echo "📧 Email: $EMAIL"
echo "🌍 Region: $REGION"

# 1. Create SNS Topics
echo "📡 Creating SNS topics..."
SENSOR_TOPIC_ARN=$(aws sns create-topic --name iot-sensor-data --region $REGION --query 'TopicArn' --output text)
ALERT_TOPIC_ARN=$(aws sns create-topic --name iot-sensor-alerts --region $REGION --query 'TopicArn' --output text)

echo "✅ Sensor Topic: $SENSOR_TOPIC_ARN"
echo "✅ Alert Topic: $ALERT_TOPIC_ARN"

# 2. Verify SES Email
echo "📧 Setting up SES email identity..."
aws ses verify-email-identity --email-address $EMAIL --region $REGION || echo "Email might already be verified"

# 3. Create DynamoDB Table
echo "💾 Creating DynamoDB table..."
aws dynamodb create-table \
    --table-name sensor-readings \
    --attribute-definitions \
        AttributeName=sensor_id,AttributeType=S \
        AttributeName=timestamp,AttributeType=N \
    --key-schema \
        AttributeName=sensor_id,KeyType=HASH \
        AttributeName=timestamp,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --region $REGION || echo "Table might already exist"

# 4. Create IAM Role for Lambda
echo "🔐 Creating IAM role..."
ROLE_ARN=$(aws iam create-role \
    --role-name iot-lambda-role \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }' \
    --query 'Role.Arn' --output text 2>/dev/null || aws iam get-role --role-name iot-lambda-role --query 'Role.Arn' --output text)

echo "✅ Role ARN: $ROLE_ARN"

# Attach policies to the role
aws iam attach-role-policy --role-name iot-lambda-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam attach-role-policy --role-name iot-lambda-role --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
aws iam attach-role-policy --role-name iot-lambda-role --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
aws iam attach-role-policy --role-name iot-lambda-role --policy-arn arn:aws:iam::aws:policy/AmazonSESFullAccess

echo "⏳ Waiting for IAM role to propagate..."
sleep 10

# 5. Create Lambda Functions
echo "⚡ Creating Lambda functions..."

# Sensor Processor Lambda
PROCESSOR_ARN=$(aws lambda create-function \
    --function-name iot-sensor-processor \
    --runtime nodejs18.x \
    --role $ROLE_ARN \
    --handler index.handler \
    --zip-file fileb://sensor_processor.zip \
    --environment Variables="{DYNAMODB_TABLE=sensor-readings,ALERT_TOPIC_ARN=$ALERT_TOPIC_ARN}" \
    --region $REGION \
    --query 'FunctionArn' --output text 2>/dev/null || aws lambda get-function --function-name iot-sensor-processor --region $REGION --query 'Configuration.FunctionArn' --output text)

echo "✅ Processor Lambda: $PROCESSOR_ARN"

# Alert Sender Lambda
ALERT_SENDER_ARN=$(aws lambda create-function \
    --function-name iot-alert-sender \
    --runtime nodejs18.x \
    --role $ROLE_ARN \
    --handler alert.handler \
    --zip-file fileb://alert_sender.zip \
    --environment Variables="{ALERT_EMAIL=$EMAIL}" \
    --region $REGION \
    --query 'FunctionArn' --output text 2>/dev/null || aws lambda get-function --function-name iot-alert-sender --region $REGION --query 'Configuration.FunctionArn' --output text)

echo "✅ Alert Sender Lambda: $ALERT_SENDER_ARN"

# 6. Subscribe Lambda functions to SNS topics
echo "🔗 Connecting SNS to Lambda..."

# Subscribe sensor processor to sensor data topic
aws sns subscribe \
    --topic-arn $SENSOR_TOPIC_ARN \
    --protocol lambda \
    --notification-endpoint $PROCESSOR_ARN \
    --region $REGION

# Subscribe alert sender to alert topic
aws sns subscribe \
    --topic-arn $ALERT_TOPIC_ARN \
    --protocol lambda \
    --notification-endpoint $ALERT_SENDER_ARN \
    --region $REGION

# 7. Add Lambda permissions for SNS
echo "🔐 Setting Lambda permissions..."

aws lambda add-permission \
    --function-name iot-sensor-processor \
    --statement-id sns-invoke \
    --action lambda:InvokeFunction \
    --principal sns.amazonaws.com \
    --source-arn $SENSOR_TOPIC_ARN \
    --region $REGION

aws lambda add-permission \
    --function-name iot-alert-sender \
    --statement-id sns-invoke \
    --action lambda:InvokeFunction \
    --principal sns.amazonaws.com \
    --source-arn $ALERT_TOPIC_ARN \
    --region $REGION

echo ""
echo "🎉 Deployment Complete!"
echo "================================"
echo "📡 Sensor Topic ARN: $SENSOR_TOPIC_ARN"
echo "🚨 Alert Topic ARN: $ALERT_TOPIC_ARN"
echo "💾 DynamoDB Table: sensor-readings"
echo "📧 Alert Email: $EMAIL"
echo ""
echo "🧪 Test the system:"
echo "python sensor_simulator.py --topic-arn $SENSOR_TOPIC_ARN"
echo ""
echo "📧 Don't forget to verify your email in SES!"
echo "🔍 Monitor CloudWatch logs for processing details"