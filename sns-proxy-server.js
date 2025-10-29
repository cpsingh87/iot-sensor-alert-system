/**
 * SNS Proxy Server for Postman Testing
 * This server acts as a proxy to publish messages to AWS SNS
 * Run with: node sns-proxy-server.js
 */

const { SNSClient, PublishCommand } = require('@aws-sdk/client-sns');
const express = require('express');
const cors = require('cors');

const app = express();
const port = 3000;

// Configure AWS SNS
const sns = new SNSClient({ region: 'us-east-2' });
const SENSOR_TOPIC_ARN = 'arn:aws:sns:us-east-2:064754721606:iot-sensor-data';

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        topicArn: SENSOR_TOPIC_ARN
    });
});

// Publish sensor data to SNS
app.post('/publish-sensor-data', async (req, res) => {
    try {
        console.log('📡 Received sensor data:', JSON.stringify(req.body, null, 2));
        
        // Validate required fields
        const { sensor_id, temperature, humidity } = req.body;
        if (!sensor_id || temperature === undefined || humidity === undefined) {
            return res.status(400).json({ 
                error: 'Missing required fields: sensor_id, temperature, humidity' 
            });
        }

        // Publish to SNS
        const command = new PublishCommand({
            TopicArn: SENSOR_TOPIC_ARN,
            Message: JSON.stringify(req.body),
            Subject: `Sensor Data from ${sensor_id}`
        });

        const result = await sns.send(command);
        
        console.log('✅ Published to SNS:', result.MessageId);
        
        // Determine expected alerts
        const alerts = [];
        if (temperature > 30) alerts.push('HIGH_TEMPERATURE');
        if (temperature < 10) alerts.push('LOW_TEMPERATURE');
        if (humidity > 80) alerts.push('HIGH_HUMIDITY');
        if (humidity < 20) alerts.push('LOW_HUMIDITY');

        res.json({ 
            success: true, 
            messageId: result.MessageId,
            sensorId: sensor_id,
            expectedAlerts: alerts.length > 0 ? alerts : ['NONE'],
            message: 'Data published successfully to SNS'
        });

    } catch (error) {
        console.error('❌ Error publishing to SNS:', error);
        res.status(500).json({ 
            error: error.message,
            code: error.code || 'UNKNOWN_ERROR'
        });
    }
});

// Get recent DynamoDB items (for verification)
app.get('/verify-data', async (req, res) => {
    try {
        const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
        const { DynamoDBDocumentClient, ScanCommand } = require('@aws-sdk/lib-dynamodb');
        
        const dynamoClient = new DynamoDBClient({ region: 'us-east-2' });
        const dynamodb = DynamoDBDocumentClient.from(dynamoClient);
        
        const result = await dynamodb.send(new ScanCommand({
            TableName: 'sensor-readings',
            Limit: 10
        }));
        
        res.json({
            success: true,
            itemCount: result.Count,
            items: result.Items.sort((a, b) => b.timestamp - a.timestamp) // Sort by timestamp desc
        });
        
    } catch (error) {
        console.error('❌ Error querying DynamoDB:', error);
        res.status(500).json({ 
            error: error.message,
            code: error.code || 'UNKNOWN_ERROR'
        });
    }
});

// Start server
app.listen(port, () => {
    console.log('🚀 SNS Proxy Server started');
    console.log(`📡 Server running at http://localhost:${port}`);
    console.log(`🔗 SNS Topic: ${SENSOR_TOPIC_ARN}`);
    console.log('');
    console.log('Available endpoints:');
    console.log('  GET  /health           - Health check');
    console.log('  POST /publish-sensor-data - Publish sensor data to SNS');
    console.log('  GET  /verify-data      - Get recent DynamoDB items');
    console.log('');
    console.log('💡 Use Postman to test the endpoints!');
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down SNS Proxy Server...');
    process.exit(0);
});

module.exports = app;