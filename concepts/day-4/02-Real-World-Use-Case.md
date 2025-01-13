### Real-World Use Case: Log Processing Pipeline with Kafka

#### **Objective**
This document describes how to build a log processing pipeline where Kafka streams logs to Amazon S3 for storage and triggers AWS Lambda functions for real-time processing. The solution is scalable, reliable, and ideal for scenarios requiring both real-time insights and long-term storage.

---

### **Architecture Overview**

**Components:**
1. **Producers:**
   - Applications or services send log data (e.g., error logs, application logs) to Kafka topics.

2. **Kafka Cluster:**
   - Kafka brokers store and stream logs.
   - Topics:
     - `raw_logs`: Receives raw log data.
     - `processed_logs`: Stores logs after real-time processing.

3. **S3 Sink Connector (Kafka Connect):**
   - Streams logs from the `raw_logs` topic to an Amazon S3 bucket for long-term storage.

4. **AWS Lambda:**
   - Processes logs in real time from Kafka.
   - Performs tasks like filtering, aggregating, or triggering alerts based on log contents.

5. **Data Consumers:**
   - Visualization tools (e.g., Kibana, Grafana) or analytics services (e.g., Redshift) for querying and analyzing processed logs.

**Workflow Diagram:**
```
[Applications/Services] --> [Kafka Topic: raw_logs] --> [Kafka Connect: S3 Sink] --> [Amazon S3]
                                        |
                                        +--> [AWS Lambda: Real-Time Processing] --> [Kafka Topic: processed_logs]
                                                                                              |
                                                                                              +--> [Consumers/Visualization]
```

---

### **Implementation Steps**

#### **1. Setting Up Kafka for Log Ingestion**

1. **Create Kafka Topics:**
   - Create a topic for raw logs (`raw_logs`):
     ```bash
     kafka-topics.sh --create \
         --bootstrap-server <bootstrap-servers> \
         --replication-factor 3 \
         --partitions 6 \
         --topic raw_logs
     ```

2. **Configure Producers:**
   - Applications or log-forwarding agents (e.g., Fluentd, Logstash) act as producers to send logs to the `raw_logs` topic.
   - Example producer snippet (Python):
     ```python
     from kafka import KafkaProducer
     import json

     producer = KafkaProducer(
         bootstrap_servers=['$BS_SERVER'],
         value_serializer=lambda x: json.dumps(x).encode('utf-8')
     )

     log_entry = {
         "timestamp": "2025-01-01T12:00:00Z",
         "level": "ERROR",
         "message": "An error occurred",
         "service": "user-service"
     }

     producer.send('raw_logs', value=log_entry)
     producer.close()
     ```

---

#### **2. Streaming Logs to S3 Using Kafka Connect**

1. **Set Up the S3 Bucket:**
   - Create an S3 bucket (e.g., `kafka-logs-bucket`).
   - Ensure the IAM role or access keys used by Kafka Connect have permissions to write to the bucket.

2. **Install and Configure the S3 Sink Connector:**
   - Download the S3 Sink Connector (e.g., from Confluent Hub).
   - Configure the connector with the following properties (`s3-sink.properties`):
     ```
     name=msk-connect-s3-connector
     connector.class=io.confluent.connect.s3.S3SinkConnector
     tasks.max=1
     topics=raw_logs
     s3.region=ap-southeast-2
     s3.bucket.name=kafka-logs-bucket
     s3.part.size=5242880
     flush.size=100
     key.converter=org.apache.kafka.connect.storage.StringConverter
     value.converter=org.apache.kafka.connect.json.JsonConverter
     storage.class=io.confluent.connect.s3.storage.S3Storage
     format.class=io.confluent.connect.s3.format.json.JsonFormat
     ```


3. **Verify S3 Integration:**
   - Check the S3 bucket to confirm logs from the `raw_logs` topic are being saved.

----

#### **3. Real-Time Processing with AWS Lambda**

1. **Create an AWS Lambda Function:**
   - Example Lambda function for filtering error logs:
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

2. **Configure the Event Source Mapping:**
   - Create a mapping between the Kafka topic (`raw_logs`) and the Lambda function:
     ```bash
     aws lambda create-event-source-mapping \
         --function-name ProcessKafkaLogs \
         --batch-size 100 \
         --event-source-arn <msk-topic-arn>
     ```

3. **Output Processed Logs to Kafka:**
   - Modify the Lambda function to write processed logs back to Kafka:
     ```python
     from kafka import KafkaProducer

     producer = KafkaProducer(
         bootstrap_servers=['$BS_SERVER'],
         value_serializer=lambda x: json.dumps(x).encode('utf-8')
     )

     producer.send('processed_logs', value=processed_log_entry)
     ```

---

#### **4. Consuming and Visualizing Processed Logs**

1. **Set Up Consumers:**
   - Analytics services or dashboards (e.g., Elasticsearch, Grafana) subscribe to the `processed_logs` topic.

2. **Long-Term Storage:**
   - Use the S3 bucket to query historical logs using AWS Athena or to generate reports in QuickSight.

---

### **Benefits of the Pipeline**

1. **Real-Time Insights:**
   - Enables quick detection and response to critical log events.

2. **Scalability:**
   - Kafka’s distributed architecture allows handling high log volumes.

3. **Cost Efficiency:**
   - Logs are stored cost-effectively in S3 for historical analysis.

4. **Flexibility:**
   - Lambda functions can be customized for a variety of real-time processing tasks.

---

### **Challenges and Mitigations**

1. **High Data Volume:**
   - **Challenge:** Kafka Connect may struggle with high-throughput logs.
   - **Solution:** Increase the number of tasks in the S3 Sink Connector (`tasks.max`).

2. **Lambda Invocation Failures:**
   - **Challenge:** Large batches of logs may lead to timeouts.
   - **Solution:** Tune the batch size and processing time in the Lambda configuration.

3. **Consumer Lag:**
   - **Challenge:** Real-time consumers falling behind Kafka producers.
   - **Solution:** Scale consumers horizontally and monitor lag metrics.

---

### **Conclusion**
This pipeline demonstrates the powerful integration of Kafka with AWS services to process and store logs in real time. By leveraging Kafka’s scalability, S3’s cost-effective storage, and Lambda’s real-time capabilities, organizations can build resilient and flexible log processing systems tailored to their needs.
