# 🌡️ IoT Sensor Alert System

[![Validate Infrastructure](https://github.com/yourusername/iot-sensor-alert-system/actions/workflows/validate.yml/badge.svg)](https://github.com/yourusername/iot-sensor-alert-system/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Serverless-orange.svg)](https://aws.amazon.com/)
[![Node.js](https://img.shields.io/badge/Node.js-18.x-green.svg)](https://nodejs.org/)

A serverless, event-driven IoT sensor monitoring system built on AWS that processes sensor data in real-time and sends email alerts when thresholds are exceeded.

> **Note**: Replace `yourusername` in the badge URLs above with your actual GitHub username after creating the repository.

## 🏗️ Architecture Overview

```
IoT Sensors → SNS Topic → Lambda Processor → DynamoDB + Alert SNS → Alert Lambda → SES Email
```

The system follows an event-driven architecture where:
1. **Sensor data** is published to an SNS topic
2. **Lambda processor** stores data in DynamoDB and checks thresholds
3. **Alert system** sends email notifications for threshold violations
4. **All components** are serverless and auto-scaling

## 🚀 Features

- ✅ **Real-time processing** of IoT sensor data
- ✅ **Automatic threshold monitoring** (temperature & humidity)
- ✅ **Email alerts** for anomalies
- ✅ **Serverless architecture** (no servers to manage)
- ✅ **Auto-scaling** based on demand
- ✅ **Cost-effective** (pay-per-use)
- ✅ **Infrastructure as Code** (Terraform)
- ✅ **Comprehensive testing** suite

## 📊 AWS Services Used

| Service | Purpose | Configuration |
|---------|---------|---------------|
| **Amazon SNS** | Message queuing and pub/sub | 2 topics (sensor data + alerts) |
| **AWS Lambda** | Serverless compute | 2 functions (processor + alerter) |
| **Amazon DynamoDB** | NoSQL database | Single table with composite key |
| **Amazon SES** | Email delivery | Verified email identity |
| **AWS IAM** | Security and permissions | Roles and policies for Lambda |
| **Amazon CloudWatch** | Monitoring and logging | Log groups for debugging |

## 🛠️ Technology Stack

- **Infrastructure**: Terraform
- **Runtime**: Node.js 18.x
- **AWS SDK**: v3 (latest)
- **Database**: DynamoDB (NoSQL)
- **Messaging**: SNS (Simple Notification Service)
- **Email**: SES (Simple Email Service)
- **Monitoring**: CloudWatch

## 📁 Project Structure

```
iot-sensor-alert-system/
├── terraform/                 # Infrastructure as Code
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Input variables
│   ├── terraform.tfvars       # Variable values
│   ├── index.js              # Sensor processor Lambda
│   ├── alert.js              # Alert sender Lambda
│   ├── package.json          # Node.js dependencies
│   └── *.zip                 # Lambda deployment packages
├── test_scripts/             # Testing automation
│   ├── verify_system.ps1     # System verification
│   ├── test_normal_reading.ps1
│   ├── test_high_temp_alert.ps1
│   ├── test_low_humidity_alert.ps1
│   └── test_multiple_alerts.ps1
├── postman/                  # API testing
│   └── IoT_Sensor_Testing.postman_collection.json
├── docs/                     # Documentation
│   ├── MANUAL_TESTING_GUIDE.md
│   ├── DEPLOYMENT_GUIDE.md
│   └── TROUBLESHOOTING.md
├── sensor_simulator.py       # Python sensor simulator
├── sns-proxy-server.js       # Testing proxy server
├── deploy.ps1               # PowerShell deployment
├── deploy.sh                # Bash deployment
└── README.md                # This file
```

## 🚦 Alert Thresholds

| Metric | Low Alert | High Alert |
|--------|-----------|------------|
| **Temperature** | < 10°C | > 30°C |
| **Humidity** | < 20% | > 80% |

## 🔧 Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Node.js >= 18.x
- Python 3.x (for sensor simulator)
- PowerShell (for Windows deployment scripts)

## 📦 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/iot-sensor-alert-system.git
cd iot-sensor-alert-system
```

### 2. Automated Setup (Recommended)
```bash
# Linux/Mac
./setup.sh

# Windows PowerShell
./setup.ps1
```

### 3. Manual Setup (Alternative)
```bash
# Copy the example file and edit with your values
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS region and email

# Install dependencies
npm install
pip install -r requirements.txt
```

Example `terraform.tfvars`:
```hcl
aws_region = "us-east-2"
alert_email = "your-email@example.com"
```

### 4. Deploy Infrastructure
```bash
# Using Terraform
cd terraform
terraform init
terraform plan
terraform apply

# OR using deployment scripts
# Windows
./deploy.ps1

# Linux/Mac
./deploy.sh
```

### 5. Test the System
```bash
# Run sensor simulator
python sensor_simulator.py --topic-arn YOUR_SNS_TOPIC_ARN --count 5

# OR use PowerShell test scripts
./test_scripts/test_normal_reading.ps1
./test_scripts/test_high_temp_alert.ps1
```

## 🧪 Testing

### Automated Testing
```bash
# System verification
./test_scripts/verify_system.ps1

# Individual test scenarios
./test_scripts/test_normal_reading.ps1      # No alerts expected
./test_scripts/test_high_temp_alert.ps1     # High temperature alert
./test_scripts/test_low_humidity_alert.ps1  # Low humidity alert
./test_scripts/test_multiple_alerts.ps1     # Multiple alerts
```

### Manual Testing
1. **AWS Console**: Use SNS to publish test messages
2. **Postman**: Import collection from `postman/` directory
3. **Python Simulator**: Use `sensor_simulator.py` for realistic data

See [MANUAL_TESTING_GUIDE.md](docs/MANUAL_TESTING_GUIDE.md) for detailed instructions.

## 📈 Monitoring

### CloudWatch Dashboards
- Lambda function metrics (duration, errors, invocations)
- DynamoDB metrics (read/write capacity, throttles)
- SNS metrics (messages published, delivery success)

### Log Groups
- `/aws/lambda/iot-sensor-processor` - Sensor data processing logs
- `/aws/lambda/iot-alert-sender` - Alert delivery logs

### Key Metrics to Monitor
- **Lambda Duration**: Should be < 5 seconds
- **Error Rate**: Should be 0%
- **DynamoDB Throttles**: Should be 0
- **Email Delivery Rate**: Should be 100%

## 💰 Cost Estimation

Based on 1000 sensor readings per day:

| Service | Monthly Cost (USD) |
|---------|-------------------|
| Lambda | ~$0.20 |
| DynamoDB | ~$1.25 |
| SNS | ~$0.50 |
| SES | ~$0.10 |
| **Total** | **~$2.05** |

*Costs may vary based on usage patterns and AWS region*

## 🔒 Security

- **IAM Roles**: Least privilege access for Lambda functions
- **VPC**: Can be deployed in private subnets (optional)
- **Encryption**: Data encrypted at rest and in transit
- **SES**: Email sending restricted to verified identities

## 🚀 Deployment Options

### Option 1: Terraform (Recommended)
```bash
cd terraform
terraform init
terraform apply
```

### Option 2: AWS CLI Scripts
```bash
# Windows
./deploy.ps1

# Linux/Mac  
./deploy.sh
```

### Option 3: Manual Deployment
Follow the step-by-step guide in [DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md)

## 🔍 Troubleshooting

### Common Issues

1. **Lambda Import Errors**
   - Ensure AWS SDK v3 dependencies are included
   - Check Node.js runtime version (18.x)

2. **Email Not Delivered**
   - Verify SES email identity
   - Check spam folder
   - Review SES sending limits

3. **DynamoDB Access Denied**
   - Verify IAM role permissions
   - Check table name in environment variables

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for detailed solutions.

## 📊 Sample Data

### Normal Sensor Reading
```json
{
  "sensor_id": "sensor-001",
  "location": "Room 1",
  "temperature": 22.5,
  "humidity": 45.0,
  "timestamp": "2025-10-29T12:00:00.000Z",
  "battery_level": 85.5
}
```

### Alert-Triggering Reading
```json
{
  "sensor_id": "sensor-002", 
  "location": "Room 2",
  "temperature": 35.8,
  "humidity": 12.3,
  "timestamp": "2025-10-29T12:05:00.000Z",
  "battery_level": 78.2
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- AWS Documentation and Best Practices
- Terraform AWS Provider
- Node.js AWS SDK v3


---

## 🏷️ Tags

`aws` `iot` `serverless` `lambda` `sns` `dynamodb` `ses` `terraform` `nodejs` `real-time` `monitoring` `alerts`

---

**⭐ If this project helped you, please give it a star!**
