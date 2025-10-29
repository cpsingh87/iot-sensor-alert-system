# 🔧 Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the IoT Sensor Alert System.

## 🚨 Common Issues

### 1. Lambda Function Errors

#### Issue: "Cannot find module 'aws-sdk'"
**Symptoms:**
- Lambda function fails with ImportModuleError
- CloudWatch logs show module not found

**Solution:**
```bash
cd terraform
npm install
# Recreate deployment package
zip -r sensor_processor.zip index.js node_modules package.json
zip -r alert_sender.zip alert.js node_modules package.json

# Update Lambda functions
aws lambda update-function-code --function-name iot-sensor-processor --zip-file fileb://sensor_processor.zip
aws lambda update-function-code --function-name iot-alert-sender --zip-file fileb://alert_sender.zip
```

#### Issue: Lambda timeout errors
**Symptoms:**
- Function execution exceeds timeout limit
- Partial data processing

**Solution:**
```bash
# Increase timeout (max 15 minutes)
aws lambda update-function-configuration \
  --function-name iot-sensor-processor \
  --timeout 30
```

#### Issue: Memory limit exceeded
**Symptoms:**
- Lambda function runs out of memory
- Performance degradation

**Solution:**
```bash
# Increase memory allocation
aws lambda update-function-configuration \
  --function-name iot-sensor-processor \
  --memory-size 256
```

### 2. DynamoDB Issues

#### Issue: Access denied to DynamoDB
**Symptoms:**
- Lambda cannot write to DynamoDB
- AccessDeniedException in logs

**Solution:**
```bash
# Check IAM role permissions
aws iam get-role-policy --role-name iot-lambda-role --policy-name iot-lambda-policy

# Verify table exists
aws dynamodb describe-table --table-name sensor-readings
```

#### Issue: DynamoDB throttling
**Symptoms:**
- ProvisionedThroughputExceededException
- High latency

**Solution:**
```bash
# Switch to on-demand billing
aws dynamodb modify-table \
  --table-name sensor-readings \
  --billing-mode PAY_PER_REQUEST
```

### 3. SNS Issues

#### Issue: Messages not being delivered
**Symptoms:**
- SNS publishes succeed but Lambda not triggered
- No processing logs

**Solution:**
```bash
# Check SNS subscriptions
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-2:ACCOUNT:iot-sensor-data

# Verify Lambda permissions
aws lambda get-policy --function-name iot-sensor-processor
```

#### Issue: SNS topic not found
**Symptoms:**
- Topic does not exist error
- Publishing fails

**Solution:**
```bash
# List existing topics
aws sns list-topics

# Create missing topic
aws sns create-topic --name iot-sensor-data
```

### 4. SES Email Issues

#### Issue: Email not being sent
**Symptoms:**
- No emails received
- SES sending fails

**Solution:**
```bash
# Check email verification status
aws ses get-identity-verification-attributes \
  --identities your-email@example.com

# Verify email if needed
aws ses verify-email-identity --email-address your-email@example.com
```

#### Issue: Emails going to spam
**Symptoms:**
- Emails delivered to spam folder
- Low delivery rate

**Solution:**
1. Set up SPF, DKIM, and DMARC records
2. Use verified domain instead of email
3. Improve email content and formatting

#### Issue: SES sending limits exceeded
**Symptoms:**
- Sending quota exceeded error
- Throttling errors

**Solution:**
```bash
# Check sending quota
aws ses get-send-quota

# Request limit increase through AWS Support
```

### 5. CloudWatch Logging Issues

#### Issue: No logs appearing
**Symptoms:**
- Lambda executes but no logs in CloudWatch
- Missing log groups

**Solution:**
```bash
# Check if log group exists
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/iot"

# Verify IAM permissions for logging
aws iam get-role-policy --role-name iot-lambda-role --policy-name iot-lambda-policy
```

## 🔍 Diagnostic Commands

### System Health Check
```bash
# Run comprehensive system verification
./test_scripts/verify_system.ps1
```

### Lambda Function Status
```bash
# Check function configuration
aws lambda get-function --function-name iot-sensor-processor
aws lambda get-function --function-name iot-alert-sender

# Check recent invocations
aws lambda get-function --function-name iot-sensor-processor --query 'Configuration.LastModified'
```

### DynamoDB Health
```bash
# Check table status
aws dynamodb describe-table --table-name sensor-readings --query 'Table.TableStatus'

# Check item count
aws dynamodb scan --table-name sensor-readings --select COUNT
```

### SNS Topic Health
```bash
# List topics
aws sns list-topics --query 'Topics[?contains(TopicArn, `iot`)]'

# Check subscriptions
aws sns list-subscriptions --query 'Subscriptions[?contains(TopicArn, `iot`)]'
```

### Recent Logs
```bash
# Get recent Lambda logs
aws logs filter-log-events \
  --log-group-name "/aws/lambda/iot-sensor-processor" \
  --start-time $(date -d '1 hour ago' +%s)000

# Get recent alert logs
aws logs filter-log-events \
  --log-group-name "/aws/lambda/iot-alert-sender" \
  --start-time $(date -d '1 hour ago' +%s)000
```

## 🧪 Testing and Validation

### Test Message Publishing
```bash
# Test normal message
aws sns publish \
  --topic-arn "arn:aws:sns:us-east-2:ACCOUNT:iot-sensor-data" \
  --message '{"sensor_id":"test-001","temperature":25.0,"humidity":50.0,"timestamp":"2025-10-29T12:00:00Z","battery_level":90.0}' \
  --subject "Test Message"
```

### Validate Data Flow
```bash
# 1. Publish test message
# 2. Check Lambda logs for processing
# 3. Verify data in DynamoDB
# 4. Check for alerts if thresholds exceeded
```

### End-to-End Test
```bash
# Use sensor simulator for comprehensive test
python sensor_simulator.py \
  --topic-arn "arn:aws:sns:us-east-2:ACCOUNT:iot-sensor-data" \
  --count 5 \
  --anomaly-chance 0.5
```

## 📊 Monitoring and Alerts

### Key Metrics to Monitor
- Lambda invocation count and duration
- Lambda error rate
- DynamoDB read/write capacity utilization
- SNS message delivery success rate
- SES bounce and complaint rates

### CloudWatch Alarms
```bash
# Lambda error alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "IoT-Lambda-Errors" \
  --alarm-description "Lambda function errors" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --dimensions Name=FunctionName,Value=iot-sensor-processor
```

## 🔧 Performance Issues

### Lambda Cold Starts
**Issue:** High latency on first invocation

**Solutions:**
1. Use provisioned concurrency
2. Implement connection pooling
3. Optimize package size

### DynamoDB Performance
**Issue:** High read/write latency

**Solutions:**
1. Optimize partition key design
2. Use Global Secondary Indexes
3. Enable DynamoDB Accelerator (DAX)

### SNS Message Processing
**Issue:** Message processing delays

**Solutions:**
1. Increase Lambda concurrency limits
2. Use SQS for message buffering
3. Implement batch processing

## 🚨 Emergency Procedures

### System Outage
1. Check AWS Service Health Dashboard
2. Review CloudWatch alarms
3. Check recent deployments
4. Verify IAM permissions
5. Contact AWS Support if needed

### Data Loss Prevention
1. Enable DynamoDB point-in-time recovery
2. Set up automated backups
3. Implement data validation
4. Monitor data integrity

### Security Incident Response
1. Review CloudTrail logs
2. Check for unauthorized access
3. Rotate access keys if compromised
4. Update security groups and policies

## 📞 Getting Help

### AWS Support
- **Basic Support:** Documentation and forums
- **Developer Support:** Technical support during business hours
- **Business Support:** 24/7 technical support

### Community Resources
- AWS Forums
- Stack Overflow (tag: aws-lambda, aws-sns, etc.)
- GitHub Issues

### Escalation Process
1. Check this troubleshooting guide
2. Review AWS documentation
3. Search community forums
4. Create GitHub issue
5. Contact AWS Support

## 🔄 Recovery Procedures

### Lambda Function Recovery
```bash
# Redeploy function from backup
terraform apply -target=aws_lambda_function.sensor_processor

# Or manual deployment
aws lambda update-function-code \
  --function-name iot-sensor-processor \
  --zip-file fileb://sensor_processor.zip
```

### DynamoDB Recovery
```bash
# Restore from backup
aws dynamodb restore-table-from-backup \
  --target-table-name sensor-readings-restored \
  --backup-arn BACKUP_ARN
```

### Complete System Recovery
```bash
# Full infrastructure recovery
terraform destroy
terraform apply
```

## 📝 Logging Best Practices

### Enable Detailed Logging
```javascript
// In Lambda functions
console.log('Processing sensor data:', JSON.stringify(sensorData, null, 2));
console.error('Error processing data:', error.message, error.stack);
```

### Log Retention
```bash
# Set log retention period
aws logs put-retention-policy \
  --log-group-name "/aws/lambda/iot-sensor-processor" \
  --retention-in-days 30
```

### Structured Logging
```javascript
// Use structured logging format
const log = {
  timestamp: new Date().toISOString(),
  level: 'INFO',
  message: 'Sensor data processed',
  sensorId: sensorData.sensor_id,
  temperature: sensorData.temperature
};
console.log(JSON.stringify(log));
```

Remember: Always test changes in a development environment before applying to production!