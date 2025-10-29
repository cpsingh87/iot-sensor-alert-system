# Simple Repository Validation Script

Write-Host "🔍 Validating Repository for GitHub..." -ForegroundColor Green

$errors = 0

# Check for sensitive files
$sensitiveFiles = @("terraform/terraform.tfvars", ".env")
foreach ($file in $sensitiveFiles) {
    if (Test-Path $file) {
        Write-Host "❌ Found sensitive file: $file" -ForegroundColor Red
        $errors++
    }
}

# Check for required files
$requiredFiles = @(
    "README.md",
    "LICENSE", 
    "CONTRIBUTING.md",
    "terraform/main.tf",
    "terraform/terraform.tfvars.example"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing: $file" -ForegroundColor Red
        $errors++
    }
}

if ($errors -eq 0) {
    Write-Host "🎉 Repository validation passed!" -ForegroundColor Green
    Write-Host "✅ Ready for GitHub commit" -ForegroundColor Green
} else {
    Write-Host "❌ Found $errors issues" -ForegroundColor Red
}