# Test High Temperature Alert
Write-Host "Testing High Temperature Alert..." -ForegroundColor Red

$topicArn = "arn:aws:sns:us-east-2:064754721606:iot-sensor-data"
$message = @{
    sensor_id = "sensor-manual-002"
    location = "Manual Test Room - Hot"
    temperature = 35.8
    humidity = 45.0
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    battery_level = 78.2
} | ConvertTo-Json -Compress

Write-Host "Publishing HIGH TEMPERATURE message: $message" -ForegroundColor Cyan

aws sns publish --topic-arn $topicArn --message $message --subject "Manual Test - High Temperature" --region us-east-2

Write-Host "🚨 High temperature test completed." -ForegroundColor Red
Write-Host "Expected: Data stored + HIGH_TEMPERATURE email alert" -ForegroundColor Yellow
Write-Host "Check your email: risox72951@ametitas.com" -ForegroundColor Magenta