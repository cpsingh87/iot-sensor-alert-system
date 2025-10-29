# Repository Validation Script
# Ensures all files are ready for GitHub commit

Write-Host "🔍 Validating Repository for GitHub..." -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

$errors = 0

# Check for sensitive files
Write-Host "🔐 Checking for sensitive files..." -ForegroundColor Yellow

$sensitiveFiles = @(
    "terraform/terraform.tfvars",
    ".env",
    "aws-credentials.json"
)

foreach ($file in $sensitiveFiles) {
    if (Test-Path $file) {
        Write-Host "❌ Found sensitive file: $file" -ForegroundColor Red
        $errors++
    }
}

if ($errors -eq 0) {
    Write-Host "✅ No sensitive files found" -ForegroundColor Green
}

# Check for required files
Write-Host "📋 Checking for required files..." -ForegroundColor Yellow

$requiredFiles = @(
    "README.md",
    "LICENSE",
    "CONTRIBUTING.md",
    "CHANGELOG.md",
    ".gitignore",
    "terraform/main.tf",
    "terraform/variables.tf",
    "terraform/outputs.tf",
    "terraform/terraform.tfvars.example",
    "docs/DEPLOYMENT_GUIDE.md",
    "docs/TROUBLESHOOTING.md",
    "docs/ARCHITECTURE.md",
    "sensor_simulator.py",
    "requirements.txt",
    "package.json"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing: $file" -ForegroundColor Red
        $errors++
    }
}

# Check GitHub-specific files
Write-Host "🐙 Checking GitHub-specific files..." -ForegroundColor Yellow

$githubFiles = @(
    ".github/ISSUE_TEMPLATE/bug_report.md",
    ".github/ISSUE_TEMPLATE/feature_request.md",
    ".github/PULL_REQUEST_TEMPLATE.md",
    ".github/workflows/validate.yml"
)

foreach ($file in $githubFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing: $file" -ForegroundColor Red
        $errors++
    }
}

# Check for placeholder text that needs updating
Write-Host "📝 Checking for placeholders..." -ForegroundColor Yellow

$readmeContent = Get-Content "README.md" -Raw
if ($readmeContent -match "yourusername") {
    Write-Host "⚠️  Update 'yourusername' in README.md badges" -ForegroundColor Yellow
}

$packageContent = Get-Content "package.json" -Raw
if ($packageContent -match "yourusername") {
    Write-Host "⚠️  Update 'yourusername' in package.json repository URL" -ForegroundColor Yellow
}

# Validate JSON files
Write-Host "🔧 Validating JSON files..." -ForegroundColor Yellow

$jsonFiles = @(
    "package.json",
    "postman/IoT_Sensor_Testing.postman_collection.json"
)

foreach ($file in $jsonFiles) {
    if (Test-Path $file) {
        try {
            Get-Content $file | ConvertFrom-Json | Out-Null
            Write-Host "✅ $file is valid JSON" -ForegroundColor Green
        } catch {
            Write-Host "❌ $file has invalid JSON" -ForegroundColor Red
            $errors++
        }
    }
}

# Check Terraform syntax
Write-Host "🏗️ Validating Terraform syntax..." -ForegroundColor Yellow
Set-Location terraform
try {
    terraform fmt -check -recursive
    Write-Host "✅ Terraform formatting is correct" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Run 'terraform fmt -recursive' to fix formatting" -ForegroundColor Yellow
}
Set-Location ..

# Final summary
Write-Host ""
if ($errors -eq 0) {
    Write-Host "🎉 Repository validation passed!" -ForegroundColor Green
    Write-Host "✅ Ready for GitHub commit" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. git add ." -ForegroundColor White
    Write-Host "2. git commit -m 'feat: Complete IoT Sensor Alert System'" -ForegroundColor White
    Write-Host "3. git push origin main" -ForegroundColor White
} else {
    Write-Host "❌ Repository validation failed with $errors errors" -ForegroundColor Red
    Write-Host "Please fix the issues above before committing" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Repository Statistics:" -ForegroundColor Cyan
$totalFiles = (Get-ChildItem -Recurse -File | Measure-Object).Count
Write-Host "- Total files: $totalFiles" -ForegroundColor White
$docFiles = (Get-ChildItem -Recurse -File -Include "*.md" | Measure-Object).Count
Write-Host "- Documentation files: $docFiles" -ForegroundColor White
$codeFiles = (Get-ChildItem -Recurse -File -Include "*.js","*.tf","*.py" | Measure-Object).Count
Write-Host "- Code files: $codeFiles" -ForegroundColor White