**Capstone Project: Building a Kafka-Based Data Pipeline or Stream Processing Solution**

---

### **1. Objective**
The capstone project provides participants with hands-on experience in designing and implementing a Kafka-based data pipeline or stream processing solution. The project integrates concepts learned throughout the course, including data ingestion, transformation, and storage.

---

### **2. Project Overview**
Participants will build a data pipeline that processes streaming data for a real-world use case. Example scenarios include:
- Real-time fraud detection.
- IoT sensor data analysis.
- Financial transaction aggregation.

#### **Key Goals:**
1. Implement a Kafka-based solution using AWS MSK.
2. Design producers and consumers to handle real-time data.
3. Process data with AWS Lambda or Kafka Streams.
4. Store processed data in a target system like Amazon S3 or DynamoDB.

---

### **3. Use Case: Real-Time Fleet Monitoring System**

#### **Problem Statement:**
A logistics company needs a real-time monitoring system to track its fleet of vehicles. The system should:
- Process location, speed, and fuel-level data from GPS devices.
- Identify vehicles exceeding speed limits.
- Archive data for analytics and generate alerts for exceptions.

#### **Requirements:**
- High-throughput data ingestion from multiple devices.
- Real-time processing for alerts.
- Scalable and fault-tolerant architecture.

---

### **4. Implementation Plan**

#### **4.1 Setting Up the Infrastructure**
1. **Create an AWS MSK Cluster:**
   - Navigate to the AWS MSK console and create a cluster with:
     - 3 brokers for fault tolerance.
     - Encryption at rest and in transit.
2. **Create Kafka Topics:**
   - Use AWS CLI to create topics:
     ```bash
     export BS_SERVER=""
     kafka-topics.sh --create --bootstrap-server $BS_SERVER --replication-factor 3 --partitions 3 --topic raw-data-topic
     kafka-topics.sh --create --bootstrap-server $BS_SERVER --replication-factor 3 --partitions 3 --topic processed-data-topic
     kafka-topics.sh --create --bootstrap-server $BS_SERVER --replication-factor 3 --partitions 3 --topic alerts-topic
     ```


---

#### **4.2 Data Ingestion**
1. **Set Up Producers:**
   - Write a Python producer to simulate GPS data:
     ```python
     from kafka import KafkaProducer
     import json
     import time

     producer = KafkaProducer(
         bootstrap_servers='<MSK-Broker-Endpoint>',
         value_serializer=lambda v: json.dumps(v).encode('utf-8')
     )

     while True:
         data = {
             "vehicleId": "V123",
             "location": "12.97,77.59",
             "speed": 85,
             "fuelLevel": 50,
             "timestamp": "2025-01-15T10:00:00Z"
         }
         producer.send('raw-data-topic', data)
         time.sleep(1)
     ```

---

#### **4.3 Data Transformation**

1. **Stream Processing with AWS Lambda:**
   - Set up a Lambda function to consume data from `raw-data-topic`, apply transformations, and publish to `processed-data-topic`.
   - Example Lambda function:
   ```python
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
   ```

---

#### **4.4 Data Storage**
1. **Archiving Data:**
   - Use Amazon S3 to store transformed data:
     - Configure AWS Lambda to write processed data to an S3 bucket.
2. **Real-Time Analytics:**
   - Configure Amazon OpenSearch to index alerts for visualization.

---

### **5. Validation and Testing**

#### **5.1 Data Flow Testing:**
1. Simulate GPS data ingestion by running the producer script.
2. Verify that raw data is published to `raw-data-topic`.

#### **5.2 End-to-End Validation:**
1. Check processed data in `processed-data-topic`.
2. Verify alerts in `alerts-topic` and S3.
3. Query indexed alerts in Amazon OpenSearch.

---

### **6. Monitoring and Scaling**

1. **Monitor Metrics:**
   - Use CloudWatch to monitor `BytesInPerSec` and `ConsumerLag`.
2. **Scale MSK:**
   - Add partitions to Kafka topics as data volume increases.

---

### **7. Deliverables**
Participants will submit:
1. Source code for producers, Lambda functions, and consumers.
2. Screenshots or logs demonstrating end-to-end pipeline functionality.
3. Documentation of the architecture and implementation steps.

---

### **8. Evaluation Criteria**
1. **Functionality:**
   - The pipeline processes data as expected.
2. **Scalability:**
   - The solution can handle increasing data volumes.
3. **Security:**
   - Encryption and access control are correctly implemented.
4. **Documentation:**
   - Clear and complete documentation of the pipeline.

---
