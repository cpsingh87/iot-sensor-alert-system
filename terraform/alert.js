const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');
const ses = new SESClient({});

exports.handler = async (event) => {
    console.log('Received alert event:', JSON.stringify(event, null, 2));
    
    for (const record of event.Records) {
        try {
            const alert = JSON.parse(record.Sns.Message);
            console.log('Processing alert:', alert);
            
            await sendEmailAlert(alert);
            
        } catch (error) {
            console.error('Error processing alert:', error);
        }
    }
    
    return { statusCode: 200, body: 'Successfully processed alerts' };
};

async function sendEmailAlert(alert) {
    const emailParams = {
        Source: process.env.ALERT_EMAIL,
        Destination: {
            ToAddresses: [process.env.ALERT_EMAIL]
        },
        Message: {
            Subject: {
                Data: `🚨 IoT Sensor Alert: ${alert.type}`,
                Charset: 'UTF-8'
            },
            Body: {
                Html: {
                    Data: generateEmailHtml(alert),
                    Charset: 'UTF-8'
                },
                Text: {
                    Data: generateEmailText(alert),
                    Charset: 'UTF-8'
                }
            }
        }
    };
    
    await ses.send(new SendEmailCommand(emailParams));
    console.log('Email alert sent for:', alert.sensor_id);
}

function generateEmailHtml(alert) {
    return `
        <html>
        <body>
            <h2>🚨 IoT Sensor Alert</h2>
            <p><strong>Alert Type:</strong> ${alert.type}</p>
            <p><strong>Sensor ID:</strong> ${alert.sensor_id}</p>
            <p><strong>Current Value:</strong> ${alert.value}</p>
            <p><strong>Threshold:</strong> ${alert.threshold}</p>
            <p><strong>Message:</strong> ${alert.message}</p>
            <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
            
            <hr>
            <p><em>This is an automated alert from your IoT Sensor Monitoring System.</em></p>
        </body>
        </html>
    `;
}

function generateEmailText(alert) {
    return `
🚨 IoT Sensor Alert

Alert Type: ${alert.type}
Sensor ID: ${alert.sensor_id}
Current Value: ${alert.value}
Threshold: ${alert.threshold}
Message: ${alert.message}
Timestamp: ${new Date().toISOString()}

---
This is an automated alert from your IoT Sensor Monitoring System.
    `;
}