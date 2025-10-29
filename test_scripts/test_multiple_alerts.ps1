# Test Multiple Alerts (High Temp + Low Humidity)
Write-Host "Testing Multiple Alerts (High Temperature + Low Humidity)..." -ForegroundColor Magenta

$topicArn = "arn:aws:sns:us-east-2:064754721606:iot-sensor-data"
$message = @{
    sensor_id = "sensor-manual-004"
    location = "Manual Test Room - Critical"
    temperature = 38.7
    humidity = 8.5
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    battery_level = 65.3
} | ConvertTo-Json -Compress

Write-Host "Publishing MULTIPLE ALERTS message: $message" -ForegroundColor Cyan

aws sns publish --topic-arn $topicArn --message $message --subject "Manual Test - Multiple Alerts" --region us-east-2

Write-Host "🚨🚨 Multiple alerts test completed." -ForegroundColor Magenta
Write-Host "Expected: Data stored + 2 email alerts (HIGH_TEMPERATURE + LOW_HUMIDITY)" -ForegroundColor Yellow
Write-Host "Check your email: risox72951@ametitas.com" -ForegroundColor Magenta