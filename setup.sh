#!/bin/bash

# IoT Sensor Alert System Setup Script
# This script helps set up the development environment

set -e

echo "🚀 IoT Sensor Alert System Setup"
echo "================================="

# Check if required tools are installed
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is not installed. Please install it first."
        exit 1
    else
        echo "✅ $1 is installed"
    fi
}

echo "📋 Checking required tools..."
check_tool "aws"
check_tool "terraform"
check_tool "node"
check_tool "python3"

# Check AWS credentials
echo "🔐 Checking AWS credentials..."
if aws sts get-caller-identity &> /dev/null; then
    echo "✅ AWS credentials are configured"
    aws sts get-caller-identity --query 'Account' --output text | xargs echo "Account ID:"
else
    echo "❌ AWS credentials not configured. Run 'aws configure' first."
    exit 1
fi

# Set up Terraform variables
echo "⚙️ Setting up Terraform configuration..."
cd terraform

if [ ! -f "terraform.tfvars" ]; then
    cp terraform.tfvars.example terraform.tfvars
    echo "📝 Created terraform.tfvars from example"
    echo "⚠️  Please edit terraform.tfvars with your email address and preferred region"
    echo "   File location: terraform/terraform.tfvars"
else
    echo "✅ terraform.tfvars already exists"
fi

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
npm install
echo "✅ Node.js dependencies installed"

cd ..

# Install Python dependencies
echo "🐍 Installing Python dependencies..."
if command -v pip3 &> /dev/null; then
    pip3 install -r requirements.txt
elif command -v pip &> /dev/null; then
    pip install -r requirements.txt
else
    echo "❌ pip not found. Please install Python pip."
    exit 1
fi
echo "✅ Python dependencies installed"

# Initialize Terraform
echo "🏗️ Initializing Terraform..."
cd terraform
terraform init
echo "✅ Terraform initialized"

cd ..

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit terraform/terraform.tfvars with your email address"
echo "2. Run 'terraform plan' to review the infrastructure"
echo "3. Run 'terraform apply' to deploy the system"
echo "4. Test with: python sensor_simulator.py --topic-arn YOUR_TOPIC_ARN"
echo ""
echo "For detailed instructions, see docs/DEPLOYMENT_GUIDE.md"