# IoT Sensor Alert System Setup Script
# This script helps set up the development environment on Windows

Write-Host "🚀 IoT Sensor Alert System Setup" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Function to check if a command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Check if required tools are installed
Write-Host "📋 Checking required tools..." -ForegroundColor Yellow

$tools = @("aws", "terraform", "node", "python")
$allToolsInstalled = $true

foreach ($tool in $tools) {
    if (Test-Command $tool) {
        Write-Host "✅ $tool is installed" -ForegroundColor Green
    } else {
        Write-Host "❌ $tool is not installed. Please install it first." -ForegroundColor Red
        $allToolsInstalled = $false
    }
}

if (-not $allToolsInstalled) {
    Write-Host "Please install missing tools and run this script again." -ForegroundColor Red
    exit 1
}

# Check AWS credentials
Write-Host "🔐 Checking AWS credentials..." -ForegroundColor Yellow
try {
    $accountInfo = aws sts get-caller-identity --query 'Account' --output text 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ AWS credentials are configured" -ForegroundColor Green
        Write-Host "Account ID: $accountInfo" -ForegroundColor Cyan
    } else {
        throw "AWS credentials not configured"
    }
} catch {
    Write-Host "❌ AWS credentials not configured. Run 'aws configure' first." -ForegroundColor Red
    exit 1
}

# Set up Terraform variables
Write-Host "⚙️ Setting up Terraform configuration..." -ForegroundColor Yellow
Set-Location terraform

if (-not (Test-Path "terraform.tfvars")) {
    Copy-Item "terraform.tfvars.example" "terraform.tfvars"
    Write-Host "📝 Created terraform.tfvars from example" -ForegroundColor Green
    Write-Host "⚠️  Please edit terraform.tfvars with your email address and preferred region" -ForegroundColor Yellow
    Write-Host "   File location: terraform/terraform.tfvars" -ForegroundColor Cyan
} else {
    Write-Host "✅ terraform.tfvars already exists" -ForegroundColor Green
}

# Install Node.js dependencies
Write-Host "📦 Installing Node.js dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Node.js dependencies installed" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install Node.js dependencies" -ForegroundColor Red
    exit 1
}

Set-Location ..

# Install Python dependencies
Write-Host "🐍 Installing Python dependencies..." -ForegroundColor Yellow
try {
    python -m pip install -r requirements.txt
    Write-Host "✅ Python dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install Python dependencies" -ForegroundColor Red
    exit 1
}

# Initialize Terraform
Write-Host "🏗️ Initializing Terraform..." -ForegroundColor Yellow
Set-Location terraform
terraform init
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Terraform initialized" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to initialize Terraform" -ForegroundColor Red
    exit 1
}

Set-Location ..

Write-Host ""
Write-Host "🎉 Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit terraform/terraform.tfvars with your email address" -ForegroundColor White
Write-Host "2. Run 'terraform plan' to review the infrastructure" -ForegroundColor White
Write-Host "3. Run 'terraform apply' to deploy the system" -ForegroundColor White
Write-Host "4. Test with: python sensor_simulator.py --topic-arn YOUR_TOPIC_ARN" -ForegroundColor White
Write-Host ""
Write-Host "For detailed instructions, see docs/DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan