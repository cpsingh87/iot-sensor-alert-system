# Test Normal Sensor Reading (No Alerts Expected)
Write-Host "Testing Normal Sensor Reading..." -ForegroundColor Green

$topicArn = "arn:aws:sns:us-east-2:064754721606:iot-sensor-data"
$message = @{
    sensor_id = "sensor-manual-001"
    location = "Manual Test Room"
    temperature = 22.5
    humidity = 45.0
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    battery_level = 85.5
} | ConvertTo-Json -Compress

Write-Host "Publishing message: $message" -ForegroundColor Cyan

aws sns publish --topic-arn $topicArn --message $message --subject "Manual Test - Normal Reading" --region us-east-2

Write-Host "✅ Normal reading test completed. Check DynamoDB for data storage." -ForegroundColor Green
Write-Host "Expected: Data stored, NO email alerts" -ForegroundColor Yellow