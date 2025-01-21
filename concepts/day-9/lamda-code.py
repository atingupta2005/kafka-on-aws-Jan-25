import json
import base64
import logging
import traceback
import boto3
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize the S3 client
s3_client = boto3.client('s3')

# S3 bucket name
S3_BUCKET_NAME = 'atin-25-transformed-data-bucket'

def lambda_handler(event, context):
    """
    AWS Lambda handler for consuming messages from an MSK Kafka topic and storing them in S3.
    """
    try:
        logger.info("Starting message processing... - v6")
        logger.info(f"Received event: {json.dumps(event)}")

        # Process each record received from the Kafka topic
        for record_key, messages in event.get('records', {}).items():
            logger.info(f"Processing records for topic-partition: {record_key}")
            for message in messages:
                try:
                    # Log the raw Base64 value
                    raw_value = message['value']
                    logger.info(f"Raw Base64 Encoded Value: {raw_value}")

                    # Decode the Base64-encoded Kafka message value
                    decoded_value = decode_message(raw_value)
                    logger.info(f"Decoded Message Value: {decoded_value}")

                    # Upload the message to S3
                    upload_to_s3(decoded_value, record_key, message)

                except Exception as message_error:
                    # Log error for individual message processing
                    logger.error("Error processing message:")
                    logger.error(f"Message metadata: {json.dumps(message)}")
                    logger.error(f"Error: {str(message_error)}")
                    logger.error("Traceback:")
                    logger.error(traceback.format_exc())

        logger.info("Finished processing messages successfully.")
        return {"statusCode": 200, "message": "Messages processed successfully"}

    except Exception as e:
        # Log critical failure of the entire batch
        logger.critical("Critical error processing event batch:")
        logger.critical(f"Error: {str(e)}")
        logger.critical("Traceback:")
        logger.critical(traceback.format_exc())
        return {"statusCode": 500, "error": str(e)}


def decode_message(raw_value):
    """
    Decode the Base64-encoded Kafka message value.
    """
    try:
        decoded_value = base64.b64decode(raw_value).decode('utf-8')
        return decoded_value
    except Exception as decode_error:
        logger.error(f"Error decoding message: {raw_value}")
        logger.error(f"Error: {str(decode_error)}")
        logger.error("Traceback:")
        logger.error(traceback.format_exc())
        raise


def upload_to_s3(data, record_key, message_metadata):
    """
    Upload the decoded Kafka message to an S3 bucket.
    The file will be named using the topic, partition, and offset for uniqueness.
    """
    try:
        logger.info("Starting upload_to_s3... - v5")
        # Extract metadata for file naming
        topic_partition = record_key.replace(':', '-')
        offset = message_metadata.get('offset', 'unknown')
        timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')

        # Define the S3 object key (path in the bucket)
        s3_object_key = f"kafka-data/{topic_partition}/message-{offset}-{timestamp}.txt"

        # Upload the data to S3
        s3_client.put_object(
            Bucket=S3_BUCKET_NAME,
            Key=s3_object_key,
            Body=data,
            ContentType='text/plain'
        )
        logger.info(f"Uploaded message to S3: {s3_object_key}")

    except Exception as s3_error:
        logger.error("Error uploading data to S3:")
        logger.error(f"Data: {data}")
        logger.error(f"Error: {str(s3_error)}")
        logger.error("Traceback:")
        logger.error(traceback.format_exc())
        raise
