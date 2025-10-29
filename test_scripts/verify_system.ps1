# System Verification Script
Write-Host "🔍 IoT Sensor Alert System Verification" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# 1. Check SNS Topics
Write-Host "`n1. Checking SNS Topics..." -ForegroundColor Yellow
aws sns list-topics --region us-east-2 --query "Topics[?contains(TopicArn, 'iot-sensor')]"

# 2. Check Lambda Functions
Write-Host "`n2. Checking Lambda Functions..." -ForegroundColor Yellow
Write-Host "Sensor Processor Function:" -ForegroundColor Cyan
aws lambda get-function --function-name iot-sensor-processor --region us-east-2 --query "Configuration.{State:State,LastModified:LastModified,Runtime:Runtime}"

Write-Host "Alert Sender Function:" -ForegroundColor Cyan
aws lambda get-function --function-name iot-alert-sender --region us-east-2 --query "Configuration.{State:State,LastModified:LastModified,Runtime:Runtime}"

# 3. Check DynamoDB Table
Write-Host "`n3. Checking DynamoDB Table..." -ForegroundColor Yellow
aws dynamodb describe-table --table-name sensor-readings --region us-east-2 --query "Table.{Status:TableStatus,ItemCount:ItemCount,CreationDateTime:CreationDateTime}"

# 4. Check Recent DynamoDB Items
Write-Host "`n4. Recent DynamoDB Items (Last 5)..." -ForegroundColor Yellow
aws dynamodb scan --table-name sensor-readings --region us-east-2 --max-items 5 --query "Items[*].{SensorID:sensor_id.S,Temperature:temperature.N,Humidity:humidity.N,Timestamp:timestamp.N}"

# 5. Check Lambda Logs (Recent)
Write-Host "`n5. Recent Lambda Processor Logs..." -ForegroundColor Yellow
$startTime = [DateTimeOffset]::UtcNow.AddMinutes(-30).ToUnixTimeMilliseconds()
aws logs filter-log-events --log-group-name "/aws/lambda/iot-sensor-processor" --start-time $startTime --region us-east-2 --query "events[0:3].{Time:timestamp,Message:message}" --output table

Write-Host "`n6. Recent Alert Sender Logs..." -ForegroundColor Yellow
aws logs filter-log-events --log-group-name "/aws/lambda/iot-alert-sender" --start-time $startTime --region us-east-2 --query "events[0:3].{Time:timestamp,Message:message}" --output table

# 7. Check SNS Subscriptions
Write-Host "`n7. Checking SNS Subscriptions..." -ForegroundColor Yellow
Write-Host "Sensor Data Topic Subscriptions:" -ForegroundColor Cyan
aws sns list-subscriptions-by-topic --topic-arn "arn:aws:sns:us-east-2:064754721606:iot-sensor-data" --region us-east-2 --query "Subscriptions[*].{Protocol:Protocol,Endpoint:Endpoint}"

Write-Host "Alert Topic Subscriptions:" -ForegroundColor Cyan
aws sns list-subscriptions-by-topic --topic-arn "arn:aws:sns:us-east-2:064754721606:iot-sensor-alerts" --region us-east-2 --query "Subscriptions[*].{Protocol:Protocol,Endpoint:Endpoint}"

# 8. Check SES Status
Write-Host "`n8. Checking SES Email Identity..." -ForegroundColor Yellow
aws ses get-identity-verification-attributes --identities "risox72951@ametitas.com" --region us-east-2

Write-Host "`n✅ System verification completed!" -ForegroundColor Green
Write-Host "Review the output above to ensure all components are healthy." -ForegroundColor Cyan