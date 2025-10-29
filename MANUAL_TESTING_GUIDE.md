# IoT Sensor Alert System - Manual Testing Guide

## Overview
This guide will help you manually test the IoT Sensor Alert System using AWS Management Console and Postman to verify all components are working correctly.

## System Architecture
```
Sensor Data → SNS Topic → Lambda Processor → DynamoDB + Alert SNS → Alert Lambda → SES Email
```

## Prerequisites
- AWS Management Console access
- Postman (or any REST client)
- Email access to check alerts

---

## Method 1: Testing via AWS Management Console

### Step 1: Test SNS Topic (Sensor Data)

1. **Navigate to SNS Console**
   - Go to AWS Console → SNS → Topics
   - Find topic: `iot-sensor-data`
   - Click on the topic

2. **Publish Test Message**
   - Click "Publish message"
   - **Subject**: `Sensor Data from sensor-test`
   - **Message body** (JSON):
   ```json
   {
     "sensor_id": "sensor-test-001",
     "location": "Test Room",
     "temperature": 35.5,
     "humidity": 15.2,
     "timestamp": "2025-10-29T12:00:00.000Z",
     "battery_level": 85.5
   }
   ```
   - Click "Publish message"

3. **Expected Result**: Message should be published successfully

### Step 2: Verify Lambda Processing

1. **Check Lambda Logs**
   - Go to AWS Console → CloudWatch → Log groups
   - Find `/aws/lambda/iot-sensor-processor`
   - Check latest log stream for processing messages

2. **Expected Log Entries**:
   ```
   Received event: {...}
   Processing sensor data: {...}
   Stored sensor reading: {...}
   Alert sent: {...}  // If thresholds exceeded
   ```

### Step 3: Verify DynamoDB Storage

1. **Navigate to DynamoDB Console**
   - Go to AWS Console → DynamoDB → Tables
   - Click on `sensor-readings` table
   - Click "Explore table items"

2. **Expected Result**: New item with your test data should appear

### Step 4: Verify Alert Processing

1. **Check Alert Lambda Logs**
   - Go to CloudWatch → Log groups
   - Find `/aws/lambda/iot-alert-sender`
   - Check for alert processing logs

2. **Expected Log Entries**:
   ```
   Received alert event: {...}
   Processing alert: {...}
   Email alert sent for: sensor-test-001
   ```

### Step 5: Verify Email Delivery

1. **Check Email Inbox** (`risox72951@ametitas.com`)
2. **Expected Email**:
   - Subject: `🚨 IoT Sensor Alert: HIGH_TEMPERATURE` or `LOW_HUMIDITY`
   - Body contains sensor details and alert information

---

## Method 2: Testing via Postman/REST Client

### Step 1: Get SNS Topic Endpoint

First, get the SNS topic ARN:
```bash
aws sns list-topics --region us-east-2 --query "Topics[?contains(TopicArn, 'iot-sensor-data')].TopicArn" --output text
```

### Step 2: Create Postman Collection

**Note**: Direct HTTP publishing to SNS requires AWS signature. Instead, use AWS CLI or SDK.

**Alternative: Use AWS CLI in Postman Pre-request Script**
```javascript
// Pre-request Script
pm.sendRequest({
    url: 'http://localhost:3000/publish-sensor-data',  // Your local proxy
    method: 'POST',
    header: {
        'Content-Type': 'application/json'
    },
    body: {
        mode: 'raw',
        raw: JSON.stringify({
            sensor_id: "sensor-postman-001",
            location: "Postman Test Room",
            temperature: 40.5,
            humidity: 10.2,
            timestamp: new Date().toISOString(),
            battery_level: 75.0
        })
    }
}, function (err, response) {
    console.log(response.json());
});
```

### Step 3: Create Local Proxy (Optional)

Create a simple Node.js proxy to publish to SNS:

```javascript
// sns-proxy.js
const AWS = require('@aws-sdk/client-sns');
const express = require('express');
const app = express();

const sns = new AWS.SNSClient({ region: 'us-east-2' });
const TOPIC_ARN = 'arn:aws:sns:us-east-2:064754721606:iot-sensor-data';

app.use(express.json());

app.post('/publish-sensor-data', async (req, res) => {
    try {
        const result = await sns.send(new AWS.PublishCommand({
            TopicArn: TOPIC_ARN,
            Message: JSON.stringify(req.body),
            Subject: `Sensor Data from ${req.body.sensor_id}`
        }));
        res.json({ success: true, messageId: result.MessageId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(3000, () => console.log('SNS Proxy running on port 3000'));
```

---

## Method 3: Direct AWS CLI Testing

### Test Normal Reading
```bash
aws sns publish \
  --topic-arn "arn:aws:sns:us-east-2:064754721606:iot-sensor-data" \
  --message '{"sensor_id":"sensor-cli-001","location":"CLI Test Room","temperature":22.5,"humidity":45.0,"timestamp":"2025-10-29T12:00:00.000Z","battery_level":90.0}' \
  --subject "Sensor Data from sensor-cli-001" \
  --region us-east-2
```

### Test High Temperature Alert
```bash
aws sns publish \
  --topic-arn "arn:aws:sns:us-east-2:064754721606:iot-sensor-data" \
  --message '{"sensor_id":"sensor-cli-002","location":"CLI Test Room","temperature":35.0,"humidity":45.0,"timestamp":"2025-10-29T12:00:00.000Z","battery_level":90.0}' \
  --subject "Sensor Data from sensor-cli-002" \
  --region us-east-2
```

### Test Low Humidity Alert
```bash
aws sns publish \
  --topic-arn "arn:aws:sns:us-east-2:064754721606:iot-sensor-data" \
  --message '{"sensor_id":"sensor-cli-003","location":"CLI Test Room","temperature":25.0,"humidity":15.0,"timestamp":"2025-10-29T12:00:00.000Z","battery_level":90.0}' \
  --subject "Sensor Data from sensor-cli-003" \
  --region us-east-2
```

---

## Verification Checklist

### ✅ Component Verification Steps

#### 1. SNS Topic Verification
- [ ] Message published successfully
- [ ] No errors in SNS console
- [ ] Message appears in topic metrics

#### 2. Lambda Processor Verification
- [ ] Function triggered by SNS
- [ ] Logs show message processing
- [ ] No errors in CloudWatch logs
- [ ] Execution duration reasonable (<30s)

#### 3. DynamoDB Verification
- [ ] New items appear in table
- [ ] Data structure is correct
- [ ] Timestamp is properly stored
- [ ] All sensor fields present

#### 4. Alert System Verification
- [ ] Alerts triggered for threshold violations
- [ ] Alert SNS topic receives messages
- [ ] Alert Lambda processes messages
- [ ] No errors in alert processing

#### 5. Email Delivery Verification
- [ ] Emails received in inbox
- [ ] Email format is correct
- [ ] Alert details are accurate
- [ ] HTML and text versions work

### 🔍 Troubleshooting Commands

#### Check Lambda Function Status
```bash
aws lambda get-function --function-name iot-sensor-processor --region us-east-2
aws lambda get-function --function-name iot-alert-sender --region us-east-2
```

#### Check Recent Lambda Invocations
```bash
aws logs filter-log-events \
  --log-group-name "/aws/lambda/iot-sensor-processor" \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --region us-east-2
```

#### Check DynamoDB Item Count
```bash
aws dynamodb scan \
  --table-name sensor-readings \
  --select COUNT \
  --region us-east-2
```

#### Check SNS Topic Subscriptions
```bash
aws sns list-subscriptions-by-topic \
  --topic-arn "arn:aws:sns:us-east-2:064754721606:iot-sensor-data" \
  --region us-east-2
```

#### Check SES Sending Statistics
```bash
aws ses get-send-statistics --region us-east-2
```

---

## Test Scenarios

### Scenario 1: Normal Operation
- **Input**: Temperature 20-30°C, Humidity 20-80%
- **Expected**: Data stored, no alerts

### Scenario 2: High Temperature Alert
- **Input**: Temperature > 30°C
- **Expected**: Data stored + email alert

### Scenario 3: Low Temperature Alert
- **Input**: Temperature < 10°C
- **Expected**: Data stored + email alert

### Scenario 4: High Humidity Alert
- **Input**: Humidity > 80%
- **Expected**: Data stored + email alert

### Scenario 5: Low Humidity Alert
- **Input**: Humidity < 20%
- **Expected**: Data stored + email alert

### Scenario 6: Multiple Alerts
- **Input**: Temperature > 30°C AND Humidity < 20%
- **Expected**: Data stored + 2 separate email alerts

---

## Performance Metrics to Monitor

1. **Lambda Duration**: Should be < 5 seconds
2. **DynamoDB Write Latency**: Should be < 100ms
3. **Email Delivery Time**: Should be < 30 seconds
4. **Error Rate**: Should be 0%
5. **Throughput**: System should handle multiple concurrent messages

---

## Success Criteria

✅ **System is working correctly if:**
1. All SNS messages are processed without errors
2. All sensor data is stored in DynamoDB
3. Alerts are triggered for threshold violations
4. Email notifications are delivered promptly
5. No errors in CloudWatch logs
6. All AWS resources are healthy

## Next Steps

After successful testing:
1. Set up CloudWatch alarms for monitoring
2. Configure auto-scaling if needed
3. Set up backup and disaster recovery
4. Implement additional sensors
5. Add dashboard for monitoring