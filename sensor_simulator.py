#!/usr/bin/env python3
"""
Simple IoT Sensor Simulator
Sends temperature and humidity data to AWS SNS
"""

import json
import random
import time
import boto3
import argparse
from datetime import datetime

def generate_sensor_data(sensor_id, anomaly=False):
    """Generate sensor data with optional anomalies"""
    
    if anomaly:
        # Generate anomalous readings to trigger alerts
        temperature = random.choice([
            random.uniform(-5, 5),    # Very cold
            random.uniform(35, 45)    # Very hot
        ])
        humidity = random.choice([
            random.uniform(5, 15),    # Very dry
            random.uniform(85, 95)    # Very humid
        ])
    else:
        # Normal readings
        temperature = random.uniform(18, 28)  # Normal room temperature
        humidity = random.uniform(30, 70)     # Normal humidity
    
    return {
        'sensor_id': sensor_id,
        'location': f'Room {sensor_id[-1]}',
        'temperature': round(temperature, 2),
        'humidity': round(humidity, 2),
        'timestamp': datetime.utcnow().isoformat(),
        'battery_level': random.uniform(20, 100)
    }

def send_sensor_data(sns_client, topic_arn, sensor_data):
    """Send sensor data to SNS topic"""
    try:
        message = json.dumps(sensor_data)
        
        response = sns_client.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject=f'Sensor Data from {sensor_data["sensor_id"]}'
        )
        
        print(f"✅ Sent data from {sensor_data['sensor_id']}: "
              f"Temp={sensor_data['temperature']}°C, "
              f"Humidity={sensor_data['humidity']}% "
              f"(MessageId: {response['MessageId'][:8]}...)")
        
        return True
        
    except Exception as e:
        print(f"❌ Error sending data from {sensor_data['sensor_id']}: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='IoT Sensor Simulator')
    parser.add_argument('--topic-arn', required=True, help='SNS Topic ARN')
    parser.add_argument('--region', default='us-east-2', help='AWS Region')
    parser.add_argument('--count', type=int, default=10, help='Number of readings to send')
    parser.add_argument('--anomaly-chance', type=float, default=0.3, 
                       help='Probability of anomalous readings (0.0-1.0)')
    
    args = parser.parse_args()
    
    # Initialize SNS client
    sns_client = boto3.client('sns', region_name=args.region)
    
    sensors = ['sensor-001', 'sensor-002', 'sensor-003']
    
    print(f"🚀 Starting IoT sensor simulation...")
    print(f"📡 SNS Topic: {args.topic_arn}")
    print(f"🔢 Sensors: {len(sensors)}")
    print(f"📊 Readings per sensor: {args.count}")
    print(f"⚠️  Anomaly chance: {args.anomaly_chance * 100}%")
    print("-" * 60)
    
    total_sent = 0
    total_anomalies = 0
    
    for i in range(args.count):
        for sensor in sensors:
            # Randomly introduce anomalies
            is_anomaly = random.random() < args.anomaly_chance
            
            sensor_data = generate_sensor_data(sensor, anomaly=is_anomaly)
            
            if send_sensor_data(sns_client, args.topic_arn, sensor_data):
                total_sent += 1
                if is_anomaly:
                    total_anomalies += 1
                    print(f"🚨 Anomaly generated for {sensor}")
        
        if i < args.count - 1:
            print(f"💤 Waiting 3 seconds...")
            time.sleep(3)
    
    print("\n" + "=" * 60)
    print(f"✅ Simulation complete!")
    print(f"📊 Total messages sent: {total_sent}")
    print(f"🚨 Anomalies generated: {total_anomalies}")
    print(f"📧 Check your email for alerts!")
    print(f"📈 Check DynamoDB table for stored data!")

if __name__ == '__main__':
    main()