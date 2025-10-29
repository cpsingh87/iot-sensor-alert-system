# Test Low Humidity Alert
Write-Host "Testing Low Humidity Alert..." -ForegroundColor Blue

$topicArn = "arn:aws:sns:us-east-2:064754721606:iot-sensor-data"
$message = @{
    sensor_id = "sensor-manual-003"
    location = "Manual Test Room - Dry"
    temperature = 24.5
    humidity = 12.3
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    battery_level = 92.1
} | ConvertTo-Json -Compress

Write-Host "Publishing LOW HUMIDITY message: $message" -ForegroundColor Cyan

aws sns publish --topic-arn $topicArn --message $message --subject "Manual Test - Low Humidity" --region us-east-2

Write-Host "🚨 Low humidity test completed." -ForegroundColor Blue
Write-Host "Expected: Data stored + LOW_HUMIDITY email alert" -ForegroundColor Yellow
Write-Host "Check your email: risox72951@ametitas.com" -ForegroundColor Magenta