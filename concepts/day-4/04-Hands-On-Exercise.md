### Hands-On Exercise: Implementing the Log Processing Pipeline Using Kafka

#### **Objective**
This hands-on exercise will guide you through implementing a log processing pipeline using Kafka and AWS services (e.g., S3, Lambda). It includes setting up the pipeline and troubleshooting common integration issues.

---

### **Part 1: Setting Up the Log Processing Pipeline**

#### **Step 1: Kafka Topic Creation**
1. **Create a Topic for Logs**
   - Create a topic named `raw_logs` to store incoming log data:
     ```bash
     kafka-topics.sh --create \
         --bootstrap-server <bootstrap-servers> \
         --replication-factor 3 \
         --partitions 6 \
         --topic raw_logs
     ```

2. **Verify Topic Creation**
   - List the available topics to confirm:
     ```bash
     kafka-topics.sh --list \
         --bootstrap-server <bootstrap-servers>
     ```

#### **Step 2: Producer Configuration**
1. **Set Up a Log Producer**
   - Configure a producer to send logs to the `raw_logs` topic. Example code (Python):
     ```python
     from kafka import KafkaProducer
     import json

     producer = KafkaProducer(
         bootstrap_servers=['$BS_SERVER'],
         value_serializer=lambda x: json.dumps(x).encode('utf-8')
     )

     log_entry = {
         "timestamp": "2025-01-01T12:00:00Z",
         "level": "INFO",
         "message": "Application started",
         "service": "auth-service"
     }

     producer.send('raw_logs', value=log_entry)
     producer.close()
     ```

2. **Test Log Production**
   - Run the producer and verify that logs are sent to Kafka.

#### **Step 3: Kafka Connect to Stream Logs to S3**
1. **Set Up an S3 Bucket**
   - Create an S3 bucket (e.g., `kafka-logs-bucket`).
   - Ensure the IAM role or access keys have `s3:PutObject` and `s3:ListBucket` permissions.

2. **Configure the S3 Sink Connector**
   - Create a properties file (`s3-sink.properties`) for the connector:
     ```
     name=s3-sink-connector
     connector.class=io.confluent.connect.s3.S3SinkConnector
     tasks.max=1
     topics=raw_logs
     s3.region=us-east-1
     s3.bucket.name=kafka-logs-bucket
     flush.size=100
     key.converter=org.apache.kafka.connect.storage.StringConverter
     value.converter=org.apache.kafka.connect.json.JsonConverter
     storage.class=io.confluent.connect.s3.storage.S3Storage
     format.class=io.confluent.connect.s3.format.json.JsonFormat
     ```

3. **Verify Data in S3**
   - Check the S3 bucket to confirm that logs are being written successfully.

#### **Step 4: Real-Time Processing with AWS Lambda**
1. **Set Up a Lambda Function**
   - Write a Lambda function to process logs in real time. Example:
     ```python
     import json

     def lambda_handler(event, context):
         for record in event['records']:
             log_entry = json.loads(record['value'])
             if log_entry['level'] == 'ERROR':
                 print(f"Error log detected: {log_entry}")
         return {
             "statusCode": 200,
             "body": json.dumps("Logs processed successfully")
         }
     ```

2. **Configure the Event Source Mapping**
   - Map the Lambda function to the Kafka topic (`raw_logs`):
     ```bash
     aws lambda create-event-source-mapping \
         --function-name ProcessKafkaLogs \
         --batch-size 100 \
         --event-source-arn <msk-topic-arn>
     ```

3. **Test the Lambda Integration**
   - Produce logs to the `raw_logs` topic and monitor Lambda logs for processing results.

---

### **Part 2: Troubleshooting Integration Issues**

#### **Issue 1: Kafka Connect Fails to Write to S3**
- **Symptoms:** Logs are not appearing in the S3 bucket.
- **Potential Causes:**
  1. Incorrect S3 bucket permissions.
  2. Misconfigured `s3-sink.properties`.
- **Resolution:**
  1. Verify IAM permissions for the bucket using the AWS Policy Simulator.
  2. Double-check the bucket name and region in the properties file.

#### **Issue 2: Lambda Not Triggering**
- **Symptoms:** Logs in the Kafka topic are not invoking the Lambda function.
- **Potential Causes:**
  1. Incorrect event source mapping.
  2. Lambda lacks permissions to access the Kafka topic.
- **Resolution:**
  1. Use the AWS CLI to check the event source mapping:
     ```bash
     aws lambda list-event-source-mappings --function-name ProcessKafkaLogs
     ```
  2. Ensure the Lambda execution role includes the `AWSKafkaReader` managed policy.

#### **Issue 3: Consumer Lag**
- **Symptoms:** Lambda function or other consumers fall behind in processing logs.
- **Potential Causes:**
  1. High message volume.
  2. Insufficient batch size or parallelism.
- **Resolution:**
  1. Increase the batch size in the Lambda event source mapping.
  2. Scale the number of partitions or consumers in the pipeline.

---

### **Part 3: Validation and Cleanup**

#### **Validation**
1. Confirm logs are successfully:
   - Produced to the Kafka topic (`raw_logs`).
   - Written to the S3 bucket by the S3 Sink Connector.
   - Processed in real time by the Lambda function.

2. Monitor metrics in CloudWatch for:
   - Lambda execution success and failure rates.
   - Kafka Connect task health.

#### **Cleanup**
1. Stop the Kafka Connect worker and delete the S3 Sink Connector.
2. Delete the Kafka topic:
   ```bash
   kafka-topics.sh --delete \
       --bootstrap-server <bootstrap-servers> \
       --topic raw_logs
   ```
3. Delete the Lambda function and associated event source mapping.
4. Delete the S3 bucket if no longer needed.

---

### **Conclusion**
By completing this exercise, you have implemented a Kafka-based log processing pipeline integrated with AWS services and learned how to troubleshoot common issues. This practical experience provides a foundation for building scalable and reliable event-driven architectures.
