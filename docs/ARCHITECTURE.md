# 🏗️ System Architecture

## Overview

The IoT Sensor Alert System is built using a serverless, event-driven architecture on AWS. This design ensures high availability, automatic scaling, and cost-effectiveness.

## Architecture Diagram

```
┌─────────────┐    ┌─────────────┐    ┌─────────────────┐    ┌─────────────┐
│             │    │             │    │                 │    │             │
│ IoT Sensors │───▶│  SNS Topic  │───▶│ Lambda Processor│───▶│  DynamoDB   │
│             │    │ sensor-data │    │                 │    │   Table     │
└─────────────┘    └─────────────┘    └─────────────────┘    └─────────────┘
                                               │
                                               ▼
                                      ┌─────────────┐    ┌─────────────────┐    ┌─────────────┐
                                      │  SNS Topic  │───▶│ Lambda Alert    │───▶│     SES     │
                                      │   alerts    │    │    Sender       │    │   Email     │
                                      └─────────────┘    └─────────────────┘    └─────────────┘
```

## Components

### 1. Data Ingestion Layer

#### Amazon SNS (Simple Notification Service)
- **Topic**: `iot-sensor-data`
- **Purpose**: Receives sensor data from IoT devices
- **Message Format**: JSON with sensor readings
- **Scalability**: Handles millions of messages per second
- **Durability**: Messages are stored redundantly

**Message Schema:**
```json
{
  "sensor_id": "string",
  "location": "string", 
  "temperature": "number",
  "humidity": "number",
  "timestamp": "ISO 8601 string",
  "battery_level": "number"
}
```

### 2. Processing Layer

#### AWS Lambda - Sensor Processor
- **Function Name**: `iot-sensor-processor`
- **Runtime**: Node.js 18.x
- **Memory**: 128 MB (configurable)
- **Timeout**: 30 seconds
- **Trigger**: SNS topic subscription

**Responsibilities:**
1. Parse incoming sensor data
2. Validate data format
3. Store data in DynamoDB
4. Check threshold violations
5. Publish alerts to alert SNS topic

**Environment Variables:**
- `DYNAMODB_TABLE`: Target table name
- `ALERT_TOPIC_ARN`: Alert SNS topic ARN

### 3. Storage Layer

#### Amazon DynamoDB
- **Table Name**: `sensor-readings`
- **Partition Key**: `sensor_id` (String)
- **Sort Key**: `timestamp` (Number)
- **Billing Mode**: Pay-per-request
- **Encryption**: Server-side encryption enabled

**Item Structure:**
```json
{
  "sensor_id": "sensor-001",
  "timestamp": 1698580800000,
  "temperature": 25.5,
  "humidity": 60.2,
  "location": "Room 1",
  "battery_level": 85.5
}
```

**Access Patterns:**
- Query by sensor_id and time range
- Scan for recent readings
- Point lookups by sensor_id + timestamp

### 4. Alert Processing Layer

#### Amazon SNS - Alert Topic
- **Topic**: `iot-sensor-alerts`
- **Purpose**: Distributes alert notifications
- **Subscribers**: Lambda alert sender function

#### AWS Lambda - Alert Sender
- **Function Name**: `iot-alert-sender`
- **Runtime**: Node.js 18.x
- **Memory**: 128 MB
- **Timeout**: 30 seconds
- **Trigger**: Alert SNS topic subscription

**Responsibilities:**
1. Process alert messages
2. Format email content (HTML + text)
3. Send emails via SES
4. Log delivery status

### 5. Notification Layer

#### Amazon SES (Simple Email Service)
- **Purpose**: Delivers email alerts
- **Configuration**: Verified email identity
- **Features**: HTML and text email support
- **Monitoring**: Bounce and complaint tracking

## Data Flow

### Normal Operation Flow
1. **Sensor Data Ingestion**
   - IoT device publishes JSON message to SNS topic
   - SNS triggers Lambda processor function

2. **Data Processing**
   - Lambda validates message format
   - Stores data in DynamoDB table
   - Checks threshold values

3. **Data Storage**
   - DynamoDB stores sensor reading
   - Automatic scaling based on demand

### Alert Flow
1. **Threshold Detection**
   - Lambda processor identifies threshold violation
   - Creates alert message with details

2. **Alert Publishing**
   - Alert published to alert SNS topic
   - SNS triggers alert Lambda function

3. **Email Delivery**
   - Alert Lambda formats email content
   - SES delivers email to configured recipient
   - Delivery status logged

## Threshold Configuration

### Temperature Thresholds
- **Low**: < 10°C
- **High**: > 30°C

### Humidity Thresholds
- **Low**: < 20%
- **High**: > 80%

### Alert Types
- `HIGH_TEMPERATURE`
- `LOW_TEMPERATURE`
- `HIGH_HUMIDITY`
- `LOW_HUMIDITY`

## Security Architecture

### Identity and Access Management (IAM)

#### Lambda Execution Role
- **Role Name**: `iot-lambda-role`
- **Permissions**:
  - CloudWatch Logs: Create log groups and streams
  - DynamoDB: PutItem, GetItem, Query operations
  - SNS: Publish messages to alert topic
  - SES: Send emails

#### Principle of Least Privilege
- Each component has minimal required permissions
- No cross-service access beyond necessary operations
- Regular permission audits recommended

### Data Encryption
- **In Transit**: HTTPS/TLS for all API calls
- **At Rest**: DynamoDB server-side encryption
- **Email**: SES uses TLS for email delivery

### Network Security
- All services operate within AWS managed infrastructure
- Optional: Deploy in VPC for additional isolation
- Security groups control network access

## Scalability and Performance

### Auto Scaling Components
- **Lambda**: Automatic scaling up to 1000 concurrent executions
- **DynamoDB**: On-demand scaling for read/write capacity
- **SNS**: Handles millions of messages per second
- **SES**: Scales based on sending limits

### Performance Characteristics
- **End-to-end Latency**: < 5 seconds typical
- **Throughput**: 1000+ messages per second
- **Availability**: 99.9% (multi-AZ deployment)

### Bottleneck Analysis
- **Lambda Cold Starts**: 100-500ms initial delay
- **DynamoDB**: Single-digit millisecond latency
- **SNS**: Sub-second message delivery
- **SES**: 1-5 seconds email delivery

## Monitoring and Observability

### CloudWatch Metrics
- Lambda invocations, duration, errors
- DynamoDB consumed capacity, throttles
- SNS messages published, delivery success
- SES bounce rate, complaint rate

### Log Aggregation
- Centralized logging in CloudWatch
- Structured JSON log format
- Correlation IDs for request tracing

### Alerting Strategy
- CloudWatch Alarms for error rates
- SNS notifications for system alerts
- Dashboard for real-time monitoring

## Disaster Recovery

### Backup Strategy
- **DynamoDB**: Point-in-time recovery enabled
- **Lambda**: Code stored in version control
- **Configuration**: Infrastructure as Code (Terraform)

### Recovery Procedures
- **RTO** (Recovery Time Objective): < 1 hour
- **RPO** (Recovery Point Objective): < 15 minutes
- **Multi-region**: Can be deployed across regions

### Failure Scenarios
- **Lambda Failure**: Automatic retry with exponential backoff
- **DynamoDB Throttling**: Automatic scaling response
- **SNS Delivery Failure**: Built-in retry mechanism
- **SES Bounce**: Automatic bounce handling

## Cost Optimization

### Pricing Model
- **Lambda**: Pay per invocation and duration
- **DynamoDB**: Pay per read/write request
- **SNS**: Pay per message published
- **SES**: Pay per email sent

### Cost Optimization Strategies
1. **Right-sizing**: Optimize Lambda memory allocation
2. **Efficient Queries**: Use DynamoDB best practices
3. **Message Filtering**: Reduce unnecessary processing
4. **Log Retention**: Set appropriate retention periods

### Estimated Monthly Costs (1000 readings/day)
- Lambda: ~$0.20
- DynamoDB: ~$1.25
- SNS: ~$0.50
- SES: ~$0.10
- **Total**: ~$2.05/month

## Future Enhancements

### Potential Improvements
1. **Real-time Dashboard**: Add visualization layer
2. **Machine Learning**: Predictive analytics for anomalies
3. **Multi-tenancy**: Support multiple customers
4. **API Gateway**: REST API for sensor management
5. **Stream Processing**: Real-time analytics with Kinesis

### Scalability Considerations
- **Global Distribution**: Multi-region deployment
- **Edge Processing**: AWS IoT Greengrass integration
- **Data Archival**: S3 for long-term storage
- **Analytics**: Integration with AWS Analytics services

## Technology Decisions

### Why Serverless?
- **No Infrastructure Management**: Focus on business logic
- **Automatic Scaling**: Handle variable workloads
- **Cost Effective**: Pay only for usage
- **High Availability**: Built-in redundancy

### Why DynamoDB?
- **Single-digit Millisecond Latency**: Fast data access
- **Automatic Scaling**: Handle traffic spikes
- **Managed Service**: No database administration
- **Integration**: Native AWS service integration

### Why SNS?
- **Decoupling**: Loose coupling between components
- **Fan-out**: Multiple subscribers per topic
- **Durability**: Message persistence and retry
- **Integration**: Native Lambda triggers

This architecture provides a robust, scalable, and cost-effective solution for IoT sensor monitoring with real-time alerting capabilities.