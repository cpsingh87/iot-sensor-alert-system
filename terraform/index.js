const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb');
const { SNSClient, PublishCommand } = require('@aws-sdk/client-sns');

const dynamoClient = new DynamoDBClient({});
const dynamodb = DynamoDBDocumentClient.from(dynamoClient);
const sns = new SNSClient({});

exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    for (const record of event.Records) {
        try {
            const message = JSON.parse(record.Sns.Message);
            console.log('Processing sensor data:', message);
            
            // Store sensor reading in DynamoDB
            await storeSensorReading(message);
            
            // Check thresholds and trigger alerts if needed
            await checkThresholds(message);
            
        } catch (error) {
            console.error('Error processing record:', error);
        }
    }
    
    return { statusCode: 200, body: 'Successfully processed sensor data' };
};

async function storeSensorReading(sensorData) {
    const params = {
        TableName: process.env.DYNAMODB_TABLE,
        Item: {
            sensor_id: sensorData.sensor_id,
            timestamp: Date.now(),
            temperature: sensorData.temperature,
            humidity: sensorData.humidity,
            location: sensorData.location || 'Unknown'
        }
    };
    
    await dynamodb.send(new PutCommand(params));
    console.log('Stored sensor reading:', params.Item);
}

async function checkThresholds(sensorData) {
    const alerts = [];
    
    // Temperature thresholds
    if (sensorData.temperature > 30) {
        alerts.push({
            type: 'HIGH_TEMPERATURE',
            sensor_id: sensorData.sensor_id,
            value: sensorData.temperature,
            threshold: 30,
            message: `High temperature alert: ${sensorData.temperature}°C exceeds 30°C`
        });
    } else if (sensorData.temperature < 10) {
        alerts.push({
            type: 'LOW_TEMPERATURE',
            sensor_id: sensorData.sensor_id,
            value: sensorData.temperature,
            threshold: 10,
            message: `Low temperature alert: ${sensorData.temperature}°C below 10°C`
        });
    }
    
    // Humidity thresholds
    if (sensorData.humidity > 80) {
        alerts.push({
            type: 'HIGH_HUMIDITY',
            sensor_id: sensorData.sensor_id,
            value: sensorData.humidity,
            threshold: 80,
            message: `High humidity alert: ${sensorData.humidity}% exceeds 80%`
        });
    } else if (sensorData.humidity < 20) {
        alerts.push({
            type: 'LOW_HUMIDITY',
            sensor_id: sensorData.sensor_id,
            value: sensorData.humidity,
            threshold: 20,
            message: `Low humidity alert: ${sensorData.humidity}% below 20%`
        });
    }
    
    // Send alerts if any thresholds are breached
    for (const alert of alerts) {
        await sendAlert(alert);
    }
}

async function sendAlert(alert) {
    const params = {
        TopicArn: process.env.ALERT_TOPIC_ARN,
        Message: JSON.stringify(alert),
        Subject: `IoT Sensor Alert: ${alert.type}`
    };
    
    await sns.send(new PublishCommand(params));
    console.log('Alert sent:', alert);
}