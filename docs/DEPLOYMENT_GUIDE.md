# 🚀 Deployment Guide

This guide provides detailed instructions for deploying the IoT Sensor Alert System to AWS.

## Prerequisites

### Required Tools
- **AWS CLI** v2.x configured with appropriate permissions
- **Terraform** >= 1.0
- **Node.js** >= 18.x
- **Python** 3.x (for testing)

### Required AWS Permissions
Your AWS user/role needs the following permissions:
- SNS: CreateTopic, Subscribe, Publish
- Lambda: CreateFunction, UpdateFunctionCode, AddPermission
- DynamoDB: CreateTable, PutItem, GetItem, Query
- SES: VerifyEmailIdentity, SendEmail
- IAM: CreateRole, AttachRolePolicy
- CloudWatch: CreateLogGroup, PutLogEvents

## Deployment Methods

### Method 1: Terraform (Recommended)

#### Step 1: Configure Variables
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
aws_region = "us-east-2"
alert_email = "your-email@example.com"
```

#### Step 2: Initialize Terraform
```bash
terraform init
```

#### Step 3: Plan Deployment
```bash
terraform plan
```

#### Step 4: Deploy Infrastructure
```bash
terraform apply
```

#### Step 5: Verify Deployment
```bash
terraform output
```

### Method 2: PowerShell Script (Windows)

#### Step 1: Configure Variables
Edit `deploy.ps1` and update:
```powershell
$REGION = "us-east-2"
$EMAIL = "your-email@example.com"
```

#### Step 2: Run Deployment
```powershell
./deploy.ps1
```

### Method 3: Bash Script (Linux/Mac)

#### Step 1: Make Script Executable
```bash
chmod +x deploy.sh
```

#### Step 2: Configure Variables
Edit `deploy.sh` and update:
```bash
REGION="us-east-2"
EMAIL="your-email@example.com"
```

#### Step 3: Run Deployment
```bash
./deploy.sh
```

## Post-Deployment Steps

### 1. Verify SES Email
1. Check your email for SES verification message
2. Click the verification link
3. Confirm email is verified in AWS Console

### 2. Test the System
```bash
# Run system verification
./test_scripts/verify_system.ps1

# Test with sensor simulator
python sensor_simulator.py --topic-arn YOUR_TOPIC_ARN --count 3
```

### 3. Monitor Deployment
- Check CloudWatch logs for any errors
- Verify DynamoDB table is created
- Confirm Lambda functions are active

## Resource Naming Convention

| Resource Type | Naming Pattern | Example |
|---------------|----------------|---------|
| SNS Topics | `iot-{purpose}` | `iot-sensor-data` |
| Lambda Functions | `iot-{purpose}` | `iot-sensor-processor` |
| DynamoDB Tables | `{purpose}-{type}` | `sensor-readings` |
| IAM Roles | `iot-{service}-role` | `iot-lambda-role` |

## Environment Variables

### Lambda Processor
- `DYNAMODB_TABLE`: Name of the DynamoDB table
- `ALERT_TOPIC_ARN`: ARN of the alert SNS topic

### Lambda Alert Sender
- `ALERT_EMAIL`: Email address for sending alerts

## Cleanup

### Using Terraform
```bash
terraform destroy
```

### Manual Cleanup
```bash
# Delete Lambda functions
aws lambda delete-function --function-name iot-sensor-processor
aws lambda delete-function --function-name iot-alert-sender

# Delete SNS topics
aws sns delete-topic --topic-arn YOUR_SENSOR_TOPIC_ARN
aws sns delete-topic --topic-arn YOUR_ALERT_TOPIC_ARN

# Delete DynamoDB table
aws dynamodb delete-table --table-name sensor-readings

# Delete IAM role
aws iam delete-role --role-name iot-lambda-role
```

## Troubleshooting Deployment

### Common Issues

#### 1. Terraform State Lock
```bash
# If terraform is locked
terraform force-unlock LOCK_ID
```

#### 2. Lambda Package Too Large
```bash
# Reduce package size
cd terraform
npm install --production
zip -r function.zip . -x "*.git*" "*.terraform*"
```

#### 3. IAM Permission Errors
- Ensure your AWS user has sufficient permissions
- Check AWS CloudTrail for detailed error messages

#### 4. SES Email Not Verified
- Check email inbox (including spam folder)
- Verify email in SES console
- Ensure correct region (SES is region-specific)

### Validation Commands

```bash
# Check SNS topics
aws sns list-topics --region us-east-2

# Check Lambda functions
aws lambda list-functions --region us-east-2

# Check DynamoDB tables
aws dynamodb list-tables --region us-east-2

# Check SES verified emails
aws ses list-verified-email-addresses --region us-east-2
```

## Multi-Environment Deployment

### Development Environment
```bash
terraform workspace new dev
terraform workspace select dev
terraform apply -var-file="dev.tfvars"
```

### Production Environment
```bash
terraform workspace new prod
terraform workspace select prod
terraform apply -var-file="prod.tfvars"
```

## Security Considerations

1. **Least Privilege**: IAM roles have minimal required permissions
2. **Encryption**: All data encrypted at rest and in transit
3. **Network**: Consider deploying in private subnets
4. **Monitoring**: Enable CloudTrail for audit logging

## Cost Optimization

1. **Lambda**: Use ARM-based Graviton2 processors
2. **DynamoDB**: Use on-demand billing for variable workloads
3. **CloudWatch**: Set log retention periods
4. **SNS**: Use message filtering to reduce costs

## Monitoring Setup

### CloudWatch Alarms
```bash
# Lambda error rate alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "IoT-Lambda-Errors" \
  --alarm-description "Lambda function errors" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold
```

### Dashboard Creation
- Import CloudWatch dashboard from `monitoring/dashboard.json`
- Customize metrics based on your requirements

## Backup and Recovery

### DynamoDB Backup
```bash
# Enable point-in-time recovery
aws dynamodb update-continuous-backups \
  --table-name sensor-readings \
  --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true
```

### Lambda Function Backup
- Lambda code is stored in deployment packages
- Terraform state includes all configuration
- Use version control for code backup

## Performance Tuning

### Lambda Optimization
- Increase memory allocation if needed
- Use provisioned concurrency for consistent performance
- Optimize cold start times

### DynamoDB Optimization
- Design efficient partition keys
- Use Global Secondary Indexes (GSI) for queries
- Monitor read/write capacity utilization

## Next Steps

After successful deployment:
1. Set up monitoring and alerting
2. Implement additional sensor types
3. Add data visualization dashboard
4. Configure backup and disaster recovery
5. Implement CI/CD pipeline