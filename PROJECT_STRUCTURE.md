# 📁 Project Structure

This document provides a comprehensive overview of the IoT Sensor Alert System project structure and file organization.

## 🗂️ Directory Structure

```
iot-sensor-alert-system/
├── 📁 terraform/                    # Infrastructure as Code
│   ├── 🔧 main.tf                   # Main Terraform configuration
│   ├── 📝 variables.tf              # Input variables definition
│   ├── 📊 outputs.tf                # Output values
│   ├── ⚙️ terraform.tfvars          # Variable values (gitignored)
│   ├── 🔧 index.js                  # Sensor processor Lambda function
│   ├── 📧 alert.js                  # Alert sender Lambda function
│   ├── 📦 package.json              # Node.js dependencies
│   ├── 📦 package-lock.json         # Dependency lock file
│   ├── 📁 node_modules/             # Node.js modules (gitignored)
│   ├── 📦 sensor_processor.zip      # Lambda deployment package
│   └── 📦 alert_sender.zip          # Lambda deployment package
├── 📁 test_scripts/                 # Testing automation scripts
│   ├── 🔍 verify_system.ps1         # System health verification
│   ├── ✅ test_normal_reading.ps1    # Normal reading test
│   ├── 🌡️ test_high_temp_alert.ps1   # High temperature alert test
│   ├── 💧 test_low_humidity_alert.ps1 # Low humidity alert test
│   └── 🚨 test_multiple_alerts.ps1   # Multiple alerts test
├── 📁 postman/                      # API testing collection
│   └── 📋 IoT_Sensor_Testing.postman_collection.json
├── 📁 docs/                         # Documentation
│   ├── 📖 MANUAL_TESTING_GUIDE.md   # Manual testing instructions
│   ├── 🚀 DEPLOYMENT_GUIDE.md       # Deployment instructions
│   ├── 🔧 TROUBLESHOOTING.md        # Troubleshooting guide
│   └── 🏗️ ARCHITECTURE.md           # System architecture details
├── 🐍 sensor_simulator.py           # Python sensor data simulator
├── 🌐 sns-proxy-server.js           # Testing proxy server
├── 📦 package.json                  # Proxy server dependencies
├── 🚀 deploy.ps1                    # PowerShell deployment script
├── 🚀 deploy.sh                     # Bash deployment script
├── 📖 README.md                     # Main project documentation
├── 🤝 CONTRIBUTING.md               # Contribution guidelines
├── 📁 PROJECT_STRUCTURE.md          # This file
├── ⚖️ LICENSE                       # MIT License
└── 🚫 .gitignore                    # Git ignore rules
```

## 📋 File Descriptions

### 🏗️ Infrastructure (terraform/)

#### Core Terraform Files
- **`main.tf`** - Main infrastructure configuration
  - SNS topics for sensor data and alerts
  - Lambda functions for processing and alerting
  - DynamoDB table for data storage
  - SES email identity for notifications
  - IAM roles and policies

- **`variables.tf`** - Input variable definitions
  - AWS region configuration
  - Alert email address
  - Threshold values for temperature and humidity
  - Lambda function settings

- **`outputs.tf`** - Output values after deployment
  - SNS topic ARNs
  - Lambda function names and ARNs
  - DynamoDB table details
  - Testing commands

- **`terraform.tfvars`** - Variable values (not in git)
  - Contains sensitive configuration values
  - Must be created manually

#### Lambda Functions
- **`index.js`** - Sensor data processor
  - Processes incoming sensor data from SNS
  - Stores data in DynamoDB
  - Checks thresholds and triggers alerts
  - Uses AWS SDK v3

- **`alert.js`** - Alert email sender
  - Processes alert messages from SNS
  - Formats HTML and text emails
  - Sends notifications via SES
  - Logs delivery status

- **`package.json`** - Node.js dependencies
  - AWS SDK v3 client libraries
  - DynamoDB document client
  - SNS and SES clients

### 🧪 Testing (test_scripts/)

#### PowerShell Test Scripts
- **`verify_system.ps1`** - Comprehensive system health check
  - Verifies all AWS resources
  - Checks recent logs and metrics
  - Validates configuration

- **`test_normal_reading.ps1`** - Tests normal sensor operation
  - Publishes data within normal thresholds
  - Verifies data storage without alerts

- **`test_high_temp_alert.ps1`** - Tests high temperature alerts
  - Publishes data exceeding temperature threshold
  - Verifies alert email delivery

- **`test_low_humidity_alert.ps1`** - Tests low humidity alerts
  - Publishes data below humidity threshold
  - Verifies alert processing

- **`test_multiple_alerts.ps1`** - Tests multiple simultaneous alerts
  - Publishes data violating multiple thresholds
  - Verifies multiple alert emails

### 📋 API Testing (postman/)

- **`IoT_Sensor_Testing.postman_collection.json`** - Postman collection
  - Pre-configured API requests
  - Test scenarios for different alert types
  - Environment variables for easy configuration

### 📚 Documentation (docs/)

- **`MANUAL_TESTING_GUIDE.md`** - Step-by-step testing instructions
  - AWS Console testing procedures
  - Postman setup and usage
  - Verification checklists

- **`DEPLOYMENT_GUIDE.md`** - Comprehensive deployment guide
  - Prerequisites and setup
  - Multiple deployment methods
  - Post-deployment verification

- **`TROUBLESHOOTING.md`** - Problem resolution guide
  - Common issues and solutions
  - Diagnostic commands
  - Recovery procedures

- **`ARCHITECTURE.md`** - Detailed system architecture
  - Component descriptions
  - Data flow diagrams
  - Security and scalability considerations

### 🔧 Utilities

- **`sensor_simulator.py`** - Python sensor data generator
  - Simulates realistic IoT sensor data
  - Configurable anomaly generation
  - Command-line interface

- **`sns-proxy-server.js`** - Local testing proxy
  - Express.js server for Postman testing
  - Publishes messages to AWS SNS
  - Provides verification endpoints

### 🚀 Deployment Scripts

- **`deploy.ps1`** - Windows PowerShell deployment
  - Automated AWS resource creation
  - Error handling and validation
  - Progress reporting

- **`deploy.sh`** - Linux/Mac Bash deployment
  - Cross-platform deployment script
  - AWS CLI integration
  - Status monitoring

### 📄 Project Files

- **`README.md`** - Main project documentation
  - Project overview and features
  - Quick start guide
  - Architecture summary

- **`CONTRIBUTING.md`** - Contribution guidelines
  - Development setup
  - Coding standards
  - Pull request process

- **`LICENSE`** - MIT License
  - Open source license terms
  - Usage permissions and limitations

- **`.gitignore`** - Git ignore rules
  - Excludes sensitive files
  - Ignores build artifacts
  - Prevents accidental commits

## 🔄 File Dependencies

### Terraform Dependencies
```
main.tf
├── variables.tf (input variables)
├── terraform.tfvars (variable values)
├── index.js (Lambda function code)
├── alert.js (Lambda function code)
├── package.json (dependencies)
└── outputs.tf (output values)
```

### Lambda Function Dependencies
```
index.js / alert.js
├── package.json (AWS SDK dependencies)
├── node_modules/ (installed packages)
└── *.zip (deployment packages)
```

### Testing Dependencies
```
test_scripts/*.ps1
├── AWS CLI (for AWS operations)
├── Deployed infrastructure (SNS topics, etc.)
└── verify_system.ps1 (system validation)
```

## 📊 File Sizes (Approximate)

| File/Directory | Size | Description |
|----------------|------|-------------|
| `terraform/main.tf` | ~8KB | Infrastructure configuration |
| `terraform/index.js` | ~4KB | Sensor processor code |
| `terraform/alert.js` | ~3KB | Alert sender code |
| `terraform/node_modules/` | ~15MB | Node.js dependencies |
| `terraform/*.zip` | ~3MB each | Lambda deployment packages |
| `sensor_simulator.py` | ~5KB | Python simulator |
| `docs/` | ~50KB total | Documentation files |
| `test_scripts/` | ~10KB total | PowerShell test scripts |

## 🔐 Security Considerations

### Sensitive Files (Not in Git)
- `terraform/terraform.tfvars` - Contains email addresses
- `terraform/node_modules/` - May contain cached credentials
- `terraform/*.zip` - Deployment packages with dependencies
- `.env` files - Environment variables

### Public Files (Safe to Share)
- All documentation files
- Terraform configuration (without .tfvars)
- Test scripts (without hardcoded values)
- Source code files

## 🚀 Getting Started Workflow

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd iot-sensor-alert-system
   ```

2. **Configure Environment**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Install Dependencies**
   ```bash
   npm install
   ```

4. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform apply
   ```

5. **Test System**
   ```bash
   ../test_scripts/verify_system.ps1
   ```

This structure provides a clear separation of concerns, comprehensive testing capabilities, and thorough documentation for maintainability and collaboration.