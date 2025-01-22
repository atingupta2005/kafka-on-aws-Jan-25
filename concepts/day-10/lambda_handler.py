import json
import base64
import logging
from confluent_kafka import Producer

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Kafka producer configuration
KAFKA_BROKERS = "<your-msk-broker-endpoints>"  # Comma-separated list of broker endpoints
ALERTS_TOPIC = "alerts-topic"

producer_config = {
    'bootstrap.servers': KAFKA_BROKERS,
    'client.id': 'lambda-producer',
    'security.protocol': 'SSL',  # Use if MSK is configured with SSL
    # Add SSL certificates if required
    # 'ssl.ca.location': '/path/to/cafile',
    # 'ssl.certificate.location': '/path/to/certificate',
    # 'ssl.key.location': '/path/to/keyfile'
}

# Initialize Kafka producer
producer = Producer(producer_config)


def lambda_handler(event, context):
    """
    AWS Lambda handler for processing vehicle data and sending alerts to a Kafka topic.
    """
    try:
        logger.info("Starting to process records")
        
        # Properly iterate over topic-partition keys and their associated messages
        for record_key, messages in event['records'].items():
            logger.info(f"Processing records for topic-partition: {record_key}")
            for message in messages:
                try:
                    # Safely access and decode the message value
                    if 'value' not in message:
                        logger.error(f"No 'value' field found in message: {message}")
                        continue

                    raw_value = message['value']
                    decoded_payload = decode_message(raw_value)
                    logger.info(f"Decoded payload: {decoded_payload}")

                    # Check for speeding and create an alert
                    if decoded_payload.get('speed', 0) > 80:
                        alert = {
                            "vehicleId": decoded_payload['vehicleId'],
                            "alert": "Speeding",
                            "speed": decoded_payload['speed'],
                            "timestamp": decoded_payload['timestamp']
                        }
                        # Publish the alert to the Kafka topic
                        publish_to_kafka(alert)
                except Exception as e:
                    logger.error(f"Error processing message: {str(e)}")
                    logger.error(f"Message: {message}")
                    logger.error("Traceback:")
                    logger.error(traceback.format_exc())
                    continue

        logger.info("Finished processing all records")
        return {"statusCode": 200, "message": "Processed successfully"}
    
    except Exception as e:
        logger.critical(f"Critical error: {str(e)}")
        logger.critical("Traceback:")
        logger.critical(traceback.format_exc())
        return {"statusCode": 500, "error": str(e)}


def decode_message(raw_value):
    """
    Decode the Base64-encoded Kafka message value and parse it as JSON.
    """
    try:
        decoded_value = base64.b64decode(raw_value).decode('utf-8')
        return json.loads(decoded_value)
    except Exception as decode_error:
        logger.error(f"Error decoding message: {raw_value}")
        logger.error(f"Error: {str(decode_error)}")
        logger.error("Traceback:")
        logger.error(traceback.format_exc())
        raise


def publish_to_kafka(alert):
    """
    Publishes an alert to the Kafka topic.
    """
    try:
        alert_json = json.dumps(alert)
        logger.info(f"Publishing alert to {ALERTS_TOPIC}: {alert_json}")
        producer.produce(ALERTS_TOPIC, alert_json.encode('utf-8'))
        producer.flush()  # Ensure the message is sent
    except Exception as e:
        logger.error(f"Error publishing to Kafka: {str(e)}")
        raise