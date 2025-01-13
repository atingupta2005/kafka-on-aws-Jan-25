import json
import traceback
import logging
import os

# Set up logging for better visibility
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def lambda_handler(event, context):
    try:
        # Log the event details for debugging purposes
        logger.debug(f"Event: {json.dumps(event)}")
        
        # Get the records from the event
        records = event.get('records', [])
        
        if not records:
            logger.warning("No records found in the event.")
        
        for record in records:
            try:
                # Extract and log relevant metadata
                topic_name = event.get('topic', 'Unknown')
                msk_name = os.getenv('MSK_CLUSTER_NAME', 'Not Set')  # Assuming you set MSK cluster name as an environment variable
                region = os.getenv('AWS_REGION', 'Unknown Region')

                # Log the metadata (topic, region, and MSK cluster)
                logger.info(f"Processing record from topic: {topic_name} in MSK cluster: {msk_name}, region: {region}")
                
                # Process the record
                payload = json.loads(record['value'])
                logger.info(f"Processed payload: {json.dumps(payload)}")
            
            except json.JSONDecodeError as json_err:
                logger.error(f"JSON decoding error: {json_err}")
                logger.error(f"Record: {record}")
                continue  # Skip this record and continue with the next
                
            except Exception as e:
                # Log any other exceptions with stack trace
                logger.error("Error occurred while processing the record.")
                logger.error(f"Error: {str(e)}")
                logger.error(f"Traceback: {traceback.format_exc()}")
                continue  # Skip this record and continue with the next

    except Exception as e:
        # Log any global errors in the Lambda function
        logger.error("Error occurred in lambda_handler.")
        logger.error(f"Error: {str(e)}")
        logger.error(f"Traceback: {traceback.format_exc()}")
